using Microsoft.AspNetCore.Mvc;
using SistemaGestionDocumental.Services;

namespace SistemaGestionDocumental.Controllers;

[ApiController]
[Route("api/[controller]")]
public class QRCodeController : ControllerBase
{
    private readonly IQRCodeService _qrCodeService;

    public QRCodeController(IQRCodeService qrCodeService)
    {
        _qrCodeService = qrCodeService;
    }

    [HttpGet("imagen/{codigoDocumento}")]
    public async Task<IActionResult> GenerarImagenQR(string codigoDocumento)
    {
        var imagen = await _qrCodeService.GenerarImagenQRAsync(codigoDocumento);
        if (imagen == null)
            return BadRequest(new { message = "Error al generar código QR" });

        return File(imagen, "image/png");
    }
}

