import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/area.dart';
import '../../models/usuario.dart';
import '../../services/api_service.dart';
import '../../services/usuario_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/loading_shimmer.dart';

class RolesPermissionsScreen extends StatefulWidget {
  const RolesPermissionsScreen({super.key});

  @override
  State<RolesPermissionsScreen> createState() => _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState extends State<RolesPermissionsScreen> {
  List<Usuario> _usuarios = [];
  List<Area> _areas = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedRolFilter;
  String? _selectedAreaFilter;
  bool? _selectedEstadoFilter;

  final TextEditingController _searchController = TextEditingController();

  // Roles disponibles
  final List<String> _roles = [
    'Administrador',
    'AdministradorDocumentos',
    'Usuario',
    'Supervisor',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final usuarioService = Provider.of<UsuarioService>(
        context,
        listen: false,
      );
      final apiService = Provider.of<ApiService>(context, listen: false);

      // Cargar usuarios y áreas en paralelo
      final usuariosFuture = usuarioService.getAll();
      final areasResponse = await apiService.get('/areas');
      final usuarios = await usuariosFuture;

      setState(() {
        _usuarios = usuarios;
        _areas =
            (areasResponse.data as List)
                .map((json) => Area.fromJson(json))
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Usuario> get _usuariosFiltrados {
    var filtered = _usuarios;

    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((usuario) {
            return usuario.nombreCompleto.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                usuario.nombreUsuario.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                usuario.email.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();
    }

    // Filtro por rol
    if (_selectedRolFilter != null) {
      filtered =
          filtered
              .where((usuario) => usuario.rol == _selectedRolFilter)
              .toList();
    }

    // Filtro por área
    if (_selectedAreaFilter != null) {
      final areaId = int.tryParse(_selectedAreaFilter!);
      if (areaId != null) {
        filtered =
            filtered.where((usuario) => usuario.areaId == areaId).toList();
      }
    }

    // Filtro por estado
    if (_selectedEstadoFilter != null) {
      filtered =
          filtered
              .where((usuario) => usuario.activo == _selectedEstadoFilter)
              .toList();
    }

    return filtered;
  }

  Future<void> _updateRol(Usuario usuario, String nuevoRol) async {
    try {
      final usuarioService = Provider.of<UsuarioService>(
        context,
        listen: false,
      );
      await usuarioService.updateRol(usuario.id, nuevoRol);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rol actualizado a $nuevoRol'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar rol: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleEstado(Usuario usuario) async {
    try {
      final usuarioService = Provider.of<UsuarioService>(
        context,
        listen: false,
      );
      await usuarioService.updateEstado(usuario.id, !usuario.activo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Usuario ${usuario.activo ? 'desactivado' : 'activado'}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRolDialog(Usuario usuario) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cambiar Rol - ${usuario.nombreCompleto}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  _roles.map((rol) {
                    return RadioListTile<String>(
                      title: Text(_getRolDisplayName(rol)),
                      value: rol,
                      groupValue: usuario.rol,
                      onChanged: (value) {
                        if (value != null) {
                          Navigator.pop(context);
                          _updateRol(usuario, value);
                        }
                      },
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
    );
  }

  String _getRolDisplayName(String rol) {
    switch (rol) {
      case 'Administrador':
        return 'Administrador del Sistema';
      case 'AdministradorDocumentos':
        return 'Administrador de Documentos';
      case 'Supervisor':
        return 'Supervisor';
      case 'Usuario':
        return 'Usuario';
      default:
        return rol;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildFilters(theme),
          const SizedBox(height: 24),
          Expanded(
            child:
                _isLoading
                    ? ListView.builder(
                      itemCount: 5,
                      itemBuilder:
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: LoadingShimmer(
                              width: double.infinity,
                              height: 100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                    )
                    : _usuariosFiltrados.isEmpty
                    ? const EmptyState(
                      icon: Icons.people_outline,
                      title: 'No se encontraron usuarios',
                      subtitle: 'Intenta ajustar los filtros de búsqueda',
                    )
                    : _buildUsersList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestión de Roles y Permisos',
          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Administre roles y permisos de usuarios del sistema.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return GlassContainer(
      blur: 10,
      opacity: theme.brightness == Brightness.dark ? 0.05 : 0.7,
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, usuario o email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
            const SizedBox(height: 16),
            // Filtros
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRolFilter,
                    decoration: InputDecoration(
                      labelText: 'Filtrar por Rol',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      ..._roles.map(
                        (rol) => DropdownMenuItem(
                          value: rol,
                          child: Text(_getRolDisplayName(rol)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedRolFilter = value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedAreaFilter,
                    decoration: InputDecoration(
                      labelText: 'Filtrar por Área',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todas')),
                      ..._areas.map(
                        (area) => DropdownMenuItem(
                          value: area.id.toString(),
                          child: Text(area.nombre),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedAreaFilter = value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<bool>(
                    value: _selectedEstadoFilter,
                    decoration: InputDecoration(
                      labelText: 'Filtrar por Estado',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todos')),
                      DropdownMenuItem(value: true, child: Text('Activos')),
                      DropdownMenuItem(value: false, child: Text('Inactivos')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedEstadoFilter = value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(ThemeData theme) {
    return ListView.builder(
      itemCount: _usuariosFiltrados.length,
      itemBuilder: (context, index) {
        final usuario = _usuariosFiltrados[index];
        return _buildUserCard(usuario, theme);
      },
    );
  }

  Widget _buildUserCard(Usuario usuario, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor:
              usuario.activo ? theme.colorScheme.primary : Colors.grey,
          child: Text(
            usuario.nombreCompleto[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          usuario.nombreCompleto,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Usuario: ${usuario.nombreUsuario}'),
            Text('Email: ${usuario.email}'),
            if (usuario.areaNombre != null) Text('Área: ${usuario.areaNombre}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge de rol
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRolColor(usuario.rol).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getRolColor(usuario.rol), width: 1),
              ),
              child: Text(
                _getRolDisplayName(usuario.rol),
                style: TextStyle(
                  color: _getRolColor(usuario.rol),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Botón para cambiar rol
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showRolDialog(usuario),
              tooltip: 'Cambiar rol',
            ),
            // Switch de estado
            Switch(
              value: usuario.activo,
              onChanged: (_) => _toggleEstado(usuario),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRolColor(String rol) {
    switch (rol) {
      case 'Administrador':
        return Colors.red;
      case 'AdministradorDocumentos':
        return Colors.orange;
      case 'Supervisor':
        return Colors.blue;
      case 'Usuario':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
