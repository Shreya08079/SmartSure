using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartSure.Identity.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class RemoveCountryColumnFromUsers : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Guard: only drop if the column exists (handles fresh DB installs)
            migrationBuilder.Sql(@"
                IF EXISTS (
                    SELECT 1 FROM sys.columns 
                    WHERE object_id = OBJECT_ID(N'[Users]') AND name = 'Country'
                )
                BEGIN
                    ALTER TABLE [Users] DROP COLUMN [Country];
                END
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Country",
                table: "Users",
                type: "nvarchar(max)",
                nullable: true);
        }
    }
}