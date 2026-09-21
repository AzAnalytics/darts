// Identité d'un joueur : nom normalisé, casse ignorée (Unicode), accents
// significatifs. Complète test/data/leaderboards_characterization_test.dart, qui
// fige ce qui NE doit PAS changer (même nom -> même id, classements).

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:darts/data/database.dart';
import 'package:darts/data/repository.dart';
import 'package:darts/domain/open_state_exception.dart';

void main() {
  late AppDatabase db;
  late DriftDartsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftDartsRepository(db);
  });
  tearDown(() => db.close());

  Future<List<String>> storedNames() async =>
      [for (final p in await db.select(db.players).get()) p.name];

  group('getOrCreatePlayer : casse ignorée', () {
    test('« jean » retrouve « Jean » (même id, aucun doublon)', () async {
      final first = await repo.getOrCreatePlayer('Jean');
      expect(await repo.getOrCreatePlayer('jean'), first);
      expect(await repo.getOrCreatePlayer('JEAN'), first);
      expect(await repo.getOrCreatePlayer('jEaN'), first);
      expect(await storedNames(), ['Jean']);
    });

    test('le nom enregistré reste celui de la première création', () async {
      await repo.getOrCreatePlayer('Jean');
      await repo.getOrCreatePlayer('jean');
      expect(await storedNames(), ['Jean']);
    });

    test('majuscules accentuées : « éric » retrouve « Éric » (NOCASE SQLite échouerait)',
        () async {
      final eric = await repo.getOrCreatePlayer('Éric');
      expect(await repo.getOrCreatePlayer('éric'), eric);
      expect(await repo.getOrCreatePlayer('ÉRIC'), eric);
      final emile = await repo.getOrCreatePlayer('émile');
      expect(await repo.getOrCreatePlayer('Émile'), emile);
      expect(await storedNames(), ['Éric', 'émile']);
    });

    test('LIMITE ASSUMÉE : les accents restent significatifs', () async {
      final eric = await repo.getOrCreatePlayer('Éric');
      final plain = await repo.getOrCreatePlayer('Eric');
      expect(plain, isNot(eric));
      expect(await storedNames(), ['Éric', 'Eric']);
    });

    test('des noms différents restent des joueurs différents', () async {
      final jean = await repo.getOrCreatePlayer('Jean');
      expect(await repo.getOrCreatePlayer('Jeanne'), isNot(jean));
      expect(await repo.getOrCreatePlayer('Jean D.'), isNot(jean));
      expect(await storedNames(), hasLength(3));
    });
  });

  group('getOrCreatePlayer : normalisation', () {
    test('espaces superflus retirés avant enregistrement et comparaison', () async {
      final id = await repo.getOrCreatePlayer('  Jean   Paul ');
      expect(await storedNames(), ['Jean Paul']);
      expect(await repo.getOrCreatePlayer('jean paul'), id);
      expect(await repo.getOrCreatePlayer('Jean  Paul'), id);
    });

    test('un nom vide ou d\'espaces est refusé', () async {
      for (final name in ['', '   ', '\t']) {
        await expectLater(repo.getOrCreatePlayer(name),
            throwsA(isA<OpenStateException>()),
            reason: '"$name"');
      }
      expect(await storedNames(), isEmpty);
    });
  });

  group('anciens doublons de casse déjà présents en base', () {
    test('« jean » et « Jean » existent : pas de plantage, le plus ancien est renvoyé',
        () async {
      // Situation possible avant ce changement : deux lignes distinctes.
      final oldest = await db
          .into(db.players)
          .insert(PlayersCompanion.insert(name: 'Jean'));
      await db.into(db.players).insert(PlayersCompanion.insert(name: 'jean'));

      expect(await repo.getOrCreatePlayer('JEAN'), oldest);
      expect(await repo.getOrCreatePlayer('jean'), oldest);
      expect(await storedNames(), hasLength(2)); // pas de fusion, pas de création
    });
  });

  group('watchPlayers', () {
    test('tous les joueurs, triés par nom sans tenir compte de la casse', () async {
      for (final n in ['zoé', 'Bob', 'alice', 'Émile', 'Carl']) {
        await repo.getOrCreatePlayer(n);
      }
      final list = await repo.watchPlayers().first;
      expect(list.map((p) => p.name).toList(),
          ['alice', 'Bob', 'Carl', 'Émile', 'zoé']);
    });

    test('expose l\'id de chaque joueur', () async {
      final id = await repo.getOrCreatePlayer('Alice');
      final list = await repo.watchPlayers().first;
      expect(list.single.id, id);
    });

    test('réactif : un joueur créé apparaît dans le flux', () async {
      final seen = <List<String>>[];
      final sub = repo
          .watchPlayers()
          .listen((l) => seen.add(l.map((p) => p.name).toList()));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await repo.getOrCreatePlayer('Alice');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await sub.cancel();
      expect(seen.first, isEmpty);
      expect(seen.last, ['Alice']);
    });

    test('un joueur retrouvé par « jean » n\'ajoute pas de ligne au flux', () async {
      await repo.getOrCreatePlayer('Jean');
      await repo.getOrCreatePlayer('jean');
      expect((await repo.watchPlayers().first).map((p) => p.name), ['Jean']);
    });
  });

  group('classements : un joueur saisi avec une casse différente reste UN joueur', () {
    test('après des matchs sous « Jean » puis « jean », une seule ligne cumulée',
        () async {
      final jean1 = await repo.getOrCreatePlayer('Jean');
      final bob = await repo.getOrCreatePlayer('Bob');
      TurnData t(int p, int score, {bool co = false}) => TurnData(
          legNumber: 1,
          playerId: p,
          score: score,
          dartsUsed: 3,
          isBust: false,
          isCheckout: co);
      await repo.saveFinishedMatch(FinishedMatchData(
        player1Id: jean1,
        player2Id: bob,
        winnerId: jean1,
        bestOf: 1,
        turns: [t(jean1, 180), t(jean1, 100, co: true)],
      ));
      // Le même joueur, saisi en minuscules pour un second match.
      final jean2 = await repo.getOrCreatePlayer('jean');
      expect(jean2, jean1);
      await repo.saveFinishedMatch(FinishedMatchData(
        player1Id: jean2,
        player2Id: bob,
        winnerId: jean2,
        bestOf: 1,
        turns: [t(jean2, 180), t(jean2, 60, co: true)],
      ));

      final s180 = await repo.watch180().first;
      expect(s180.map((s) => s.name), ['Jean']); // une seule ligne
      expect(s180.single.value, 2); // 180 cumulés sur les deux matchs
      final checkouts = await repo.watchCheckouts().first;
      expect(checkouts.single.name, 'Jean');
      expect(checkouts.single.value, 100);
    });
  });
}
