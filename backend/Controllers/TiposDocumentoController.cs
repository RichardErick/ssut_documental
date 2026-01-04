using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SistemaGestionDocumental.Data;

namespace SistemaGestionDocumental.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TiposDocumentoController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public TiposDocumentoController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult> GetAll()
    {
        var tipos = await _context.TiposDocumento
            .Where(t => t.Activo)
            .Select(t => new
            {
                t.Id,
                t.Nombre,
                t.Codigo,
                t.Descripcion
            })
            .ToListAsync();

        return Ok(tipos);
    }
}

