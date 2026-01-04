using SistemaGestionDocumental.DTOs;

namespace SistemaGestionDocumental.Services;

public interface IMovimientoService
{
    Task<IEnumerable<MovimientoDTO>> GetAllAsync();
    Task<MovimientoDTO?> GetByIdAsync(int id);
    Task<IEnumerable<MovimientoDTO>> GetByDocumentoIdAsync(int documentoId);
    Task<IEnumerable<MovimientoDTO>> GetMovimientosPorFechaAsync(DateTime fechaDesde, DateTime fechaHasta);
    Task<MovimientoDTO> CreateAsync(CreateMovimientoDTO dto);
    Task<MovimientoDTO?> DevolverDocumentoAsync(DevolverDocumentoDTO dto);
}

