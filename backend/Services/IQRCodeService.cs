namespace SistemaGestionDocumental.Services;

public interface IQRCodeService
{
    Task<string> GenerarCodigoQRAsync(string codigoDocumento);
    Task<byte[]?> GenerarImagenQRAsync(string codigoDocumento);
}

