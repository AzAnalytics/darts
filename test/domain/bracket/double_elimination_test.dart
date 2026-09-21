// Génération du tableau de double élimination.
// N = nombre de joueurs partout. Les byes n'ont PAS de case : le tableau ne
// contient que des matchs réellement joués (2N − 2 cases, +1 avec GF2).

import 'package:flutter_test/flutter_test.dart';

import 'package:darts/domain/bracket/bracket.dart';
import 'package:darts/domain/open_state_exception.dart';

import 'bracket_test_utils.dart';

// Raccourcis : destination du vainqueur / du perdant d'une case.
SlotRef? _w(Bracket b, String key) => b.nodeAt(key).winnerTo;
SlotRef? _l(Bracket b, String key) => b.nodeAt(key).loserTo;

void main() {
  group('Validation', () {
    test('refuse moins de 3 joueurs', () {
      expect(() => generateDouble(2), throwsA(isA<OpenStateException>()));
      expect(() => generateDouble(0), throwsA(isA<OpenStateException>()));
    });

    test('refuse un joueur inscrit deux fois', () {
      expect(
        () => doubleElim.generate([1, 2, 2, 3], const BracketConfig()),
        throwsA(isA<OpenStateException>()),
      );
    });
  });

  group('N = 4 (tableau complet, sans bye)', () {
    final b = generateDouble(4);

    test('6 cases exactement (2N − 2)', () {
      expect(b.nodes.map((n) => n.key).toSet(),
          {'W1-1', 'W1-2', 'W2-1', 'L1-1', 'L2-1', 'GF1'});
      expect(b.nodes.length, 6);
    });

    test('premier tour : 1 contre 4 et 2 contre 3, prêts à jouer', () {
      expect(b.nodeAt('W1-1').playerA, 1);
      expect(b.nodeAt('W1-1').playerB, 4);
      expect(b.nodeAt('W1-2').playerA, 2);
      expect(b.nodeAt('W1-2').playerB, 3);
      expect(b.nodeAt('W1-1').status, NodeStatus.ready);
      expect(b.nodeAt('W1-2').status, NodeStatus.ready);
      for (final key in ['W2-1', 'L1-1', 'L2-1', 'GF1']) {
        expect(b.nodeAt(key).status, NodeStatus.pending, reason: key);
      }
    });

    test('liens vainqueur / perdant', () {
      expect(_w(b, 'W1-1'), const SlotRef('W2-1', Slot.a));
      expect(_w(b, 'W1-2'), const SlotRef('W2-1', Slot.b));
      expect(_l(b, 'W1-1'), const SlotRef('L1-1', Slot.a));
      expect(_l(b, 'W1-2'), const SlotRef('L1-1', Slot.b));
      expect(_w(b, 'W2-1'), const SlotRef('GF1', Slot.a));
      expect(_l(b, 'W2-1'), const SlotRef('L2-1', Slot.b));
      expect(_w(b, 'L1-1'), const SlotRef('L2-1', Slot.a));
      expect(_w(b, 'L2-1'), const SlotRef('GF1', Slot.b));
      expect(_w(b, 'GF1'), isNull);
      expect(_l(b, 'GF1'), isNull);
    });
  });

  group('N = 8 (tableau complet, sans bye)', () {
    final b = generateDouble(8);

    test('14 cases (2N − 2), premier tour 1-8, 4-5, 2-7, 3-6', () {
      expect(b.nodes.length, 14);
      final pairs = [
        for (var i = 1; i <= 4; i++)
          (b.nodeAt('W1-$i').playerA, b.nodeAt('W1-$i').playerB),
      ];
      expect(pairs, [(1, 8), (4, 5), (2, 7), (3, 6)]);
    });

    test('les perdants du tableau gagnant arrivent en ordre inversé (tour 2 du tableau perdant)', () {
      // L2-1 reçoit le perdant de W2-2, L2-2 celui de W2-1 : on évite qu'un
      // joueur retrouve tout de suite celui qui vient de le battre.
      expect(_l(b, 'W2-1'), const SlotRef('L2-2', Slot.b));
      expect(_l(b, 'W2-2'), const SlotRef('L2-1', Slot.b));
      expect(_w(b, 'L1-1'), const SlotRef('L2-1', Slot.a));
      expect(_w(b, 'L1-2'), const SlotRef('L2-2', Slot.a));
    });

    test('finale du tableau perdant et grande finale', () {
      expect(_w(b, 'L2-1'), const SlotRef('L3-1', Slot.a));
      expect(_w(b, 'L2-2'), const SlotRef('L3-1', Slot.b));
      expect(_w(b, 'L3-1'), const SlotRef('L4-1', Slot.a));
      expect(_l(b, 'W3-1'), const SlotRef('L4-1', Slot.b));
      expect(_w(b, 'W3-1'), const SlotRef('GF1', Slot.a));
      expect(_w(b, 'L4-1'), const SlotRef('GF1', Slot.b));
    });
  });

  group('N = 5 (byes résolus, sans case)', () {
    final b = generateDouble(5);

    test('8 cases exactement (2N − 2) : les matchs de bye n\'existent pas', () {
      expect(b.nodes.map((n) => n.key).toSet(), {
        'W1-2', // 4 contre 5 : le seul match du premier tour
        'W2-1', 'W2-2', 'W3-1',
        'L2-1', 'L3-1', 'L4-1',
        'GF1',
      });
      expect(b.nodes.length, 8);
    });

    test('les têtes de série 1, 2 et 3 sont exemptées : placées directement au tour 2', () {
      expect(b.nodeAt('W1-2').playerA, 4);
      expect(b.nodeAt('W1-2').playerB, 5);
      expect(b.nodeAt('W2-1').playerA, 1); // tête de série 1 attend le vainqueur de 4-5
      expect(b.nodeAt('W2-1').playerB, isNull);
      expect(b.nodeAt('W2-2').playerA, 2);
      expect(b.nodeAt('W2-2').playerB, 3);
      expect(b.nodeAt('W2-2').status, NodeStatus.ready);
    });

    test('le tableau perdant se contracte autour des byes', () {
      expect(_w(b, 'W1-2'), const SlotRef('W2-1', Slot.b));
      // Le perdant de 4-5 rejoint directement L2-1 (L1-1 et L1-2 supprimés).
      expect(_l(b, 'W1-2'), const SlotRef('L2-1', Slot.a));
      expect(_l(b, 'W2-2'), const SlotRef('L2-1', Slot.b));
      // Le perdant de W2-1 saute L2-2 (supprimé) et arrive en L3-1.
      expect(_l(b, 'W2-1'), const SlotRef('L3-1', Slot.b));
      expect(_w(b, 'L2-1'), const SlotRef('L3-1', Slot.a));
      expect(_w(b, 'L3-1'), const SlotRef('L4-1', Slot.a));
      expect(_l(b, 'W3-1'), const SlotRef('L4-1', Slot.b));
    });
  });

  group('Grande finale', () {
    test('sans reset : pas de GF2, 2N − 2 cases', () {
      final b = generateDouble(6);
      expect(b.hasGrandFinalReset, isFalse);
      expect(b.nodeByKey(BracketKeys.grandFinalReset), isNull);
      expect(b.nodes.length, 2 * 6 - 2);
    });

    test('avec reset : GF2 présent, vide, en attente, 2N − 1 cases', () {
      final b = generateDouble(6, reset: true);
      expect(b.hasGrandFinalReset, isTrue);
      final gf2 = b.nodeAt(BracketKeys.grandFinalReset);
      expect(gf2.playerA, isNull);
      expect(gf2.playerB, isNull);
      expect(gf2.status, NodeStatus.pending);
      expect(b.nodes.length, 2 * 6 - 1);
    });
  });

  group('Invariants structurels pour N = 3 à 64', () {
    for (var n = 3; n <= 64; n++) {
      test('N = $n', () {
        for (final reset in [false, true]) {
          final b = generateDouble(n, reset: reset);
          final expectedCount = reset ? 2 * n - 1 : 2 * n - 2;
          expect(b.nodes.length, expectedCount,
              reason: 'nombre de cases (reset=$reset)');

          // Clés uniques
          expect(b.nodes.map((n) => n.key).toSet().length, b.nodes.length);

          // Chaque créneau (hors GF2, rempli par le moteur) est alimenté par
          // exactement UNE source : un joueur déjà placé OU un lien entrant.
          final incoming = <String, int>{};
          for (final node in b.nodes) {
            for (final ref in [node.winnerTo, node.loserTo]) {
              if (ref == null) continue;
              expect(b.nodeByKey(ref.nodeKey), isNotNull,
                  reason: '${node.key} pointe vers ${ref.nodeKey} inexistant');
              final slotId = '${ref.nodeKey}.${ref.slot.name}';
              incoming[slotId] = (incoming[slotId] ?? 0) + 1;
            }
          }
          for (final node in b.nodes) {
            if (node.key == BracketKeys.grandFinalReset) continue;
            for (final (slot, player) in [
              (Slot.a, node.playerA),
              (Slot.b, node.playerB),
            ]) {
              final sources = (player != null ? 1 : 0) +
                  (incoming['${node.key}.${slot.name}'] ?? 0);
              expect(sources, 1,
                  reason: '${node.key} créneau ${slot.name} : $sources source(s)');
            }
          }

          // Tous les joueurs sont placés exactement une fois à la génération.
          final placed = [
            for (final node in b.nodes) ...[
              if (node.playerA != null) node.playerA!,
              if (node.playerB != null) node.playerB!,
            ],
          ];
          expect(placed.toSet().length, placed.length,
              reason: 'un joueur placé deux fois');

          // Statut cohérent : prêt si et seulement si les deux joueurs sont connus.
          for (final node in b.nodes) {
            final both = node.playerA != null && node.playerB != null;
            expect(node.status,
                both ? NodeStatus.ready : NodeStatus.pending,
                reason: node.key);
          }

          // Les perdants du tableau perdant et de la grande finale sortent du tournoi.
          for (final node in b.nodes) {
            if (node.side != BracketSide.winners) {
              expect(node.loserTo, isNull, reason: node.key);
            }
          }
        }
      });
    }
  });

  group('Séparation des têtes de série 1 et 2 dans le tableau gagnant', () {
    // En double élimination, 1 et 2 PEUVENT se retrouver deux fois : en finale
    // du tableau gagnant, puis en grande finale. L'invariant correct est donc :
    // dans le tableau gagnant, elles sont dans des moitiés opposées et ne
    // peuvent pas se croiser avant la finale du tableau gagnant.
    for (var n = 3; n <= 64; n++) {
      test('N = $n', () {
        final b = generateDouble(n);
        final possible = possiblePlayersInWinners(b);
        final winnersFinalRound = b.nodes
            .where((node) => node.side == BracketSide.winners)
            .map((node) => node.round)
            .reduce((x, y) => x > y ? x : y);

        final casesWhereBothCanMeet = [
          for (final node in b.nodes)
            if (node.side == BracketSide.winners &&
                possible[node.key]!.containsAll([1, 2]))
              node,
        ];

        // Exactement une case peut les réunir : la finale du tableau gagnant.
        expect(casesWhereBothCanMeet.map((node) => node.key).toList(),
            [BracketKeys.winners(winnersFinalRound, 1)]);
      });
    }
  });
}
