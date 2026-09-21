// lib/domain/bracket/seeding.dart
// Têtes de série : ordre de placement standard et tirage au sort.

import 'dart:math';

/// Plus petite puissance de 2 supérieure ou égale à [n] (n >= 1).
int nextPowerOfTwo(int n) {
  var size = 1;
  while (size < n) {
    size *= 2;
  }
  return size;
}

/// Ordre de placement standard des têtes de série pour un tableau dont la
/// taille [size] est une puissance de 2. Les cases du premier tour sont les
/// paires consécutives : pour 8 → [1,8, 4,5, 2,7, 3,6] soit 1-8, 4-5, 2-7, 3-6.
/// Les têtes de série 1 et 2 sont dans des moitiés opposées du tableau, 1 et 3/4
/// dans des quarts opposés, etc.
List<int> standardSeedOrder(int size) {
  if (size < 2 || (size & (size - 1)) != 0) {
    throw ArgumentError.value(size, 'size', 'doit être une puissance de 2 >= 2');
  }
  var order = [1, 2];
  while (order.length < size) {
    final next = order.length * 2;
    order = [
      for (final seed in order) ...[seed, next + 1 - seed],
    ];
  }
  return order;
}

/// Tirage au sort des têtes de série : renvoie les joueurs mélangés
/// (le premier = tête de série 1). [random] injectable pour les tests.
List<int> shuffledSeeds(Iterable<int> playerIds, Random random) {
  return [...playerIds]..shuffle(random);
}
