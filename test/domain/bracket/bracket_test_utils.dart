// Utilitaires partagés par les tests du tableau.
// Convention : dans ces tests l'identifiant d'un joueur = sa tête de série
// (joueur 1 = tête de série 1, etc.), ce qui rend les scénarios lisibles.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:darts/domain/bracket/bracket.dart';
import 'package:darts/domain/bracket/bracket_engine.dart';
import 'package:darts/domain/bracket/double_elimination.dart';

const engine = BracketEngine();
const doubleElim = DoubleEliminationFormat();

/// Tableau de double élimination pour [n] joueurs (joueur i = tête de série i).
Bracket generateDouble(int n, {bool reset = false}) => doubleElim.generate(
      List.generate(n, (i) => i + 1),
      BracketConfig(grandFinalReset: reset),
    );

/// Joue un match : [winner] gagne la case [key].
Bracket play(Bracket bracket, String key, int winner) =>
    engine.applyResult(bracket, key, winner).bracket;

class Simulation {
  final Bracket bracket;
  final int matchesPlayed;

  /// Nombre de défaites par joueur.
  final Map<int, int> losses;

  /// Vrai si le second match de grande finale a été joué.
  final bool resetPlayed;
  const Simulation(this.bracket, this.matchesPlayed, this.losses, this.resetPlayed);
}

/// Joue un tableau jusqu'au bout. [pickWinner] choisit le vainqueur d'une case
/// prête ; [order] (optionnel) choisit au hasard quelle case prête jouer en
/// premier (sinon : la première), pour vérifier que l'ordre n'a pas d'influence.
///
/// Vérifie au passage : personne ne joue contre soi-même, et aucun joueur n'est
/// présent dans deux cases prêtes en même temps.
Simulation simulate(
  Bracket start, {
  required int Function(BracketNode node) pickWinner,
  Random? order,
}) {
  var bracket = start;
  var played = 0;
  final losses = <int, int>{};
  final maxSteps = start.nodes.length + 5;

  while (!bracket.isComplete) {
    if (played > maxSteps) fail('Le tableau ne se termine pas (boucle ?)');
    final ready = bracket.readyNodes.toList();
    if (ready.isEmpty) {
      fail('Tableau bloqué : aucune case prête. Cases : ${bracket.nodes}');
    }

    final inPlay = <int>{};
    for (final node in ready) {
      expect(node.playerA, isNot(node.playerB),
          reason: '${node.key} : un joueur contre lui-même');
      for (final p in [node.playerA!, node.playerB!]) {
        expect(inPlay.add(p), isTrue,
            reason: 'Joueur $p dans deux matchs prêts en même temps');
      }
    }

    final node = order == null ? ready.first : ready[order.nextInt(ready.length)];
    final winner = pickWinner(node);
    final loser = winner == node.playerA ? node.playerB! : node.playerA!;
    losses[loser] = (losses[loser] ?? 0) + 1;
    bracket = play(bracket, node.key, winner);
    played++;
  }

  final gf2 = bracket.nodeByKey(BracketKeys.grandFinalReset);
  return Simulation(
    bracket,
    played,
    losses,
    gf2 != null && gf2.status == NodeStatus.finished,
  );
}

/// Toujours la meilleure tête de série (le plus petit numéro) qui gagne.
int favoriteWins(BracketNode node) => min(node.playerA!, node.playerB!);

/// Pour chaque case du tableau gagnant, l'ensemble des joueurs qui PEUVENT s'y
/// retrouver (joueurs déjà placés + tout ce qui peut y arriver par les
/// vainqueurs des cases précédentes du tableau gagnant).
Map<String, Set<int>> possiblePlayersInWinners(Bracket bracket) {
  final winners = bracket.nodes.where((n) => n.side == BracketSide.winners);
  final feeders = <String, List<BracketNode>>{};
  for (final n in winners) {
    final target = n.winnerTo;
    if (target != null) feeders.putIfAbsent(target.nodeKey, () => []).add(n);
  }
  final memo = <String, Set<int>>{};
  Set<int> possible(BracketNode n) => memo[n.key] ??= {
        if (n.playerA != null) n.playerA!,
        if (n.playerB != null) n.playerB!,
        for (final f in feeders[n.key] ?? const <BracketNode>[]) ...possible(f),
      };
  return {for (final n in winners) n.key: possible(n)};
}

