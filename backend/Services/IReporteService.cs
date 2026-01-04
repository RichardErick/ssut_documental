using SistemaGestionDocumental.DTOs;

namespace SistemaGestionDocumental.Services;

public interface IReporteService
{
    Task<IEnumerable<MovimientoDTO>> GenerarReporteMovimientosAsync(ReporteMovimientosDTO filtros);
    Task<IEnumerable<DocumentoDTO>> GenerarReporteDocumentosAsync(ReporteDocumentosDTO filtros);
    Task<EstadisticaDocumentoDTO> ObtenerEstadisticasAsync();
}

