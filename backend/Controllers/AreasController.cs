using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SistemaGestionDocumental.Data;

namespace SistemaGestionDocumental.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AreasController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public AreasController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult> GetAll()
    {
        var areas = await _context.Areas
            .Where(a => a.Activo)
            .Select(a => new
            {
                a.Id,
                a.Nombre,
                a.Codigo,
                a.Descripcion
            })
            .ToListAsync();

        return Ok(areas);
    }
}

