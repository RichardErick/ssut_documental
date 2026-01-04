using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SistemaGestionDocumental.Models;

[Table("tipos_documento")]
public class TipoDocumento
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

    // Relación con documentos
    public virtual ICollection<Documento> Documentos { get; set; } = new List<Documento>();
}

