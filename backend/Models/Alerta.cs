using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SistemaGestionDocumental.Models;

[Table("alertas")]
public class Alerta
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Column("uuid")]
    public Guid Uuid { get; set; } = Guid.NewGuid();

    [Column("usuario_id")]
    public int? UsuarioId { get; set; }

    [ForeignKey("UsuarioId")]
    public virtual Usuario? Usuario { get; set; }

    [Required]
    [Column("titulo")]
    [StringLength(200)]
    public string Titulo { get; set; } = string.Empty;

    [Required]
    [Column("mensaje")]
    public string Mensaje { get; set; } = string.Empty;

    [Column("tipo_alerta")]
    [StringLength(20)]
    public string TipoAlerta { get; set; } = "info";

    [Column("leida")]
    public bool Leida { get; set; } = false;

    [Column("fecha_creacion")]
    public DateTime FechaCreacion { get; set; } = DateTime.UtcNow;

    [Column("fecha_lectura")]
    public DateTime? FechaLectura { get; set; }

    [Column("documento_id")]
    public int? DocumentoId { get; set; }

    [ForeignKey("DocumentoId")]
    public virtual Documento? Documento { get; set; }

    [Column("movimiento_id")]
    public int? MovimientoId { get; set; }

    [ForeignKey("MovimientoId")]
    public virtual Movimiento? Movimiento { get; set; }
}
