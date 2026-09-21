// Migration v1 -> v2 : on part d'une vraie base v1 (DDL exact de l'ancien
// schéma, avec des données), on l'ouvre avec le code actuel, et on vérifie que
// les données survivent et que les nouveautés fonctionnent.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:darts/data/database.dart';
import 'package:darts/data/repository.dart';
import 'package:darts/domain/open.dart';

// DDL du schéma v1, tel que généré par Drift avant la v2.
const _v1Schema = [
  'CREATE TABLE "players" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" TEXT NOT NULL, "created_at" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)))',
  'CREATE TABLE "opens" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" TEXT NOT NULL, "location" TEXT NULL, "date" INTEGER NULL, "best_of" INTEGER NOT NULL DEFAULT 5, "format" TEXT NOT NULL DEFAULT \'single_elim\', "status" TEXT NOT NULL DEFAULT \'setup\', "created_at" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)))',
  'CREATE TABLE "matches" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "open_id" INTEGER NULL REFERENCES opens (id), "player1_id" INTEGER NOT NULL REFERENCES players (id), "player2_id" INTEGER NOT NULL REFERENCES players (id), "marker_id" INTEGER NULL REFERENCES players (id), "best_of" INTEGER NOT NULL, "status" TEXT NOT NULL DEFAULT \'pending\', "winner_id" INTEGER NULL REFERENCES players (id), "round" INTEGER NULL, "created_at" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)), "finished_at" INTEGER NULL)',
  'CREATE TABLE "legs" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "match_id" INTEGER NOT NULL REFERENCES matches (id), "leg_number" INTEGER NOT NULL, "starter_id" INTEGER NOT NULL REFERENCES players (id), "winner_id" INTEGER NULL REFERENCES players (id))',
  'CREATE TABLE "turns" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "leg_id" INTEGER NOT NULL REFERENCES legs (id), "player_id" INTEGER NOT NULL REFERENCES players (id), "turn_number" INTEGER NOT NULL, "score" INTEGER NOT NULL, "darts_used" INTEGER NOT NULL DEFAULT 3, "is_bust" INTEGER NOT NULL DEFAULT 0 CHECK ("is_bust" IN (0, 1)), "is_checkout" INTEGER NOT NULL DEFAULT 0 CHECK ("is_checkout" IN (0, 1)))',
];

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
      for (final ddl in _v1Schema) {
        raw.execute(ddl);
      }
      raw.execute("INSERT INTO players (name) VALUES ('Alice'), ('Bob')");
      raw.execute("INSERT INTO opens (name, best_of) VALUES ('Open v1', 3)");
      raw.execute(
          'INSERT INTO matches (player1_id, player2_id, best_of, status, winner_id, finished_at) '
          "VALUES (1, 2, 5, 'finished', 1, 1700000000)");
      raw.execute('PRAGMA user_version = 1');
    }));
  });
  tearDown(() => db.close());

  test('passe en version 2 et crée les nouvelles tables', () async {
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 2);

    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final names = tables.map((r) => r.read<String>('name')).toSet();
    expect(names, containsAll(['open_entries', 'bracket_nodes']));
  });

  test('les données v1 survivent, la nouvelle colonne prend sa valeur par défaut', () async {
    final repo = DriftDartsRepository(db);

    final open = (await repo.watchOpens().first).single;
    expect(open.name, 'Open v1');
    expect(open.bestOf, 3);
    expect(open.status, OpenStatus.setup);
    expect(open.grandFinalReset, isFalse);
    expect(open.entryCount, 0);

    final history = await repo.watchHistory().first;
    expect(history.single.p1, 'Alice');
    expect(history.single.winner, 'Alice');
    expect(await db.select(db.players).get(), hasLength(2));
  });

  test('un open créé en v1 est utilisable avec les fonctions v2', () async {
    final repo = DriftDartsRepository(db);
    final openId = (await repo.watchOpens().first).single.id;

    // Il est en 'single_elim' (défaut SQL v1) : le tableau n'est pas encore
    // disponible pour ce format, mais l'inscription fonctionne.
    final alice = await repo.getOrCreatePlayer('Alice');
    await repo.registerPlayer(openId, alice);
    expect((await repo.watchEntries(openId).first).single.playerName, 'Alice');

    // Et on peut le passer en double élimination avant de démarrer.
    await repo.updateOpen(openId, const NewOpen(name: 'Open v1', bestOf: 3));
    final bob = await repo.getOrCreatePlayer('Bob');
    final carl = await repo.getOrCreatePlayer('Carl');
    await repo.registerPlayer(openId, bob);
    await repo.registerPlayer(openId, carl);
    await repo.shuffleSeeds(openId);
    await repo.generateBracket(openId);
    expect((await repo.watchBracket(openId).first).nodes, hasLength(4)); // 2N − 2
  });

  test('les clés étrangères sont actives après migration', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
  });
}
