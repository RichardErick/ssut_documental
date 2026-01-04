using SistemaGestionDocumental.DTOs;
using SistemaGestionDocumental.Models;

namespace SistemaGestionDocumental.Services;

public interface IDocumentoService
{
    Task<IEnumerable<DocumentoDTO>> GetAllAsync();
    Task<DocumentoDTO?> GetByIdAsync(int id);
    Task<DocumentoDTO?> GetByCodigoAsync(string codigo);
    Task<DocumentoDTO?> GetByQRCodeAsync(string codigoQR);
    Task<IEnumerable<DocumentoDTO>> BuscarAsync(BusquedaDocumentoDTO busqueda);
    Task<DocumentoDTO> CreateAsync(CreateDocumentoDTO dto);
    Task<DocumentoDTO?> UpdateAsync(int id, UpdateDocumentoDTO dto);
    Task<bool> DeleteAsync(int id);
    
    /// <summary>
    /// Obtiene el historial completo de movimientos de un documento
    /// </summary>
    /// <param name="documentoId">ID del documento</param>
    /// <returns>Lista de movimientos del documento ordenados por fecha descendente</returns>
    Task<IEnumerable<MovimientoDTO>> GetDocumentoHistorialAsync(int documentoId);
}
