using QRCoder;

namespace SistemaGestionDocumental.Services;

public class QRCodeService : IQRCodeService
{
    public async Task<string> GenerarCodigoQRAsync(string codigoDocumento)
    {
        // Generar un código único basado en el código del documento
        var qrCode = $"DOC-{codigoDocumento}-{DateTime.Now:yyyyMMddHHmmss}";
        return await Task.FromResult(qrCode);
    }

    public async Task<byte[]?> GenerarImagenQRAsync(string codigoDocumento)
    {
        return await Task.Run(() =>
        {
            try
            {
                using var qrGenerator = new QRCodeGenerator();
                var qrCodeData = qrGenerator.CreateQrCode(codigoDocumento, QRCodeGenerator.ECCLevel.Q);
                using var qrCode = new PngByteQRCode(qrCodeData);
                return qrCode.GetGraphic(20);
            }
            catch
            {
                return null;
            }
        });
    }
}

