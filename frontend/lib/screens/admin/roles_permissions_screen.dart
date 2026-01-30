import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/user_role.dart';
import '../../models/usuario.dart';
import '../../providers/auth_provider.dart';
import '../../services/usuario_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_helper.dart';

class RolesPermissionsScreen extends StatefulWidget {
  const RolesPermissionsScreen({super.key});

  @override
  State<RolesPermissionsScreen> createState() => _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState extends State<RolesPermissionsScreen> {
  List<Usuario> _usuarios = [];
  List<Usuario> _usuariosFiltrados = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // Roles disponibles
  final List<String> _roles = [
    'AdministradorSistema',
    'AdministradorDocumentos', 
    'Contador',
    'Gerente',
  ];

  // Permisos por rol según la matriz definida
  final Map<String, List<String>> _permisosPorRol = {
    'AdministradorSistema': ['Ver Documento'],
    'AdministradorDocumentos': [
      'Ver Documento',
      'Crear Documento', 
      'Subir Documento',
      'Editar Metadatos',
      'Borrar Documento',
      'Crear Carpeta',
      'Borrar Carpeta'
    ],
    'Contador': [
      'Ver Documento',
      'Crear Documento',
      'Subir Documento'
    ],
    'Gerente': ['Ver Documento'],
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filtrarUsuarios);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarUsuarios() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _usuariosFiltrados = _usuarios.where((usuario) {
        return usuario.nombreCompleto.toLowerCase().contains(query) ||
               usuario.nombreUsuario.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final usuarioService = Provider.of<UsuarioService>(context, listen: false);
      final usuarios = await usuarioService.getAll();
      
      if (mounted) {
        setState(() {
          _usuarios = usuarios.where((u) => u.activo).toList();
          _usuariosFiltrados = List.from(_usuarios);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando usuarios: ${ErrorHelper.getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cambiarRol(Usuario usuario, String nuevoRol) async {
    try {
      final usuarioService = Provider.of<UsuarioService>(context, listen: false);
      await usuarioService.updateRol(usuario.id, nuevoRol);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rol actualizado a ${_getRolDisplayName(nuevoRol)}'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar rol: ${ErrorHelper.getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarDialogoRol(Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getRolColor(usuario.rol).withOpacity(0.2),
              child: Icon(_getRolIcon(usuario.rol), color: _getRolColor(usuario.rol)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(usuario.nombreCompleto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Cambiar rol', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _roles.map((rol) {
            final isSelected = usuario.rol == rol;
            return InkWell(
              onTap: () {
                if (!isSelected) {
                  Navigator.pop(context);
                  _cambiarRol(usuario, rol);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? _getRolColor(rol).withOpacity(0.1) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? _getRolColor(rol) : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(_getRolIcon(rol), color: _getRolColor(rol), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getRolDisplayName(rol),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? _getRolColor(rol) : null,
                        ),
                      ),
                    ),
                    if (isSelected) Icon(Icons.check_circle, color: _getRolColor(rol), size: 20),
                  ],
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Solo el administrador de sistema puede gestionar roles
    if (!authProvider.canManageUserPermissions) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Gestión de Roles', style: GoogleFonts.poppins()),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No tienes permisos para acceder a esta sección', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Text('Rol actual: ${authProvider.role.displayName}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Gestión de Roles y Permisos', style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar datos',
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header con estadísticas
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen del Sistema',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildEstadisticas(),
                      const SizedBox(height: 16),
                      // Buscador
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar usuario...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista de usuarios
                Expanded(
                  child: _usuariosFiltrados.isEmpty
                      ? const Center(
                          child: Text('No se encontraron usuarios', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _usuariosFiltrados.length,
                          itemBuilder: (context, index) {
                            final usuario = _usuariosFiltrados[index];
                            return _buildUsuarioCard(usuario);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEstadisticas() {
    final stats = <String, int>{};
    for (final rol in _roles) {
      stats[rol] = _usuarios.where((u) => u.rol == rol).length;
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: stats.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getRolColor(entry.key).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getRolColor(entry.key).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getRolIcon(entry.key), color: _getRolColor(entry.key), size: 16),
              const SizedBox(width: 8),
              Text(
                '${_getRolDisplayName(entry.key)}: ${entry.value}',
                style: TextStyle(
                  color: _getRolColor(entry.key),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUsuarioCard(Usuario usuario) {
    final permisos = _permisosPorRol[usuario.rol] ?? [];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del usuario
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getRolColor(usuario.rol),
                  child: Text(
                    usuario.nombreCompleto.isNotEmpty ? usuario.nombreCompleto[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario.nombreCompleto,
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '@${usuario.nombreUsuario}',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                // Botón cambiar rol
                ElevatedButton.icon(
                  onPressed: () => _mostrarDialogoRol(usuario),
                  icon: Icon(_getRolIcon(usuario.rol), size: 16),
                  label: Text(_getRolDisplayName(usuario.rol)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getRolColor(usuario.rol).withOpacity(0.1),
                    foregroundColor: _getRolColor(usuario.rol),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Permisos del rol
            Text(
              'Permisos del Rol:',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: permisos.map((permiso) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    permiso,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getRolDisplayName(String rol) {
    switch (rol) {
      case 'AdministradorSistema':
        return 'Admin Sistema';
      case 'AdministradorDocumentos':
        return 'Admin Documentos';
      case 'Contador':
        return 'Contador';
      case 'Gerente':
        return 'Gerente';
      default:
        return rol;
    }
  }

  IconData _getRolIcon(String rol) {
    switch (rol) {
      case 'AdministradorSistema':
        return Icons.security;
      case 'AdministradorDocumentos':
        return Icons.folder_shared;
      case 'Contador':
        return Icons.account_balance;
      case 'Gerente':
        return Icons.business_center;
      default:
        return Icons.person;
    }
  }

  Color _getRolColor(String rol) {
    switch (rol) {
      case 'AdministradorSistema':
        return Colors.red;
      case 'AdministradorDocumentos':
        return Colors.blue;
      case 'Contador':
        return Colors.green;
      case 'Gerente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
},
                  ),
                ),
                if (_hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_alt_off),
                    onPressed: _clearFilters,
                    tooltip: 'Limpiar filtros',
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: isDesktop ? 250 : double.infinity,
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
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todos los roles'),
                      ),
                      ..._roles.map(
                        (rol) => DropdownMenuItem(
                          value: rol,
                          child: Row(
                            children: [
                              Icon(
                                _getRolIcon(rol),
                                size: 18,
                                color: _getRolColor(rol),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getRolDisplayName(rol),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).toList(),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedRolFilter = value);
                    },
                  ),
                ),
                SizedBox(
                  width: isDesktop ? 250 : double.infinity,
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
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todas las áreas'),
                      ),
                      ..._areas.map(
                        (area) => DropdownMenuItem(
                          value: area.id.toString(),
                          child: Text(
                            area.nombre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedAreaFilter = value);
                    },
                  ),
                ),
                SizedBox(
                  width: isDesktop ? 200 : double.infinity,
                  child: DropdownButtonFormField<bool>(
                    value: _selectedEstadoFilter,
                    decoration: InputDecoration(
                      labelText: 'Estado',
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
            if (_usuariosFiltrados.length != _usuarios.length) ...[
              const SizedBox(height: 12),
              Text(
                'Mostrando ${_usuariosFiltrados.length} de ${_usuarios.length} usuarios',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsersSection(ThemeData theme, bool isDesktop) {
    if (_isLoading) {
      return Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LoadingShimmer(
              width: double.infinity,
              height: 120,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    if (_usuariosFiltrados.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        title: 'No se encontraron usuarios',
        subtitle: 'Intenta ajustar los filtros de búsqueda',
      );
    }

    if (_isGridView) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isDesktop ? 1.0 : 0.85, 
        ),
        itemCount: _usuariosFiltrados.length,
        itemBuilder: (context, index) {
          return _buildUserCardGrid(_usuariosFiltrados[index], theme);
        },
      );
    }

    return Column(
      children:
          _usuariosFiltrados.asMap().entries.map((entry) {
            return AnimatedCard(
              delay: Duration(milliseconds: entry.key * 50),
              margin: const EdgeInsets.only(bottom: 12),
              child: _buildUserCard(entry.value, theme, isDesktop),
            );
          }).toList(),
    );
  }

  Widget _buildUserCard(Usuario usuario, ThemeData theme, bool isDesktop) {
    return ListTile(
      contentPadding: EdgeInsets.all(isDesktop ? 20 : 16),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: isDesktop ? 30 : 24,
            backgroundColor:
                usuario.activo ? theme.colorScheme.primary : Colors.grey,
            child: Text(
              usuario.nombreCompleto[0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 20 : 16,
              ),
            ),
          ),
          if (!usuario.activo)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.block, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              usuario.nombreCompleto,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getRolColor(usuario.rol).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getRolColor(usuario.rol), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getRolIcon(usuario.rol),
                  size: 14,
                  color: _getRolColor(usuario.rol),
                ),
                const SizedBox(width: 6),
                Text(
                  _getRolDisplayName(usuario.rol),
                  style: TextStyle(
                    color: _getRolColor(usuario.rol),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.person_outline, usuario.nombreUsuario),
            const SizedBox(height: 4),
            _buildInfoRow(Icons.email_outlined, usuario.email),
            if (usuario.areaNombre != null) ...[
              const SizedBox(height: 4),
              _buildInfoRow(Icons.business_outlined, usuario.areaNombre!),
            ],
            if (usuario.ultimoAcceso != null) ...[
              const SizedBox(height: 4),
              _buildInfoRow(
                Icons.access_time,
                'Último acceso: ${DateFormat('dd/MM/yyyy HH:mm').format(usuario.ultimoAcceso!)}',
              ),
            ],
          ],
        ),
      ),
      trailing:
          isDesktop
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showRolDialog(usuario),
                    tooltip: 'Cambiar rol',
                    color: theme.colorScheme.primary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDeleteUsuario(usuario),
                    tooltip: 'Eliminar',
                    color: theme.colorScheme.error,
                  ),
                  Switch(
                    value: usuario.activo,
                    onChanged: (_) => _toggleEstado(usuario),
                  ),
                ],
              )
              : PopupMenuButton(
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Cambiar rol'),
                          ],
                        ),
                        onTap:
                            () => Future.delayed(
                              const Duration(milliseconds: 100),
                              () => _showRolDialog(usuario),
                            ),
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              usuario.activo ? Icons.block : Icons.check_circle,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(usuario.activo ? 'Desactivar' : 'Activar'),
                          ],
                        ),
                        onTap:
                            () => Future.delayed(
                              const Duration(milliseconds: 100),
                              () => _toggleEstado(usuario),
                            ),
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Eliminar'),
                          ],
                        ),
                        onTap:
                            () => Future.delayed(
                              const Duration(milliseconds: 100),
                              () => _confirmDeleteUsuario(usuario),
                            ),
                      ),
                    ],
              ),
    );
  }

  Widget _buildUserCardGrid(Usuario usuario, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showRolDialog(usuario),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor:
                        usuario.activo
                            ? theme.colorScheme.primary
                            : Colors.grey,
                    child: Text(
                      usuario.nombreCompleto[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  if (!usuario.activo)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.block,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                usuario.nombreCompleto,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRolColor(usuario.rol).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getRolDisplayName(usuario.rol),
                  style: TextStyle(
                    color: _getRolColor(usuario.rol),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _showRolDialog(usuario),
                    tooltip: 'Cambiar rol',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => _confirmDeleteUsuario(usuario),
                    tooltip: 'Eliminar',
                  ),
                  Switch(
                    value: usuario.activo,
                    onChanged: (_) => _toggleEstado(usuario),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
