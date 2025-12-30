using System;
using System.IO;
using Npgsql;

namespace ForestInventory.Migrations
{
    /// <summary>
    /// Herramienta para aplicar la migración de especies a la base de datos
    /// Uso: dotnet run --project ApplyMigration.csproj
    /// </summary>
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("=== Aplicando Migración de Especies ===\n");

            // Solicitar cadena de conexión
            string connectionString = GetConnectionString();

            if (string.IsNullOrWhiteSpace(connectionString))
            {
                Console.WriteLine("❌ Error: Cadena de conexión vacía");
                return;
            }

            try
            {
                // Leer archivo SQL
                string sqlFilePath = Path.Combine(Directory.GetCurrentDirectory(), "especies_costa_rica.sql");
                
                if (!File.Exists(sqlFilePath))
                {
                    Console.WriteLine($"❌ Error: No se encontró el archivo {sqlFilePath}");
                    return;
                }

                string sqlScript = File.ReadAllText(sqlFilePath);
                Console.WriteLine($"✓ Archivo SQL cargado: {sqlFilePath}");

                // Conectar a la base de datos
                using var connection = new NpgsqlConnection(connectionString);
                connection.Open();
                Console.WriteLine("✓ Conexión establecida con la base de datos");

                // Ejecutar script SQL
                using var command = new NpgsqlCommand(sqlScript, connection);
                command.ExecuteNonQuery();
                Console.WriteLine("✓ Script SQL ejecutado exitosamente");

                // Verificar especies insertadas
                using var verifyCommand = new NpgsqlCommand(
                    "SELECT COUNT(*) FROM \"Especies\" WHERE \"Activo\" = true", 
                    connection);
                
                var count = verifyCommand.ExecuteScalar();
                Console.WriteLine($"\n✓ Total de especies activas en la base de datos: {count}");

                Console.WriteLine("\n=== Migración completada exitosamente ===");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"\n❌ Error al aplicar la migración:");
                Console.WriteLine(ex.Message);
                if (ex.InnerException != null)
                {
                    Console.WriteLine($"Detalles: {ex.InnerException.Message}");
                }
            }
        }

        static string GetConnectionString()
        {
            Console.WriteLine("Ingresa la cadena de conexión a PostgreSQL:");
            Console.WriteLine("Ejemplo: Host=localhost;Port=5432;Database=forestdb;Username=forestuser;Password=forestpass");
            Console.WriteLine("\nO presiona Enter para usar la configuración por defecto de docker-compose:");
            Console.Write("> ");

            string input = Console.ReadLine()?.Trim();

            if (string.IsNullOrWhiteSpace(input))
            {
                // Cadena por defecto del docker-compose
                return "Host=localhost;Port=5432;Database=forestdb;Username=forestuser;Password=forestpass";
            }

            return input;
        }
    }
}
