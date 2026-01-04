using Microsoft.AspNetCore.Mvc;
using SistemaGestionDocumental.DTOs;
using SistemaGestionDocumental.Services;

namespace SistemaGestionDocumental.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ReportesController : ControllerBase
{
    private readonly IReporteService _reporteService;

    public ReportesController(IReporteService reporteService)
    {
        _reporteService = reporteService;
    }

    [HttpPost("movimientos")]
    public async Task<ActionResult<IEnumerable<MovimientoDTO>>> ReporteMovimientos([FromBody] ReporteMovimientosDTO filtros)
    {
        var movimientos = await _reporteService.GenerarReporteMovimientosAsync(filtros);
        return Ok(movimientos);
    }

    [HttpPost("documentos")]
    public async Task<ActionResult<IEnumerable<DocumentoDTO>>> ReporteDocumentos([FromBody] ReporteDocumentosDTO filtros)
    {
        var documentos = await _reporteService.GenerarReporteDocumentosAsync(filtros);
        return Ok(documentos);
    }

    [HttpGet("estadisticas")]
    public async Task<ActionResult<EstadisticaDocumentoDTO>> Estadisticas()
    {
        var estadisticas = await _reporteService.ObtenerEstadisticasAsync();
        return Ok(estadisticas);
    }
}

