// Tests de CARACTÉRISATION : ils figent le comportement actuel des quatre
// classements (180, moyenne, checkout, historique) et de l'identité d'un joueur
// (même nom -> même id), AVANT la modification de getOrCreatePlayer
// (comparaison insensible à la casse). Ils doivent continuer à passer, sans
// être modifiés, après ce changement.
//
// Jusqu'ici watchAverages et watchCheckouts n'étaient couverts par aucun test.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:darts/data/database.dart';
import 'package:darts/data/repository.dart';

TurnData _turn(int leg, int player, int score,
        {int darts = 3, bool bust = false, bool checkout = false}) =>
    TurnData(
      legNumber: leg,
      playerId: player,
      score: score,
      dartsUsed: darts,
      isBust: bust,
      isCheckout: checkout,
    );

void main() {
  late AppDatabase db;
  late DriftDartsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftDartsRepository(db);
  });
  tearDown(() => db.close());

  group('Identité d\'un joueur', () {
    test('le même nom renvoie toujours le même joueur', () async {
      final first = await repo.getOrCreatePlayer('Alice');
      final again = await repo.getOrCreatePlayer('Alice');
      expect(again, first);
      expect(await db.select(db.players).get(), hasLength(1));
    });

    test('des noms différents sont des joueurs différents', () async {
      final a = await repo.getOrCreatePlayer('Alice');
      final b = await repo.getOrCreatePlayer('Bob');
      expect(a, isNot(b));
      expect(await db.select(db.players).get(), hasLength(2));
    });

    test('le nom enregistré est celui de la première création', () async {
      await repo.getOrCreatePlayer('Alice');
      final row = (await db.select(db.players).get()).single;
      expect(row.name, 'Alice');
    });
  });

  group('Classements cumulés par joueur', () {
    // Deux matchs : Alice-Bob puis Alice-Carl.
    //   Alice : volées 180, 141(co), 60, 45 puis 180, 121(co)
    //           -> 727 points en 18 fléchettes, deux 180, meilleur checkout 141
    //   Bob   : volées 100, 180, 100(co, 2 fléchettes), 26, puis une volée ratée (bust)
    //           -> 406 points en 14 fléchettes, un 180, meilleur checkout 100
    //   Carl  : volées 180, 60 -> 240 points en 6 fléchettes seulement
    late int alice, bob, carl;

    setUp(() async {
      alice = await repo.getOrCreatePlayer('Alice');
      bob = await repo.getOrCreatePlayer('Bob');
      carl = await repo.getOrCreatePlayer('Carl');

      await repo.saveFinishedMatch(FinishedMatchData(
        player1Id: alice,
        player2Id: bob,
        winnerId: alice,
        bestOf: 3,
        turns: [
          _turn(1, alice, 180),
          _turn(1, bob, 100),
          _turn(1, alice, 141, checkout: true),
          _turn(2, bob, 180),
          _turn(2, alice, 60),
          _turn(2, bob, 100, darts: 2, checkout: true),
          _turn(3, alice, 45),
          _turn(3, bob, 26),
          _turn(3, bob, 0, bust: true),
        ],
      ));
      await repo.saveFinishedMatch(FinishedMatchData(
        player1Id: alice,
        player2Id: carl,
        winnerId: alice,
        bestOf: 1,
        turns: [
          _turn(1, carl, 180),
          _turn(1, alice, 180),
          _turn(1, carl, 60),
          _turn(1, alice, 121, checkout: true),
        ],
      ));
    });

    Map<String, num> asMap(List<Standing> list) =>
        {for (final s in list) s.name: s.value};

    test('180 : cumul sur tous les matchs, ordre décroissant', () async {
      final list = await repo.watch180().first;
      expect(list.first.name, 'Alice');
      expect(asMap(list), {'Alice': 2, 'Bob': 1, 'Carl': 1});
    });

    test('moyenne 3 fléchettes : points / fléchettes x 3, un bust compte ses fléchettes',
        () async {
      final list = await repo.watchAverages().first;
      // Alice 727 / 18 x 3 = 121,17 ; Bob 406 / 14 x 3 = 87,0.
      expect(list.map((s) => s.name).toList(), ['Alice', 'Bob']);
      expect(list[0].value, closeTo(121.2, 0.001));
      expect(list[1].value, closeTo(87.0, 0.001));
    });

    test('moyenne : un joueur à moins de 9 fléchettes n\'apparaît pas', () async {
      final names = (await repo.watchAverages().first).map((s) => s.name);
      expect(names, isNot(contains('Carl'))); // 6 fléchettes seulement
    });

    test('checkout : meilleur checkout par joueur, ordre décroissant', () async {
      final list = await repo.watchCheckouts().first;
      expect(list.map((s) => s.name).toList(), ['Alice', 'Bob']);
      expect(asMap(list), {'Alice': 141, 'Bob': 100}); // Carl n'a jamais fini un leg
    });

    test('historique : une ligne par match, avec joueurs et vainqueur', () async {
      final list = await repo.watchHistory().first;
      final rows = list.map((m) => (m.p1, m.p2, m.winner)).toSet();
      expect(rows, {
        ('Alice', 'Bob', 'Alice'),
        ('Alice', 'Carl', 'Alice'),
      });
      expect(list.every((m) => m.finishedAt != null), isTrue);
    });

    test('les classements se recalculent quand un nouveau match est enregistré',
        () async {
      final before = asMap(await repo.watch180().first);
      expect(before['Bob'], 1);
      await repo.saveFinishedMatch(FinishedMatchData(
        player1Id: bob,
        player2Id: carl,
        winnerId: bob,
        bestOf: 1,
        turns: [_turn(1, bob, 180), _turn(1, bob, 60, checkout: true)],
      ));
      final after = asMap(await repo.watch180().first);
      expect(after['Bob'], 2);
      expect(after['Alice'], 2);
    });
  });
}
