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

/// Libellé français d'un format d'open (voir OpenFormat).
String formatLabel(String format) {
  switch (format) {
    case OpenFormat.singleElim:
      return 'Élimination simple';
    case OpenFormat.doubleElim:
      return 'Double élimination';
    case OpenFormat.groupsKnockout:
      return 'Poules + phase finale';
    default:
      return format;
  }
}

/// Vrai si le tableau de ce format peut être généré aujourd'hui.
/// (Seule la double élimination est implémentée : voir BracketFormats.)
bool isFormatAvailable(String format) => format == OpenFormat.doubleElim;

/// « 1 inscrit », « 12 inscrits ».
String entryCountLabel(int count) => count <= 1 ? '$count inscrit' : '$count inscrits';

/// Cycle de vie d'un open. Valeurs stockées dans `opens.status`.
abstract final class OpenStatus {
  /// Inscriptions et seeding en cours, pas encore de tableau.
  static const setup = 'setup';

  /// Tableau généré, des matchs sont à jouer.
  static const running = 'running';

  /// Tous les matchs sont joués, places finales calculées.
  static const finished = 'finished';
}

/// Nombres de legs proposés à l'utilisateur (best-of). Liste UNIQUE partagée par
/// le match libre (SetupScreen) et le formulaire d'open, pour qu'il ne voie
/// jamais deux listes différentes. Le repository accepte tout nombre impair.
const bestOfOptions = [3, 5, 7, 9, 11];

/// Données saisies par le président pour créer / modifier un open.
class NewOpen {
  final String name;
  final String? location;
  final DateTime? date;
  final String format;

  /// Best-of PAR DÉFAUT des matchs de l'open (impair : 3, 5, 7…). Ce n'est pas
  /// une contrainte figée : chaque match enregistre son propre best-of
  /// (`matches.bestOf`) ; celui de l'open est la valeur proposée au lancement
  /// d'un match. Cela laisse la porte ouverte à un best-of variable par tour
  /// (finale plus longue) sans toucher au schéma.
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

  /// Best-of par défaut des matchs (voir NewOpen.bestOf).
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