/// Le premier « double affrontement » possible dans un tableau.
class RematchRisk {
  /// Case où la revanche peut avoir lieu (la plus précoce).
  final String nodeKey;
  final BracketSide side;
  final int round;

  /// Nombre de paires de joueurs pouvant se rejouer à ce moment-là.
  final int pairs;
  const RematchRisk(this.nodeKey, this.side, this.round, this.pairs);

  @override
  String toString() => '$nodeKey (tour $round, $pairs paires)';
}

/// Mesure exacte (sans tirage au sort) du tour le plus précoce où deux joueurs
/// qui viennent de s'affronter peuvent se retrouver face à face une seconde fois.
///
/// Principe : le parcours d'un joueur est une suite de cases (à chaque case il
/// gagne -> lien vainqueur, ou perd -> lien perdant). Deux joueurs se
/// rencontrent dans toute case commune à leurs parcours ; à la première
/// rencontre l'un gagne et l'autre perd, donc leurs parcours DOIVENT diverger
/// (et les deux doivent continuer). La revanche est la case commune suivante.
/// On énumère tous les couples de parcours : il y en a peu (un parcours = un
/// tour de chute dans le tableau perdant), le calcul est donc exact.
///
/// Renvoie null si aucune revanche n'est possible. La grande finale compte comme
/// le dernier tour possible (un champion des deux tableaux s'y rencontre presque
/// toujours pour la seconde fois).
RematchRisk? earliestRematch(Bracket bracket) {
  final byKey = {for (final n in bracket.nodes) n.key: n};
  final startOf = <int, String>{};
  for (final n in bracket.nodes) {
    if (n.playerA != null) startOf[n.playerA!] = n.key;
    if (n.playerB != null) startOf[n.playerB!] = n.key;
  }

  final memo = <String, List<List<String>>>{};
  List<List<String>> pathsFrom(String key) => memo[key] ??= [
        [key],
        for (final ref in [byKey[key]!.winnerTo, byKey[key]!.loserTo])
          if (ref != null)
            for (final tail in pathsFrom(ref.nodeKey)) [key, ...tail],
      ];

  int rank(String key) {
    final n = byKey[key]!;
    return n.side == BracketSide.grandFinal ? 1 << 20 : n.round;
  }

  final players = startOf.keys.toList()..sort();
  // Parcours de chaque joueur (avec leur ensemble de cases, calculé une fois).
  final journeys = {
    for (final p in players)
      p: [
        for (final path in pathsFrom(startOf[p]!)) (path, path.toSet()),
      ],
  };
  String? bestKey;
  var bestRank = 1 << 30;
  var bestPairs = <String>{};

  for (var i = 0; i < players.length; i++) {
    for (var j = i + 1; j < players.length; j++) {
      for (final (sx, _) in journeys[players[i]]!) {
        for (final (sy, inY) in journeys[players[j]]!) {
          final shared = [for (final k in sx) if (inY.contains(k)) k];
          if (shared.length < 2) continue;
          // Première rencontre : les parcours doivent diverger et continuer.
          final ix = sx.indexOf(shared[0]);
          final iy = sy.indexOf(shared[0]);
          if (ix + 1 >= sx.length || iy + 1 >= sy.length) continue;
          if (sx[ix + 1] == sy[iy + 1]) continue;
          final rematchNode = shared[1];
          final r = rank(rematchNode);
          if (r < bestRank) {
            bestRank = r;
            bestKey = rematchNode;
            bestPairs = {};
          }
          if (r == bestRank) bestPairs.add('${players[i]}-${players[j]}');
        }
      }
    }
  }
  if (bestKey == null) return null;
  final node = byKey[bestKey]!;
  return RematchRisk(bestKey, node.side, node.round, bestPairs.length);
}
