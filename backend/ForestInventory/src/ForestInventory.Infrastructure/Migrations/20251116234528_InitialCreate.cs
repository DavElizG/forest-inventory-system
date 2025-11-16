using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ForestInventory.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Especies",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    NombreComun = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    NombreCientifico = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Familia = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Descripcion = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    DensidadMadera = table.Column<double>(type: "double precision", nullable: true),
                    Activo = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    FechaCreacion = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Especies", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Usuarios",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    NombreCompleto = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Email = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    PasswordHash = table.Column<string>(type: "text", nullable: false),
                    Rol = table.Column<int>(type: "integer", nullable: false),
                    Activo = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    FechaCreacion = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UltimoAcceso = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    Telefono = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    Organizacion = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Usuarios", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Parcelas",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Codigo = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Nombre = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Latitud = table.Column<double>(type: "double precision", precision: 10, scale: 7, nullable: false),
                    Longitud = table.Column<double>(type: "double precision", precision: 10, scale: 7, nullable: false),
                    Altitud = table.Column<double>(type: "double precision", precision: 10, scale: 2, nullable: true),
                    Area = table.Column<double>(type: "double precision", precision: 10, scale: 4, nullable: false),
                    Descripcion = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    Ubicacion = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    FechaCreacion = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    FechaUltimaActualizacion = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    Activo = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    UsuarioCreadorId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Parcelas", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Parcelas_Usuarios_UsuarioCreadorId",
                        column: x => x.UsuarioCreadorId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "SyncLogs",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UsuarioId = table.Column<Guid>(type: "uuid", nullable: false),
                    Tipo = table.Column<int>(type: "integer", nullable: false),
                    FechaSincronizacion = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    RegistrosEnviados = table.Column<int>(type: "integer", nullable: false),
                    RegistrosRecibidos = table.Column<int>(type: "integer", nullable: false),
                    Exitoso = table.Column<bool>(type: "boolean", nullable: false),
                    MensajeError = table.Column<string>(type: "text", nullable: true),
                    Detalles = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SyncLogs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SyncLogs_Usuarios_UsuarioId",
                        column: x => x.UsuarioId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Arboles",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Codigo = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Latitud = table.Column<double>(type: "double precision", precision: 10, scale: 7, nullable: false),
                    Longitud = table.Column<double>(type: "double precision", precision: 10, scale: 7, nullable: false),
                    Altitud = table.Column<double>(type: "double precision", precision: 10, scale: 2, nullable: true),
                    Dap = table.Column<double>(type: "double precision", precision: 10, scale: 2, nullable: false),
                    Altura = table.Column<double>(type: "double precision", precision: 10, scale: 2, nullable: false),
                    AlturaComercial = table.Column<double>(type: "double precision", precision: 10, scale: 2, nullable: true),
                    DiametroCopa = table.Column<double>(type: "double precision", precision: 10, scale: 2, nullable: true),
                    Estado = table.Column<int>(type: "integer", nullable: false),
                    Observaciones = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    FechaMedicion = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    FechaCreacion = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    FechaUltimaActualizacion = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    Sincronizado = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    SyncId = table.Column<Guid>(type: "uuid", nullable: true),
                    ParcelaId = table.Column<Guid>(type: "uuid", nullable: false),
                    EspecieId = table.Column<Guid>(type: "uuid", nullable: false),
                    UsuarioCreadorId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Arboles", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Arboles_Especies_EspecieId",
                        column: x => x.EspecieId,
                        principalTable: "Especies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Arboles_Parcelas_ParcelaId",
                        column: x => x.ParcelaId,
                        principalTable: "Parcelas",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Arboles_Usuarios_UsuarioCreadorId",
                        column: x => x.UsuarioCreadorId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Arboles_EspecieId",
                table: "Arboles",
                column: "EspecieId");

            migrationBuilder.CreateIndex(
                name: "IX_Arboles_ParcelaId_Codigo",
                table: "Arboles",
                columns: new[] { "ParcelaId", "Codigo" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Arboles_UsuarioCreadorId",
                table: "Arboles",
                column: "UsuarioCreadorId");

            migrationBuilder.CreateIndex(
                name: "IX_Especies_NombreCientifico",
                table: "Especies",
                column: "NombreCientifico",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Parcelas_Codigo",
                table: "Parcelas",
                column: "Codigo",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Parcelas_UsuarioCreadorId",
                table: "Parcelas",
                column: "UsuarioCreadorId");

            migrationBuilder.CreateIndex(
                name: "IX_SyncLogs_UsuarioId",
                table: "SyncLogs",
                column: "UsuarioId");

            migrationBuilder.CreateIndex(
                name: "IX_Usuarios_Email",
                table: "Usuarios",
                column: "Email",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Arboles");

            migrationBuilder.DropTable(
                name: "SyncLogs");

            migrationBuilder.DropTable(
                name: "Especies");

            migrationBuilder.DropTable(
                name: "Parcelas");

            migrationBuilder.DropTable(
                name: "Usuarios");
        }
    }
}
