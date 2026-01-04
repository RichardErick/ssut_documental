namespace SistemaGestionDocumental.DTOs;

public class DocumentoDTO
{
    public int Id { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public string NumeroCorrelativo { get; set; } = string.Empty;
    public int TipoDocumentoId { get; set; }
    public string? TipoDocumentoNombre { get; set; }
    public int AreaOrigenId { get; set; }
    public string? AreaOrigenNombre { get; set; }
    public string Gestion { get; set; } = string.Empty;
    public DateTime FechaDocumento { get; set; }
    public string? Descripcion { get; set; }
    public int? ResponsableId { get; set; }
    public string? ResponsableNombre { get; set; }
    public string? CodigoQR { get; set; }
    public string? UbicacionFisica { get; set; }
    public string Estado { get; set; } = string.Empty;
    public DateTime FechaRegistro { get; set; }
}

public class CreateDocumentoDTO
{
    public string NumeroCorrelativo { get; set; } = string.Empty;
    public int TipoDocumentoId { get; set; }
    public int AreaOrigenId { get; set; }
    public string Gestion { get; set; } = string.Empty;
    public DateTime FechaDocumento { get; set; }
    public string? Descripcion { get; set; }
    public int? ResponsableId { get; set; }
    public string? UbicacionFisica { get; set; }
}

public class UpdateDocumentoDTO
{
    public string? Descripcion { get; set; }
    public int? ResponsableId { get; set; }
    public string? UbicacionFisica { get; set; }
    public string? Estado { get; set; }
}

public class BusquedaDocumentoDTO
{
    public string? Codigo { get; set; }
    public string? NumeroCorrelativo { get; set; }
    public int? TipoDocumentoId { get; set; }
    public int? AreaOrigenId { get; set; }
    public string? Gestion { get; set; }
    public DateTime? FechaDesde { get; set; }
    public DateTime? FechaHasta { get; set; }
    public string? Estado { get; set; }
    public string? CodigoQR { get; set; }
}

