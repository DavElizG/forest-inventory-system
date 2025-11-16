namespace ForestInventory.Application.Common;

public static class Constants
{
    public static class Roles
    {
        public const string Administrador = "Administrador";
        public const string Supervisor = "Supervisor";
        public const string TecnicoForestal = "TecnicoForestal";
        public const string Consultor = "Consultor";
    }

    public static class Pagination
    {
        public const int DefaultPageSize = 20;
        public const int MaxPageSize = 100;
    }

    public static class FileExport
    {
        public const string ExcelContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        public const string KmzContentType = "application/vnd.google-earth.kmz";
        public const string PdfContentType = "application/pdf";
    }

    public static class Validation
    {
        public const int MinDap = 1; // cm
        public const int MaxDap = 500; // cm
        public const int MinAltura = 1; // m
        public const int MaxAltura = 100; // m
        public const int MinAreaParcela = 1; // hectáreas
        public const int MaxAreaParcela = 10000; // hectáreas
    }
}
