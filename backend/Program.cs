using Microsoft.EntityFrameworkCore;
using SistemaGestionDocumental.Data;
using SistemaGestionDocumental.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterApp",
        policy =>
        {
            policy.WithOrigins("http://localhost:3000", "http://localhost:8080")
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        });
});

// Configure PostgreSQL Database
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Host=localhost;Database=ssut_gestion_documental;Username=postgres;Password=postgres";

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(connectionString));

// Register services
builder.Services.AddScoped<IDocumentoService, DocumentoService>();
builder.Services.AddScoped<IMovimientoService, MovimientoService>();
builder.Services.AddScoped<IQRCodeService, QRCodeService>();
builder.Services.AddScoped<IReporteService, ReporteService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowFlutterApp");
app.UseAuthorization();
app.MapControllers();

// Ensure database connection and schema
using (var scope = app.Services.CreateScope())
{
    // AQUI SE DEFINE LOS SERVICIOS QUE SE VA A USAR EN LA APLICACION
    try
    {
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
        
        // Verificar conexión
        if (db.Database.CanConnect())
        {
            logger.LogInformation("Conexión a la base de datos exitosa");
            // Si la base de datos ya existe, no intentamos crearla
            // Usa migraciones para actualizar el esquema si es necesario
        }
        //aqui no deberia entrar nunca
        else
        {
            logger.LogWarning("No se puede conectar a la base de datos. Asegúrate de que PostgreSQL esté ejecutándose y la base de datos exista.");
        }
    }
    //aqui no deberia entrar nunca
    catch (Exception ex)
    {
        var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "Error al verificar la conexión a la base de datos");
        // No lanzamos la excepción para que la aplicación pueda iniciar
        // La base de datos debe ser creada manualmente usando los scripts SQL
        // la bd es creado manaulmentre usando los scripts sql en la carpeta database
    }
}
//AQUI SE EJECUTA LA APLICACION EN EL PUERTO 7000
app.Run();

