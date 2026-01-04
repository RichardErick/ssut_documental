using Microsoft.AspNetCore.Mvc;
using SistemaGestionDocumental.DTOs;
using SistemaGestionDocumental.Services;

namespace SistemaGestionDocumental.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DocumentosController : ControllerBase
{
    private readonly IDocumentoService _documentoService;

    public DocumentosController(IDocumentoService documentoService)
    {
        _documentoService = documentoService;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<DocumentoDTO>>> GetAll()
    {
        var documentos = await _documentoService.GetAllAsync();
        return Ok(documentos);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<DocumentoDTO>> GetById(int id)
    {
        var documento = await _documentoService.GetByIdAsync(id);
        if (documento == null)
            return NotFound();

        return Ok(documento);
    }

    [HttpGet("codigo/{codigo}")]
    public async Task<ActionResult<DocumentoDTO>> GetByCodigo(string codigo)
    {
        var documento = await _documentoService.GetByCodigoAsync(codigo);
        if (documento == null)
            return NotFound();

        return Ok(documento);
    }

    [HttpGet("qr/{codigoQR}")]
    public async Task<ActionResult<DocumentoDTO>> GetByQRCode(string codigoQR)
    {
        var documento = await _documentoService.GetByQRCodeAsync(codigoQR);
        if (documento == null)
            return NotFound();

        return Ok(documento);
    }

    [HttpPost("buscar")]
    public async Task<ActionResult<IEnumerable<DocumentoDTO>>> Buscar([FromBody] BusquedaDocumentoDTO busqueda)
    {
        var documentos = await _documentoService.BuscarAsync(busqueda);
        return Ok(documentos);
    }

    [HttpPost]
    public async Task<ActionResult<DocumentoDTO>> Create([FromBody] CreateDocumentoDTO dto)
    {
        try
        {
            var documento = await _documentoService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = documento.Id }, documento);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<DocumentoDTO>> Update(int id, [FromBody] UpdateDocumentoDTO dto)
    {
        var documento = await _documentoService.UpdateAsync(id, dto);
        if (documento == null)
            return NotFound();

        return Ok(documento);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _documentoService.DeleteAsync(id);
        if (!result)
            return NotFound();

        return NoContent();
    }
    
    /// <summary>
    /// Obtiene el historial completo de movimientos de un documento
    /// </summary>
    /// <param name="id">ID del documento</param>
    /// <returns>Lista de movimientos del documento ordenados por fecha descendente</returns>
    [HttpGet("{id}/historial")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IEnumerable<MovimientoDTO>))]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<IEnumerable<MovimientoDTO>>> GetHistorial(int id)
    {
        try
        {
            var historial = await _documentoService.GetDocumentoHistorialAsync(id);
            return Ok(historial);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }
}

