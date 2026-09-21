// lib/domain/open_rules.dart
// Règles d'un open partagées par le repository et les écrans (logique PURE).

import 'bracket/bracket_formats.dart';
import 'open.dart';

/// État du classement (têtes de série) d'un open.
enum SeedingStatus {
  /// Personne n'a de tête de série (ou aucun inscrit).
  none,

  /// Certains ont une tête de série, pas tous, ou elles sont incohérentes.
  partial,

  /// Tous les inscrits ont une tête de série, exactement 1..N sans trou.
  complete,
}

SeedingStatus seedingStatusOf(Iterable<int?> seeds) {
  final list = seeds.toList();
  if (list.every((s) => s == null)) return SeedingStatus.none;
  if (list.contains(null)) return SeedingStatus.partial;
  final distinct = list.cast<int>().toSet();
  // N valeurs distinctes toutes comprises entre 1 et N : c'est exactement 1..N.
  final complete =
      distinct.length == list.length && distinct.every((s) => s >= 1 && s <= list.length);
  return complete ? SeedingStatus.complete : SeedingStatus.partial;
}

SeedingStatus seedingStatus(List<OpenEntry> entries) =>
    seedingStatusOf(entries.map((e) => e.seed));

/// Ce qui empêche de générer le tableau, en français, ou null si tout est prêt.
/// Un seul motif à la fois, dans cet ordre : format, nombre de joueurs, têtes
/// de série. Ne s'applique qu'à un open en inscriptions.
String? generationBlocker(OpenSummary open, List<OpenEntry> entries) {
  if (open.status != OpenStatus.setup) {
    return 'Le tableau est déjà généré.';
  }
  if (!isFormatAvailable(open.format)) {
    return 'Le format « ${formatLabel(open.format)} » n\'est pas encore disponible : '
        'modifiez le format de l\'open (menu ⋮ › Modifier).';
  }
  final minPlayers = BracketFormats.byId(open.format).minPlayers;
  if (entries.length < minPlayers) {
    return 'Il faut au moins $minPlayers joueurs : '
        '${entryCountLabel(entries.length)} pour l\'instant.';
  }
  switch (seedingStatus(entries)) {
    case SeedingStatus.complete:
      return null;
    case SeedingStatus.none:
      return 'Définissez les têtes de série : glissez les joueurs pour les '
          'classer, ou faites le tirage au sort.';
    case SeedingStatus.partial:
      final missing = entries.where((e) => e.seed == null).length;
      if (missing == 1) {
        return '1 joueur n\'a pas de tête de série : classez-le ou refaites le tirage.';
      }
      if (missing > 1) {
        return '$missing joueurs n\'ont pas de tête de série : '
            'classez-les ou refaites le tirage.';
      }
      return 'Les têtes de série sont incohérentes : classez à nouveau les '
          'joueurs ou refaites le tirage.';
  }
}
