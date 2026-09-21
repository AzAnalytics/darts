// Descente dans le tableau perdant : à quel tour la PREMIÈRE revanche est-elle
// possible ? (deux joueurs qui viennent de s'affronter se retrouvent face à face)
//
// Mesure exacte via earliestRematch (voir bracket_test_utils.dart). Repères
// mesurés lors du choix du motif (première revanche possible, en tour du
// tableau perdant) :
//
//                                    8    16   32   64   17..32   33..64
//   descente « droite » (naïve)      2     2    2    2      2        2
//   inversé / droit alterné          3     4    4    4      4        4
//   motif retenu (_dropPosition)     3     4    5    6      5        6
//
// Plafond théorique observé : le tour k, avec k = log2 de la taille du tableau
// (plus petite puissance de 2 >= N). Le motif retenu l'atteint pour tout N de
// 3 à 64 ; ce test verrouille ce comportement.

import 'package:flutter_test/flutter_test.dart';

import 'package:darts/domain/bracket/bracket.dart';

import 'bracket_test_utils.dart';

/// k = log2 de la plus petite puissance de 2 >= n.
int _k(int n) {
  var size = 1, k = 0;
  while (size < n) {
    size *= 2;
    k++;
  }
  return k;
}

void main() {
  group('Instrument de mesure (petits tableaux, vérifiables à la main)', () {
    test('N = 4 : 1-4 puis 2-3 au tour 1 ; revanche possible dès L2-1', () {
      // 1 bat 4, mais 1 perd la finale du tableau gagnant : il descend en L2-1
      // où peut l'attendre 4 (vainqueur de L1-1). Idem pour 2 et 3.
      final risk = earliestRematch(generateDouble(4))!;
      expect(risk.nodeKey, 'L2-1');
      expect(risk.side, BracketSide.losers);
      expect(risk.round, 2);
      expect(risk.pairs, 2); // (1,4) et (2,3)
    });

    test('N = 3 : revanche possible dès L2-1', () {
      final risk = earliestRematch(generateDouble(3))!;
      expect(risk.nodeKey, 'L2-1');
      expect(risk.round, 2);
    });
  });

  group('Tableaux pleins : valeurs exactes verrouillées', () {
    test('8 joueurs : tour 3 (4 paires)', () {
      final risk = earliestRematch(generateDouble(8))!;
      expect((risk.round, risk.pairs), (3, 4));
    });

    test('16 joueurs : tour 4 (8 paires)', () {
      final risk = earliestRematch(generateDouble(16))!;
      expect((risk.round, risk.pairs), (4, 8));
    });

    test('32 joueurs : tour 5', () {
      final risk = earliestRematch(generateDouble(32))!;
      expect(risk.round, 5);
    });

    test('64 joueurs : tour 6', () {
      final risk = earliestRematch(generateDouble(64))!;
      expect(risk.round, 6);
    });
  });

  test('pour tout N de 3 à 48 : aucune revanche avant le tour k', () {
    for (var n = 3; n <= 48; n++) {
      final risk = earliestRematch(generateDouble(n))!;
      expect(risk.round, greaterThanOrEqualTo(_k(n)),
          reason: 'N=$n : revanche possible dès ${risk.nodeKey}, '
              'avant le tour k=${_k(n)}');
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
