// Les clés étrangères SQLite sont un réglage PAR CONNEXION : il faut le refaire
// à chaque ouverture. Il est posé dans MigrationStrategy.beforeOpen, qui
// s'exécute à chaque ouverture de la base (création, migration ou simple
// réouverture). Ces tests le prouvent avec une vraie base sur fichier, rouverte.

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:darts/data/database.dart';

Future<int> _foreignKeysPragma(AppDatabase db) async {
  final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
  return row.read<int>('foreign_keys');
}

void main() {
  test('les clés étrangères sont réellement appliquées (pas seulement le pragma)', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    // Inscription à un open et un joueur qui n'existent pas : doit être refusée.
    await expectLater(
      db.into(db.openEntries).insert(
            OpenEntriesCompanion.insert(openId: 999, playerId: 999),
          ),
      throwsA(anything),
    );
    expect(await db.select(db.openEntries).get(), isEmpty);
  });

  test('réglage refait à CHAQUE ouverture : base sur fichier fermée puis rouverte', () async {
    final dir = await Directory.systemTemp.createTemp('darts_fk_test');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}darts.sqlite');

    for (var ouverture = 1; ouverture <= 3; ouverture++) {
      final db = AppDatabase.forTesting(NativeDatabase(file));
      expect(await _foreignKeysPragma(db), 1, reason: 'ouverture n°$ouverture');
      await expectLater(
        db.into(db.matches).insert(MatchesCompanion.insert(
              player1Id: 404,
              player2Id: 405,
              bestOf: 5,
            )),
        throwsA(anything),
        reason: 'ouverture n°$ouverture : un match sans joueurs doit être refusé',
      );
      await db.close();
    }
  });
}
