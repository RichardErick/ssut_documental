using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SistemaGestionDocumental.Models;

[Table("configuracion")]
public class Configuracion
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Required]
    [Column("clave")]
    [StringLength(100)]
    public string Clave { get; set; } = string.Empty;

    [Column("valor")]
    public string? Valor { get; set; }

    [Column("descripcion")]
    public string? Descripcion { get; set; }

    [Column("tipo_dato")]
    [StringLength(20)]
    public string TipoDato { get; set; } = "string";

    [Column("editable")]
    public bool Editable { get; set; } = true;

    [Column("fecha_actualizacion")]
    public DateTime FechaActualizacion { get; set; } = DateTime.UtcNow;

    [Column("actualizado_por")]
    public int? ActualizadoPor { get; set; }

    [ForeignKey("ActualizadoPor")]
    public virtual Usuario? ActualizadoPorUsuario { get; set; }
}
