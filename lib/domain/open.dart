// lib/domain/open.dart
// Vocabulaire et DTOs d'un open (sans dépendance à Drift ni à Flutter :
// réutilisables tels quels avec un futur backend distant).

/// Formats d'open. Valeurs stockées dans `opens.format`.
abstract final class OpenFormat {
  static const singleElim = 'single_elim';
  static const doubleElim = 'double_elim';
  static const groupsKnockout = 'groups_knockout';

  static const all = [singleElim, doubleElim, groupsKnockout];
}

/// Cycle de vie d'un open. Valeurs stockées dans `opens.status`.
abstract final class OpenStatus {
  /// Inscriptions et seeding en cours, pas encore de tableau.
  static const setup = 'setup';

  /// Tableau généré, des matchs sont à jouer.
  static const running = 'running';

  /// Tous les matchs sont joués, places finales calculées.
  static const finished = 'finished';
}

/// Données saisies par le président pour créer / modifier un open.
class NewOpen {
  final String name;
  final String? location;
  final DateTime? date;
  final String format;

  /// Nombre de legs du match (impair : 1, 3, 5…).
  final int bestOf;

  /// Double élimination : si le vainqueur du tableau perdant gagne la grande
  /// finale, un second match est joué. Désactivé par défaut (finale sèche).
  final bool grandFinalReset;

  const NewOpen({
    required this.name,
    this.location,
    this.date,
    this.format = OpenFormat.doubleElim,
    this.bestOf = 5,
    this.grandFinalReset = false,
  });
}

class OpenSummary {
  final int id;
  final String name;
  final String? location;
  final DateTime? date;
  final String format;
  final int bestOf;
  final bool grandFinalReset;
  final String status;
  final int entryCount;
  const OpenSummary({
    required this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.format,
    required this.bestOf,
    required this.grandFinalReset,
    required this.status,
    required this.entryCount,
  });
}

/// Un joueur inscrit à un open.
class OpenEntry {
  final int playerId;
  final String playerName;

  /// Tête de série (1 = la meilleure). Null tant que le seeding n'est pas fait.
  final int? seed;

  /// Place finale, renseignée à la fin de l'open.
  final int? finalPlacement;
  const OpenEntry({
    required this.playerId,
    required this.playerName,
    required this.seed,
    required this.finalPlacement,
  });
}
