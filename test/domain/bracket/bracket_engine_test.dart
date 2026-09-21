// Progression du tableau : BracketEngine.applyResult.
// Scénario de référence : 4 joueurs (joueur i = tête de série i).
//   W1-1 : 1 vs 4    W1-2 : 2 vs 3    W2-1 : gagnants    L1-1 : perdants du tour 1
//   L2-1 : gagnant de L1-1 vs perdant de W2-1    GF1 : gagnant W2-1 vs gagnant L2-1

import 'package:flutter_test/flutter_test.dart';

import 'package:darts/domain/bracket/bracket.dart';
import 'package:darts/domain/open_state_exception.dart';

import 'bracket_test_utils.dart';

Matcher get _openError => throwsA(isA<OpenStateException>());

void main() {
  group('Avancement d\'un match', () {
    test('le vainqueur et le perdant sont placés dans les bons créneaux', () {
      final start = generateDouble(4);
      final update = engine.applyResult(start, 'W1-1', 1, matchId: 77);
      final b = update.bracket;

      final played = b.nodeAt('W1-1');
      expect(played.status, NodeStatus.finished);
      expect(played.winnerId, 1);
      expect(played.loserId, 4);
      expect(played.matchId, 77);

      expect(b.nodeAt('W2-1').playerA, 1); // vainqueur -> tableau gagnant
      expect(b.nodeAt('L1-1').playerA, 4); // perdant -> tableau perdant
    });

    test('une case devient prête quand ses deux joueurs sont connus', () {
      var b = generateDouble(4);
      b = play(b, 'W1-1', 1);
      expect(b.nodeAt('W2-1').status, NodeStatus.pending);
      expect(b.nodeAt('L1-1').status, NodeStatus.pending);
      b = play(b, 'W1-2', 2);
      expect(b.nodeAt('W2-1').status, NodeStatus.ready);
      expect(b.nodeAt('L1-1').status, NodeStatus.ready);
      expect(b.nodeAt('L1-1').playerA, 4);
      expect(b.nodeAt('L1-1').playerB, 3);
    });

    test('la liste des cases modifiées est complète', () {
      final update = engine.applyResult(generateDouble(4), 'W1-1', 4);
      expect(update.changed.map((n) => n.key).toSet(), {'W1-1', 'W2-1', 'L1-1'});
    });

    test('le tableau d\'origine n\'est pas modifié (immuable)', () {
      final start = generateDouble(4);
      engine.applyResult(start, 'W1-1', 1);
      expect(start.nodeAt('W1-1').status, NodeStatus.ready);
      expect(start.nodeAt('W2-1').playerA, isNull);
    });

    test('un joueur avec un bye est déjà en place et attend son adversaire', () {
      // N = 5 : la tête de série 1 est directement au tour 2.
      var b = generateDouble(5);
      expect(b.nodeAt('W2-1').status, NodeStatus.pending);
      b = play(b, 'W1-2', 5); // 5 bat 4
      expect(b.nodeAt('W2-1').playerA, 1);
      expect(b.nodeAt('W2-1').playerB, 5);
      expect(b.nodeAt('W2-1').status, NodeStatus.ready);
      expect(b.nodeAt('L2-1').playerA, 4); // le perdant 4 saute le tour 1 perdant
    });
  });

  group('Refus des résultats invalides', () {
    test('case inconnue', () {
      expect(() => engine.applyResult(generateDouble(4), 'W9-9', 1), _openError);
    });

    test('case pas encore jouable (adversaire inconnu)', () {
      expect(() => engine.applyResult(generateDouble(4), 'W2-1', 1), _openError);
    });

    test('vainqueur qui ne fait pas partie du match', () {
      expect(() => engine.applyResult(generateDouble(4), 'W1-1', 2), _openError);
      expect(() => engine.applyResult(generateDouble(4), 'W1-1', 99), _openError);
    });

    test('match déjà terminé', () {
      final b = play(generateDouble(4), 'W1-1', 1);
      expect(() => engine.applyResult(b, 'W1-1', 4), _openError);
    });
  });

  group('Marqueur', () {
    test('le marqueur désigné est retiré s\'il devient joueur du match', () {
      // Le joueur 2 est désigné marqueur de W2-1 (adversaires pas encore connus)…
      var b = generateDouble(4);
      b = b.replacing([b.nodeAt('W2-1').withMarker(2)]);
      b = play(b, 'W1-1', 1);
      expect(b.nodeAt('W2-1').markerId, 2);
      // …puis il gagne W1-2 et se retrouve dans le match qu'il devait marquer.
      b = play(b, 'W1-2', 2);
      expect(b.nodeAt('W2-1').playerB, 2);
      expect(b.nodeAt('W2-1').markerId, isNull);
    });

    test('marqueur retiré : le match reste prêt et jouable, sans marqueur', () {
      // Un match n'est JAMAIS bloqué faute de marqueur : le statut ne dépend
      // que de la présence des deux joueurs.
      var b = generateDouble(4);
      b = b.replacing([b.nodeAt('W2-1').withMarker(2)]);
      b = play(b, 'W1-1', 1);
      b = play(b, 'W1-2', 2); // 2 rejoint W2-1 : son assignation est retirée
      final finale = b.nodeAt('W2-1');
      expect(finale.markerId, isNull);
      expect(finale.status, NodeStatus.ready);
      b = play(b, 'W2-1', 1); // jouable sans marqueur
      expect(b.nodeAt('W2-1').status, NodeStatus.finished);
      expect(b.nodeAt(BracketKeys.grandFinal).playerA, 1);
    });

    test('un marqueur étranger au match est conservé', () {
      var b = generateDouble(4);
      b = b.replacing([b.nodeAt('W2-1').withMarker(3)]);
      b = play(b, 'W1-1', 1);
      b = play(b, 'W1-2', 2);
      expect(b.nodeAt('W2-1').markerId, 3);
    });
  });

  // Déroulé commun jusqu'à la grande finale (N = 4) :
  // 1 bat 4, 2 bat 3, 1 bat 2 (W2-1), 3 bat 4 (L1-1), 2 bat 3 (L2-1)
  // -> GF1 : 1 (tableau gagnant, créneau A) contre 2 (tableau perdant, créneau B).
  Bracket toGrandFinal({required bool reset}) {
    var b = generateDouble(4, reset: reset);
    b = play(b, 'W1-1', 1);
    b = play(b, 'W1-2', 2);
    b = play(b, 'W2-1', 1);
    b = play(b, 'L1-1', 3);
    b = play(b, 'L2-1', 2);
    return b;
  }

  group('Grande finale sans reset', () {
    test('GF1 oppose les deux champions', () {
      final b = toGrandFinal(reset: false);
      final gf1 = b.nodeAt(BracketKeys.grandFinal);
      expect(gf1.playerA, 1);
      expect(gf1.playerB, 2);
      expect(gf1.status, NodeStatus.ready);
      expect(b.isComplete, isFalse);
    });

    test('le champion du tableau gagnant gagne : terminé', () {
      final b = play(toGrandFinal(reset: false), 'GF1', 1);
      expect(b.isComplete, isTrue);
      expect(b.championId, 1);
    });

    test('le champion du tableau perdant gagne : terminé aussi (finale sèche)', () {
      final b = play(toGrandFinal(reset: false), 'GF1', 2);
      expect(b.isComplete, isTrue);
      expect(b.championId, 2);
    });
  });

  group('Grande finale avec reset', () {
    test('le champion du tableau gagnant gagne GF1 : GF2 inutile', () {
      final b = play(toGrandFinal(reset: true), 'GF1', 1);
      expect(b.nodeAt(BracketKeys.grandFinalReset).status, NodeStatus.skipped);
      expect(b.isComplete, isTrue);
      expect(b.championId, 1);
    });

    test('le champion du tableau perdant gagne GF1 : GF2 à jouer, mêmes joueurs', () {
      final b = play(toGrandFinal(reset: true), 'GF1', 2);
      final gf2 = b.nodeAt(BracketKeys.grandFinalReset);
      expect(gf2.status, NodeStatus.ready);
      expect({gf2.playerA, gf2.playerB}, {1, 2});
      expect(b.isComplete, isFalse);
      expect(b.championId, isNull);
    });

    test('GF2 : le vainqueur du tableau gagnant reprend l\'avantage', () {
      var b = play(toGrandFinal(reset: true), 'GF1', 2);
      b = play(b, BracketKeys.grandFinalReset, 1);
      expect(b.isComplete, isTrue);
      expect(b.championId, 1);
    });

    test('GF2 : le vainqueur du tableau perdant confirme', () {
      var b = play(toGrandFinal(reset: true), 'GF1', 2);
      b = play(b, BracketKeys.grandFinalReset, 2);
      expect(b.isComplete, isTrue);
      expect(b.championId, 2);
    });
  });
}
