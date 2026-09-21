// lib/domain/open_state_exception.dart
// Erreur « métier » (état de l'open, règle du tournoi violée).
// Le message est en français et destiné à être affiché tel quel par l'UI.

class OpenStateException implements Exception {
  final String message;
  const OpenStateException(this.message);

  @override
  String toString() => message;
}
