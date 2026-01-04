using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SistemaGestionDocumental.Data;

namespace SistemaGestionDocumental.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsuariosController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public UsuariosController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult> GetAll()
    {
        var usuarios = await _context.Usuarios
            .Include(u => u.Area)
            .Select(u => new
            {
                u.Id,
                u.NombreUsuario,
                u.NombreCompleto,
                u.Email,
                u.Rol,
                u.AreaId,
                AreaNombre = u.Area != null ? u.Area.Nombre : null,
                u.Activo,
                u.UltimoAcceso,
                u.FechaRegistro,
                u.FechaActualizacion
            })
            .OrderBy(u => u.NombreCompleto)
            .ToListAsync();

        return Ok(usuarios);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult> GetById(int id)
    {
        var usuario = await _context.Usuarios
            .Include(u => u.Area)
            .Where(u => u.Id == id)
            .Select(u => new
            {
                u.Id,
                u.NombreUsuario,
                u.NombreCompleto,
                u.Email,
                u.Rol,
                u.AreaId,
                AreaNombre = u.Area != null ? u.Area.Nombre : null,
                u.Activo,
                u.UltimoAcceso,
                u.IntentosFallidos,
                u.BloqueadoHasta,
                u.FechaRegistro,
                u.FechaActualizacion
            })
            .FirstOrDefaultAsync();

        if (usuario == null)
            return NotFound();

        return Ok(usuario);
    }

    [HttpPut("{id}/rol")]
    public async Task<ActionResult> UpdateRol(int id, [FromBody] UpdateRolDTO dto)
    {
        var usuario = await _context.Usuarios.FindAsync(id);
        if (usuario == null)
            return NotFound();

        // Validar que el rol sea válido
        var rolesValidos = new[] { "Administrador", "AdministradorDocumentos", "Usuario", "Supervisor" };
        if (!rolesValidos.Contains(dto.Rol))
            return BadRequest(new { message = $"Rol inválido. Roles permitidos: {string.Join(", ", rolesValidos)}" });

        usuario.Rol = dto.Rol;
        usuario.FechaActualizacion = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(new
        {
            usuario.Id,
            usuario.NombreUsuario,
            usuario.NombreCompleto,
            usuario.Rol,
            usuario.FechaActualizacion
        });
    }

    [HttpPut("{id}/estado")]
    public async Task<ActionResult> UpdateEstado(int id, [FromBody] UpdateEstadoDTO dto)
    {
        var usuario = await _context.Usuarios.FindAsync(id);
        if (usuario == null)
            return NotFound();

        usuario.Activo = dto.Activo;
        usuario.FechaActualizacion = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(new
        {
            usuario.Id,
            usuario.NombreUsuario,
            usuario.NombreCompleto,
            usuario.Activo,
            usuario.FechaActualizacion
        });
    }

    [HttpPut("{id}")]
    public async Task<ActionResult> UpdateUsuario(int id, [FromBody] UpdateUsuarioDTO dto)
    {
        var usuario = await _context.Usuarios.FindAsync(id);
        if (usuario == null)
            return NotFound();

        if (!string.IsNullOrEmpty(dto.NombreCompleto))
            usuario.NombreCompleto = dto.NombreCompleto;

        if (!string.IsNullOrEmpty(dto.Email))
        {
            // Verificar que el email no esté en uso por otro usuario
            var emailExists = await _context.Usuarios
                .AnyAsync(u => u.Email == dto.Email && u.Id != id);
            if (emailExists)
                return BadRequest(new { message = "El email ya está en uso" });

            usuario.Email = dto.Email;
        }

        if (dto.Rol != null)
        {
            var rolesValidos = new[] { "Administrador", "AdministradorDocumentos", "Usuario", "Supervisor" };
            if (!rolesValidos.Contains(dto.Rol))
                return BadRequest(new { message = $"Rol inválido. Roles permitidos: {string.Join(", ", rolesValidos)}" });
            usuario.Rol = dto.Rol;
        }

        if (dto.AreaId.HasValue)
        {
            var areaExists = await _context.Areas.AnyAsync(a => a.Id == dto.AreaId.Value);
            if (!areaExists)
                return BadRequest(new { message = "El área especificada no existe" });
            usuario.AreaId = dto.AreaId.Value;
        }

        if (dto.Activo.HasValue)
            usuario.Activo = dto.Activo.Value;

        usuario.FechaActualizacion = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(new
        {
            usuario.Id,
            usuario.NombreUsuario,
            usuario.NombreCompleto,
            usuario.Email,
            usuario.Rol,
            usuario.AreaId,
            usuario.Activo,
            usuario.FechaActualizacion
        });
    }
}

public class UpdateRolDTO
{
    public string Rol { get; set; } = string.Empty;
}

public class UpdateEstadoDTO
{
    public bool Activo { get; set; }
}

public class UpdateUsuarioDTO
{
    public string? NombreCompleto { get; set; }
    public string? Email { get; set; }
    public string? Rol { get; set; }
    public int? AreaId { get; set; }
    public bool? Activo { get; set; }
}

