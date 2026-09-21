// lib/domain/bracket/bracket_format.dart
// Un format de tournoi sait générer son tableau et calculer les places finales.
// La progression (faire avancer un match) est commune : voir BracketEngine.
// Ajouter un format = une nouvelle implémentation + une entrée dans BracketFormats.

import 'bracket.dart';

abstract class BracketFormat {
  /// Identifiant stocké dans `opens.format` (voir OpenFormat).
  String get id;

  /// Nombre minimum de joueurs pour lancer le format.
  int get minPlayers;

  /// Génère le tableau initial. [playersBySeed] : joueurs classés par tête de
  /// série (index 0 = tête de série 1). Les byes sont résolus ici, sans case.
  Bracket generate(List<int> playersBySeed, BracketConfig config);

  /// Place finale de chaque joueur (1 = vainqueur). Les ex æquo partagent la
  /// meilleure place de leur groupe (ex. deux 5es, puis un 7e…). Le tableau doit
  /// être terminé.
  Map<int, int> placements(Bracket bracket);
}
