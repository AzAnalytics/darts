// Simulation d'opens complets pour N = 3 à 64, résultats aléatoires (graines
// fixes : reproductible), ordre de jeu aléatoire des cases prêtes.
//
// Invariant central : nombre de matchs réellement joués
//   = 2N − 2                      (sans reset, ou avec reset non déclenché)
//   = 2N − 1                      (avec reset déclenché : le champion du tableau
//                                  perdant gagne GF1, GF2 est alors joué)

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:darts/domain/bracket/bracket.dart';

import 'bracket_test_utils.dart';

void main() {
  group('Open complet simulé', () {
    for (var n = 3; n <= 64; n++) {
      test('N = $n', () {
        for (final reset in [false, true]) {
          for (var seed = 0; seed < 6; seed++) {
            final random = Random(n * 1000 + seed);
            final label = 'N=$n reset=$reset graine=$seed';
            final sim = simulate(
              generateDouble(n, reset: reset),
              pickWinner: (node) =>
                  random.nextBool() ? node.playerA! : node.playerB!,
              order: random,
            );
            final b = sim.bracket;

            // --- Nombre de matchs joués ---
            final expectedMatches = 2 * n - 2 + (sim.resetPlayed ? 1 : 0);
            expect(sim.matchesPlayed, expectedMatches, reason: label);
            if (!reset) expect(sim.resetPlayed, isFalse, reason: label);

            // --- Défaites : 2 pour chacun, sauf le champion et le finaliste ---
            final champion = b.championId!;
            final finalist = b.decidingFinal!.loserId!;
            expect(champion, isNot(finalist), reason: label);
            for (var p = 1; p <= n; p++) {
              final lost = sim.losses[p] ?? 0;
              if (p == champion) {
                expect(lost, lessThanOrEqualTo(1), reason: '$label champion $p');
              } else if (p == finalist) {
                // Finale sèche : le finaliste a 1 ou 2 défaites. Avec reset
                // déclenché il en a exactement 2.
                expect(lost, inInclusiveRange(1, 2), reason: '$label finaliste $p');
                if (sim.resetPlayed) expect(lost, 2, reason: '$label finaliste $p');
              } else {
                expect(lost, 2, reason: '$label joueur $p');
              }
            }

            // --- Toutes les cases sont terminées, sauf GF2 éventuellement inutile ---
            for (final node in b.nodes) {
              expect(
                node.status == NodeStatus.finished ||
                    (node.key == BracketKeys.grandFinalReset &&
                        node.status == NodeStatus.skipped),
                isTrue,
                reason: '$label ${node.key} ${node.status.name}',
              );
              if (node.status == NodeStatus.finished) {
                expect(node.winnerId, anyOf(node.playerA, node.playerB));
              }
            }

            // --- Places finales ---
            final places = doubleElim.placements(b);
            expect(places.keys.toSet(), {for (var p = 1; p <= n; p++) p},
                reason: label);
            expect(places[champion], 1, reason: label);
            expect(places[finalist], 2, reason: label);
            for (final entry in places.entries) {
              expect(entry.value, inInclusiveRange(1, n), reason: label);
              // Classement « à la compétition » : la place d'un joueur = 1 +
              // nombre de joueurs strictement mieux classés (1,2,3,4,5,5,7,7…).
              final better = places.values.where((v) => v < entry.value).length;
              expect(better, entry.value - 1,
                  reason: '$label joueur ${entry.key} place ${entry.value}');
            }
          }
        }
      });
    }
  });

  test('le résultat ne dépend pas de l\'ordre de jeu des cases prêtes', () {
    // Même vainqueurs (le mieux classé gagne), ordres de jeu différents.
    for (var n = 3; n <= 40; n++) {
      final reference = simulate(generateDouble(n), pickWinner: favoriteWins);
      for (var seed = 0; seed < 4; seed++) {
        final other = simulate(
          generateDouble(n),
          pickWinner: favoriteWins,
          order: Random(seed),
        );
        expect(doubleElim.placements(other.bracket),
            doubleElim.placements(reference.bracket),
            reason: 'N=$n graine=$seed');
      }
    }
  });

  group('Places finales : cas de référence (le mieux classé gagne toujours)', () {
    test('N = 4', () {
      final sim = simulate(generateDouble(4), pickWinner: favoriteWins);
      expect(doubleElim.placements(sim.bracket), {1: 1, 2: 2, 3: 3, 4: 4});
    });

    test('N = 8 : 1, 2, 3, 4, puis deux 5es et deux 7es', () {
      final sim = simulate(generateDouble(8), pickWinner: favoriteWins);
      expect(sim.matchesPlayed, 14);
      expect(doubleElim.placements(sim.bracket),
          {1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 5, 7: 7, 8: 7});
    });

    test('N = 5 (avec byes)', () {
      final sim = simulate(generateDouble(5), pickWinner: favoriteWins);
      expect(sim.matchesPlayed, 8);
      expect(doubleElim.placements(sim.bracket), {1: 1, 2: 2, 3: 3, 4: 4, 5: 5});
    });

    test('les places ne sont pas disponibles avant la fin', () {
      expect(() => doubleElim.placements(generateDouble(4)), throwsA(anything));
    });
  });
}
