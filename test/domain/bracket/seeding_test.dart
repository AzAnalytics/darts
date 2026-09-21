import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:darts/domain/bracket/seeding.dart';

void main() {
  group('nextPowerOfTwo', () {
    test('renvoie la plus petite puissance de 2 >= n', () {
      expect(nextPowerOfTwo(1), 1);
      expect(nextPowerOfTwo(2), 2);
      expect(nextPowerOfTwo(3), 4);
      expect(nextPowerOfTwo(4), 4);
      expect(nextPowerOfTwo(5), 8);
      expect(nextPowerOfTwo(16), 16);
      expect(nextPowerOfTwo(17), 32);
    });
  });

  group('standardSeedOrder', () {
    test('valeurs connues', () {
      expect(standardSeedOrder(2), [1, 2]);
      expect(standardSeedOrder(4), [1, 4, 2, 3]);
      expect(standardSeedOrder(8), [1, 8, 4, 5, 2, 7, 3, 6]);
      expect(standardSeedOrder(16),
          [1, 16, 8, 9, 4, 13, 5, 12, 2, 15, 7, 10, 3, 14, 6, 11]);
    });

    test('permutation complète, chaque paire fait taille + 1', () {
      for (final size in [2, 4, 8, 16, 32, 64, 128]) {
        final order = standardSeedOrder(size);
        expect(order.toSet(), {for (var s = 1; s <= size; s++) s});
        for (var i = 0; i < size; i += 2) {
          expect(order[i] + order[i + 1], size + 1);
        }
      }
    });

    test('les têtes de série 1 et 2 sont dans des moitiés opposées', () {
      for (final size in [4, 8, 16, 32, 64]) {
        final order = standardSeedOrder(size);
        expect(order.indexOf(1), lessThan(size ~/ 2));
        expect(order.indexOf(2), greaterThanOrEqualTo(size ~/ 2));
      }
    });

    test('refuse une taille qui n\'est pas une puissance de 2', () {
      expect(() => standardSeedOrder(6), throwsArgumentError);
      expect(() => standardSeedOrder(1), throwsArgumentError);
      expect(() => standardSeedOrder(0), throwsArgumentError);
    });
  });

  group('shuffledSeeds', () {
    test('conserve les mêmes joueurs et ne modifie pas l\'entrée', () {
      final input = [10, 20, 30, 40, 50];
      final shuffled = shuffledSeeds(input, Random(1));
      expect(shuffled.toSet(), input.toSet());
      expect(shuffled.length, input.length);
      expect(input, [10, 20, 30, 40, 50]);
    });

    test('reproductible avec la même graine', () {
      final input = List.generate(20, (i) => i);
      expect(shuffledSeeds(input, Random(42)), shuffledSeeds(input, Random(42)));
    });
  });
}
