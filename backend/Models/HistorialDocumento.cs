using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SistemaGestionDocumental.Models;

[Table("historial_documento")]
public class HistorialDocumento
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Column("uuid")]
    public Guid Uuid { get; set; } = Guid.NewGuid();

    [Required]
    [Column("documento_id")]
    public int DocumentoId { get; set; }

    [ForeignKey("DocumentoId")]
    public virtual Documento? Documento { get; set; }

    [Column("fecha_cambio")]
    public DateTime FechaCambio { get; set; } = DateTime.UtcNow;

    [Column("usuario_id")]
    public int? UsuarioId { get; set; }

    [ForeignKey("UsuarioId")]
    public virtual Usuario? Usuario { get; set; }

    [Required]
    [Column("tipo_cambio")]
    [StringLength(50)]
    public string TipoCambio { get; set; } = string.Empty;

    [Column("estado_anterior")]
    public string? EstadoAnterior { get; set; }

    [Column("estado_nuevo")]
    public string? EstadoNuevo { get; set; }

    [Column("area_anterior_id")]
    public int? AreaAnteriorId { get; set; }

    [ForeignKey("AreaAnteriorId")]
    public virtual Area? AreaAnterior { get; set; }

    [Column("area_nueva_id")]
    public int? AreaNuevaId { get; set; }

    [ForeignKey("AreaNuevaId")]
    public virtual Area? AreaNueva { get; set; }

    [Column("campo_modificado")]
    [StringLength(100)]
    public string? CampoModificado { get; set; }

    [Column("valor_anterior")]
    public string? ValorAnterior { get; set; }

    [Column("valor_nuevo")]
    public string? ValorNuevo { get; set; }

    [Column("observacion")]
    public string? Observacion { get; set; }
}
