using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ForestInventory.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddNumeroArbolToArboles : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "NumeroArbol",
                table: "Arboles",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "NumeroArbol",
                table: "Arboles");
        }
    }
}
