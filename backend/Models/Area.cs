using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SistemaGestionDocumental.Models;

[Table("areas")]
public class Area
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Required]
    [Column("nombre")]
    [StringLength(100)]
    public string Nombre { get; set; } = string.Empty;

    [Column("codigo")]
    [StringLength(20)]
    public string? Codigo { get; set; }

    [Column("descripcion")]
    [StringLength(300)]
    public string? Descripcion { get; set; }

    [Column("activo")]
    public bool Activo { get; set; } = true;

    // Relaciones
    public virtual ICollection<Documento> DocumentosOrigen { get; set; } = new List<Documento>();
    public virtual ICollection<Movimiento> MovimientosOrigen { get; set; } = new List<Movimiento>();
    public virtual ICollection<Movimiento> MovimientosDestino { get; set; } = new List<Movimiento>();
    public virtual ICollection<Usuario> Usuarios { get; set; } = new List<Usuario>();
}

