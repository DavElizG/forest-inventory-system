/// Resultado de una operación de sincronización
class SyncResult {
  final bool success;
  final String message;
  final int synced;
  final int failed;

  SyncResult({
    required this.success,
    required this.message,
    required this.synced,
    required this.failed,
  });
}
