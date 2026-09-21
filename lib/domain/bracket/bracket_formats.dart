// lib/domain/bracket/bracket_formats.dart
// Registre des formats disponibles. Seule la double élimination est
// implémentée pour l'instant ; élimination simple et poules + phase finale
// viendront ici sans toucher au repository.

import '../open.dart';
import '../open_state_exception.dart';
import 'bracket_format.dart';
import 'double_elimination.dart';

abstract final class BracketFormats {
  static BracketFormat byId(String id) {
    switch (id) {
      case OpenFormat.doubleElim:
        return const DoubleEliminationFormat();
      default:
        throw OpenStateException(
            'Le format « $id » n\'est pas encore disponible.');
    }
  }
}
