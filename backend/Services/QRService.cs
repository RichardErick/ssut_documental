using QRCoder;
using System.Drawing;
using System.Drawing.Imaging;

namespace SistemaGestionDocumental.Services;

public interface IQRService
{
    byte[] GenerarQR(string contenido);
    string GenerarQRBase64(string contenido);
}

public class QRService : IQRService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<QRService> _logger;

    public QRService(IConfiguration configuration, ILogger<QRService> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public byte[] GenerarQR(string contenido)
    {
        try
        {
            using var qrGenerator = new QRCodeGenerator();
            using var qrCodeData = qrGenerator.CreateQrCode(contenido, QRCodeGenerator.ECCLevel.Q);
            using var qrCode = new PngByteQRCode(qrCodeData);
            return qrCode.GetGraphic(20);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al generar código QR");
            throw;
        }
    }

    public string GenerarQRBase64(string contenido)
    {
        var qrBytes = GenerarQR(contenido);
        return Convert.ToBase64String(qrBytes);
    }
}
