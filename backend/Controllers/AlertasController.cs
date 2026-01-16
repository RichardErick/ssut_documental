using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SistemaGestionDocumental.Data;
using SistemaGestionDocumental.Models;
using System.Security.Claims;

namespace SistemaGestionDocumental.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class AlertasController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public AlertasController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Alerta>>> GetMisAlertas()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub"));

        var alertas = await _context.Alertas
            .Where(a => a.UsuarioId == userId)
            .OrderByDescending(a => a.FechaCreacion)
            .Take(50)
            .ToListAsync();

        return Ok(alertas);
    }

    [HttpGet("unread-count")]
    public async Task<ActionResult<int>> GetUnreadCount()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub"));

        var count = await _context.Alertas
            .Where(a => a.UsuarioId == userId && !a.Leida)
            .CountAsync();

        return Ok(new { count });
    }

    [HttpPut("{id}/leida")]
    public async Task<IActionResult> MarcarComoLeida(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub"));

        var alerta = await _context.Alertas.FindAsync(id);

        if (alerta == null)
            return NotFound();

        if (alerta.UsuarioId != userId)
            return Forbid();

        alerta.Leida = true;
        alerta.FechaLectura = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return NoContent();
    }
    
    [HttpDelete("{id}")]
    public async Task<IActionResult> EliminarAlerta(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub"));
        var alerta = await _context.Alertas.FindAsync(id);

        if (alerta == null) return NotFound();
        if (alerta.UsuarioId != userId) return Forbid();

        _context.Alertas.Remove(alerta);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
