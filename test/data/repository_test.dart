// Repository Drift sur une vraie base SQLite en mémoire : inscriptions, seeding,
// génération du tableau, marqueurs, progression atomique, places finales.
// (La logique de tournoi elle-même est testée sans base dans test/domain.)

import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:darts/data/database.dart';
import 'package:darts/data/repository.dart';
import 'package:darts/domain/bracket/bracket.dart';
import 'package:darts/domain/bracket/double_elimination.dart';
import 'package:darts/domain/open.dart';
import 'package:darts/domain/open_state_exception.dart';

Matcher get _openError => throwsA(isA<OpenStateException>());

void main() {
  late AppDatabase db;
  late DriftDartsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftDartsRepository(db);
  });
  tearDown(() => db.close());

  /// Crée un open avec [n] joueurs J1..Jn inscrits (et classés dans cet ordre).
  Future<({int openId, List<int> players})> newOpen(
    int n, {
    bool reset = false,
    bool seeded = true,
  }) async {
    final openId =
        await repo.createOpen(NewOpen(name: 'Open test', grandFinalReset: reset));
    final players = <int>[];
    for (var i = 1; i <= n; i++) {
      final id = await repo.getOrCreatePlayer('J$i');
      players.add(id);
      await repo.registerPlayer(openId, id);
    }
    if (seeded) await repo.setSeeds(openId, players);
    return (openId: openId, players: players);
  }

  Future<Bracket> bracketOf(int openId) => repo.watchBracket(openId).first;

  /// Joue une case : [winner] gagne, avec un 180 et un checkout dans ses volées.
  Future<int> playNode(BracketNode node, int winner) {
    return repo.reportNodeResult(
      node.id!,
      FinishedMatchData(
        player1Id: node.playerA!,
        player2Id: node.playerB!,
        winnerId: winner,
        bestOf: 5,
        turns: [
          TurnData(
              legNumber: 1,
              playerId: winner,
              score: 180,
              dartsUsed: 3,
              isBust: false,
              isCheckout: false),
          TurnData(
              legNumber: 1,
              playerId: winner,
              score: 141,
              dartsUsed: 3,
              isBust: false,
              isCheckout: true),
        ],
      ),
    );
  }

  test('les clés étrangères sont activées', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
  });

  group('Création et gestion d\'un open', () {
    test('valeurs par défaut : double élimination, finale sèche', () async {
      final id = await repo.createOpen(const NewOpen(name: '  Open de printemps  '));
      final open = (await repo.watchOpen(id).first)!;
      expect(open.name, 'Open de printemps');
      expect(open.format, OpenFormat.doubleElim);
      expect(open.grandFinalReset, isFalse);
      expect(open.bestOf, 5);
      expect(open.status, OpenStatus.setup);
      expect(open.entryCount, 0);
      expect(open.location, isNull);
      expect(open.date, isNull);
    });

    test('lieu, date, reset activable', () async {
      final date = DateTime(2026, 10, 3, 14);
      final id = await repo.createOpen(NewOpen(
        name: 'Open',
        location: ' Salle des fêtes ',
        date: date,
        bestOf: 3,
        grandFinalReset: true,
      ));
      final open = (await repo.watchOpen(id).first)!;
      expect(open.location, 'Salle des fêtes');
      expect(open.date, date);
      expect(open.bestOf, 3);
      expect(open.grandFinalReset, isTrue);
    });

    test('refuse un nom vide, un best-of pair, un format inconnu', () async {
      await expectLater(repo.createOpen(const NewOpen(name: '   ')), _openError);
      await expectLater(
          repo.createOpen(const NewOpen(name: 'x', bestOf: 4)), _openError);
      await expectLater(
          repo.createOpen(const NewOpen(name: 'x', bestOf: 0)), _openError);
      await expectLater(
          repo.createOpen(const NewOpen(name: 'x', format: 'pyramide')), _openError);
    });

    test('watchOpens : compte les inscrits, du plus récent au plus ancien', () async {
      final old = await repo.createOpen(NewOpen(name: 'Ancien', date: DateTime(2026, 1, 1)));
      final recent = await repo.createOpen(NewOpen(name: 'Récent', date: DateTime(2026, 6, 1)));
      final undated = await repo.createOpen(const NewOpen(name: 'Sans date'));
      await repo.registerPlayer(recent, await repo.getOrCreatePlayer('A'));
      final list = await repo.watchOpens().first;
      expect(list.map((o) => o.id).toList(), [recent, old, undated]);
      expect(list.first.entryCount, 1);
    });

    test('modification et suppression tant que l\'open n\'a pas démarré', () async {
      final id = await repo.createOpen(const NewOpen(name: 'Avant'));
      await repo.updateOpen(id, const NewOpen(name: 'Après', bestOf: 7));
      final open = (await repo.watchOpen(id).first)!;
      expect(open.name, 'Après');
      expect(open.bestOf, 7);

      await repo.registerPlayer(id, await repo.getOrCreatePlayer('A'));
      await repo.deleteOpen(id);
      expect(await repo.watchOpen(id).first, isNull);
      expect(await db.select(db.openEntries).get(), isEmpty);
    });

    test('plus modifiable ni supprimable une fois démarré', () async {
      final o = await newOpen(4);
      await repo.generateBracket(o.openId);
      await expectLater(repo.updateOpen(o.openId, const NewOpen(name: 'x')), _openError);
      await expectLater(repo.deleteOpen(o.openId), _openError);
    });

    test('open introuvable', () async {
      await expectLater(repo.registerPlayer(999, 1), _openError);
      await expectLater(repo.generateBracket(999), _openError);
    });
  });

  group('Inscriptions et seeding', () {
    test('inscription, doublon refusé, watchEntries avec noms', () async {
      final o = await newOpen(3, seeded: false);
      await expectLater(repo.registerPlayer(o.openId, o.players[0]), _openError);
      final entries = await repo.watchEntries(o.openId).first;
      expect(entries.map((e) => e.playerName).toSet(), {'J1', 'J2', 'J3'});
      expect(entries.every((e) => e.seed == null), isTrue);
    });

    test('setSeeds classe les joueurs, watchEntries les renvoie dans l\'ordre', () async {
      final o = await newOpen(4, seeded: false);
      await repo.setSeeds(o.openId, o.players.reversed.toList());
      final entries = await repo.watchEntries(o.openId).first;
      expect(entries.map((e) => e.playerName).toList(), ['J4', 'J3', 'J2', 'J1']);
      expect(entries.map((e) => e.seed).toList(), [1, 2, 3, 4]);
    });

    test('setSeeds refuse un classement incomplet, en double ou étranger', () async {
      final o = await newOpen(3, seeded: false);
      final stranger = await repo.getOrCreatePlayer('Étranger');
      await expectLater(repo.setSeeds(o.openId, o.players.sublist(0, 2)), _openError);
      await expectLater(
          repo.setSeeds(o.openId, [o.players[0], o.players[0], o.players[1]]), _openError);
      await expectLater(
          repo.setSeeds(o.openId, [o.players[0], o.players[1], stranger]), _openError);
    });

    test('shuffleSeeds : permutation valide, reproductible avec la même graine', () async {
      final o = await newOpen(8, seeded: false);
      await repo.shuffleSeeds(o.openId, random: Random(7));
      final first = await repo.watchEntries(o.openId).first;
      expect(first.map((e) => e.seed).toList(), [1, 2, 3, 4, 5, 6, 7, 8]);
      expect(first.map((e) => e.playerId).toSet(), o.players.toSet());

      final orderA = first.map((e) => e.playerId).toList();
      await repo.shuffleSeeds(o.openId, random: Random(7));
      final orderB = (await repo.watchEntries(o.openId).first).map((e) => e.playerId).toList();
      expect(orderB, orderA);
    });

    test('désinscription : les têtes de série restent contiguës', () async {
      final o = await newOpen(4);
      await repo.unregisterPlayer(o.openId, o.players[1]); // J2 (tête de série 2)
      final entries = await repo.watchEntries(o.openId).first;
      expect(entries.map((e) => e.playerName).toList(), ['J1', 'J3', 'J4']);
      expect(entries.map((e) => e.seed).toList(), [1, 2, 3]);
    });

    test('inscriptions closes une fois le tableau généré', () async {
      final o = await newOpen(4);
      await repo.generateBracket(o.openId);
      final late = await repo.getOrCreatePlayer('Retardataire');
      await expectLater(repo.registerPlayer(o.openId, late), _openError);
      await expectLater(repo.unregisterPlayer(o.openId, o.players[0]), _openError);
      await expectLater(repo.setSeeds(o.openId, o.players), _openError);
    });
  });

  group('Génération du tableau', () {
    test('refuse moins de 3 joueurs', () async {
      final o = await newOpen(2);
      await expectLater(repo.generateBracket(o.openId), _openError);
    });

    test('refuse des têtes de série incomplètes', () async {
      final o = await newOpen(4, seeded: false);
      await expectLater(repo.generateBracket(o.openId), _openError);
      // Un joueur ajouté après le seeding casse aussi la complétude.
      await repo.setSeeds(o.openId, o.players);
      await repo.registerPlayer(o.openId, await repo.getOrCreatePlayer('J5'));
      await expectLater(repo.generateBracket(o.openId), _openError);
    });

    test('génère 2N − 2 cases, l\'open passe en running', () async {
      final o = await newOpen(6);
      await repo.generateBracket(o.openId);
      final bracket = await bracketOf(o.openId);
      expect(bracket.nodes.length, 2 * 6 - 2);
      expect(bracket.nodes.every((n) => n.id != null), isTrue);
      expect((await repo.watchOpen(o.openId).first)!.status, OpenStatus.running);
      // Les têtes de série 1 et 2 ont un bye : elles ne sont pas au premier tour.
      final firstRoundPlayers = [
        for (final n in bracket.nodes.where((n) => n.round == 1 && n.side == BracketSide.winners))
          ...[n.playerA, n.playerB],
      ];
      expect(firstRoundPlayers, isNot(contains(o.players[0])));
      expect(firstRoundPlayers, isNot(contains(o.players[1])));
      expect(bracket.readyNodes, isNotEmpty);
    });

    test('le reset de la grande finale est repris de l\'open', () async {
      final sans = await newOpen(5);
      final avec = await newOpen(5, reset: true);
      await repo.generateBracket(sans.openId);
      await repo.generateBracket(avec.openId);
      expect((await bracketOf(sans.openId)).hasGrandFinalReset, isFalse);
      expect((await bracketOf(avec.openId)).hasGrandFinalReset, isTrue);
    });

    test('impossible de générer deux fois', () async {
      final o = await newOpen(4);
      await repo.generateBracket(o.openId);
      await expectLater(repo.generateBracket(o.openId), _openError);
    });

    test('annulation du tableau avant tout match, puis nouvelle génération', () async {
      final o = await newOpen(5);
      await repo.generateBracket(o.openId);
      await repo.resetBracket(o.openId);
      expect((await bracketOf(o.openId)).nodes, isEmpty);
      expect((await repo.watchOpen(o.openId).first)!.status, OpenStatus.setup);
      await repo.registerPlayer(o.openId, await repo.getOrCreatePlayer('J6'));
      await repo.shuffleSeeds(o.openId, random: Random(1));
      await repo.generateBracket(o.openId);
      expect((await bracketOf(o.openId)).nodes.length, 2 * 6 - 2);
    });

    test('annulation refusée si aucun tableau ou si un match est joué', () async {
      final o = await newOpen(4);
      await expectLater(repo.resetBracket(o.openId), _openError);
      await repo.generateBracket(o.openId);
      final ready = (await bracketOf(o.openId)).readyNodes.first;
      await repo.reportWalkover(ready.id!, ready.playerA!);
      await expectLater(repo.resetBracket(o.openId), _openError);
    });
  });

  group('Marqueur', () {
    test('assignation, changement, retrait', () async {
      final o = await newOpen(5);
      await repo.generateBracket(o.openId);
      final node = (await bracketOf(o.openId)).readyNodes.first; // 4 contre 5
      final marker = o.players[0];
      await repo.assignMarker(node.id!, marker);
      expect((await bracketOf(o.openId)).nodeAt(node.key).markerId, marker);
      await repo.assignMarker(node.id!, o.players[1]);
      expect((await bracketOf(o.openId)).nodeAt(node.key).markerId, o.players[1]);
      await repo.assignMarker(node.id!, null);
      expect((await bracketOf(o.openId)).nodeAt(node.key).markerId, isNull);
    });

    test('un joueur ne marque jamais son propre match', () async {
      final o = await newOpen(5);
      await repo.generateBracket(o.openId);
      final node = (await bracketOf(o.openId)).readyNodes.first;
      await expectLater(repo.assignMarker(node.id!, node.playerA), _openError);
      await expectLater(repo.assignMarker(node.id!, node.playerB), _openError);
    });

    test('le marqueur doit être inscrit à l\'open', () async {
      final o = await newOpen(5);
      await repo.generateBracket(o.openId);
      final node = (await bracketOf(o.openId)).readyNodes.first;
      final stranger = await repo.getOrCreatePlayer('Étranger');
      await expectLater(repo.assignMarker(node.id!, stranger), _openError);
    });

    test('marqueur retiré automatiquement s\'il rejoint le match qu\'il devait marquer', () async {
      final o = await newOpen(4);
      await repo.generateBracket(o.openId);
      var b = await bracketOf(o.openId);
      // J2 est désigné marqueur de la finale du tableau gagnant (adversaires inconnus).
      await repo.assignMarker(b.nodeAt('W2-1').id!, o.players[1]);
      await playNode(b.nodeAt('W1-1'), o.players[0]);
      await playNode((await bracketOf(o.openId)).nodeAt('W1-2'), o.players[1]);
      b = await bracketOf(o.openId);
      expect(b.nodeAt('W2-1').playerB, o.players[1]);
      expect(b.nodeAt('W2-1').markerId, isNull);
    });

    test('marqueur retiré automatiquement : le match se joue quand même, sans marqueur', () async {
      final o = await newOpen(4);
      await repo.generateBracket(o.openId);
      await repo.assignMarker((await bracketOf(o.openId)).nodeAt('W2-1').id!, o.players[1]);
      await playNode((await bracketOf(o.openId)).nodeAt('W1-1'), o.players[0]);
      await playNode((await bracketOf(o.openId)).nodeAt('W1-2'), o.players[1]);

      final finale = (await bracketOf(o.openId)).nodeAt('W2-1');
      expect(finale.markerId, isNull);
      expect(finale.status, NodeStatus.ready);

      // Jouable et enregistrable sans marqueur ; le tableau avance normalement.
      final matchId = await playNode(finale, o.players[0]);
      final match = await (db.select(db.matches)..where((t) => t.id.equals(matchId))).getSingle();
      expect(match.markerId, isNull);
      expect((await bracketOf(o.openId)).nodeAt('GF1').playerA, o.players[0]);
    });

    test('marqueur non modifiable sur un match terminé', () async {
      final o = await newOpen(5);
      await repo.generateBracket(o.openId);
      final node = (await bracketOf(o.openId)).readyNodes.first;
      await playNode(node, node.playerA!);
      await expectLater(repo.assignMarker(node.id!, o.players[0]), _openError);
    });

    test('le marqueur est enregistré dans le match joué', () async {
      final o = await newOpen(5);
      await repo.generateBracket(o.openId);
      final node = (await bracketOf(o.openId)).readyNodes.first;
      await repo.assignMarker(node.id!, o.players[0]);
      final matchId = await playNode(node, node.playerA!);
      final match = await (db.select(db.matches)..where((t) => t.id.equals(matchId))).getSingle();
      expect(match.markerId, o.players[0]);
    });
  });

  group('Progression d\'un match', () {
    test('le résultat enregistre le match (avec open et tour) et fait avancer le tableau', () async {
      final o = await newOpen(4);
      await repo.generateBracket(o.openId);
      final node = (await bracketOf(o.openId)).nodeAt('W1-1'); // J1 contre J4
      final matchId = await playNode(node, o.players[0]);

      final match = await (db.select(db.matches)..where((t) => t.id.equals(matchId))).getSingle();
      expect(match.openId, o.openId);
      expect(match.round, 1);
      expect(match.winnerId, o.players[0]);
      expect(match.status, 'finished');

      final b = await bracketOf(o.openId);
      expect(b.nodeAt('W1-1').status, NodeStatus.finished);
      expect(b.nodeAt('W1-1').matchId, matchId);
      expect(b.nodeAt('W1-1').winnerId, o.players[0]);
      expect(b.nodeAt('W2-1').playerA, o.players[0]);
      expect(b.nodeAt('L1-1').playerA, o.players[3]);
    });

    test('les statistiques du match alimentent les classements existants', () async {
      final o = await newOpen(4);
      await repo.generateBracket(o.openId);
      final node = (await bracketOf(o.openId)).nodeAt('W1-1');
      await playNode(node, o.players[0]);
      final s180 = await repo.watch180().first;
      expect(s180.single.name, 'J1');
      expect(s180.single.value, 1);
      final history = await repo.watchHistory().first;
      expect(history.single.winner, 'J1');
    });

    test('forfait : le tableau avance sans match ni statistiques', () async {
      final o = await newOpen(4);
      await repo.generateBracket(o.openId);
      final node = (await bracketOf(o.openId)).nodeAt('W1-1');
      await repo.reportWalkover(node.id!, o.players[0]);
      final b = await bracketOf(o.openId);
      expect(b.nodeAt('W1-1').status, NodeStatus.finished);
      expect(b.nodeAt('W1-1').matchId, isNull);
      expect(b.nodeAt('W2-1').playerA, o.players[0]);
      expect(await db.select(db.matches).get(), isEmpty);
    });

    test('refus : case pas prête, déjà jouée, mauvais joueurs, mauvais vainqueur', () async {
      final o = await newOpen(4);
      await repo.generateBracket(o.openId);
      final b = await bracketOf(o.openId);
      final w11 = b.nodeAt('W1-1');
      final w21 = b.nodeAt('W2-1'); // pas prête

      await expectLater(repo.reportWalkover(w21.id!, o.players[0]), _openError);

      // Mauvais joueurs dans le match saisi
      await expectLater(
        repo.reportNodeResult(
          w11.id!,
          FinishedMatchData(
              player1Id: o.players[1],
              player2Id: o.players[2],
              winnerId: o.players[1],
              bestOf: 5,
              turns: const []),
        ),
        _openError,
      );

      // Vainqueur qui ne joue pas dans la case
      await expectLater(repo.reportWalkover(w11.id!, o.players[2]), _openError);

      // Déjà jouée
      await playNode(w11, o.players[0]);
      await expectLater(repo.reportWalkover(w11.id!, o.players[3]), _openError);
    });

    test('atomicité : un résultat refusé n\'enregistre AUCUN match', () async {
      final o = await newOpen(4);
      await repo.generateBracket(o.openId);
      final node = (await bracketOf(o.openId)).nodeAt('W1-1');
      // Les deux joueurs sont les bons, mais le vainqueur annoncé est étranger :
      // refusé par le moteur APRÈS l'écriture du match -> tout doit être annulé.
      await expectLater(
        repo.reportNodeResult(
          node.id!,
          FinishedMatchData(
            player1Id: node.playerA!,
            player2Id: node.playerB!,
            winnerId: o.players[2],
            bestOf: 5,
            turns: const [],
          ),
        ),
        _openError,
      );
      expect(await db.select(db.matches).get(), isEmpty);
      expect(await db.select(db.legs).get(), isEmpty);
      expect((await bracketOf(o.openId)).nodeAt('W1-1').status, NodeStatus.ready);
    });

    test('refus si l\'open n\'est pas en cours', () async {
      final o = await newOpen(4);
      await repo.generateBracket(o.openId);
      final node = (await bracketOf(o.openId)).nodeAt('W1-1');
      await repo.resetBracket(o.openId);
      await expectLater(repo.reportWalkover(node.id!, o.players[0]), _openError);
    });
  });

  group('Un open de bout en bout (4 joueurs)', () {
    test('sans reset : places finales enregistrées, open terminé', () async {
      final o = await newOpen(4);
      final p = o.players;
      await repo.generateBracket(o.openId);

      Future<void> play(String key, int winner) async =>
          playNode((await bracketOf(o.openId)).nodeAt(key), winner);

      await play('W1-1', p[0]);
      await play('W1-2', p[1]);
      await play('W2-1', p[0]);
      await play('L1-1', p[2]);
      await play('L2-1', p[1]);
      expect((await repo.watchOpen(o.openId).first)!.status, OpenStatus.running);
      await play('GF1', p[0]);

      expect((await repo.watchOpen(o.openId).first)!.status, OpenStatus.finished);
      final entries = await repo.watchEntries(o.openId).first;
      expect({for (final e in entries) e.playerId: e.finalPlacement},
          {p[0]: 1, p[1]: 2, p[2]: 3, p[3]: 4});
      expect(await db.select(db.matches).get(), hasLength(6)); // 2N − 2
    });

    test('avec reset : GF2 joué quand le champion du tableau perdant gagne GF1', () async {
      final o = await newOpen(4, reset: true);
      final p = o.players;
      await repo.generateBracket(o.openId);

      Future<void> play(String key, int winner) async =>
          playNode((await bracketOf(o.openId)).nodeAt(key), winner);

      await play('W1-1', p[0]);
      await play('W1-2', p[1]);
      await play('W2-1', p[0]);
      await play('L1-1', p[2]);
      await play('L2-1', p[1]);
      await play('GF1', p[1]); // le tableau perdant gagne : reset
      expect((await repo.watchOpen(o.openId).first)!.status, OpenStatus.running);
      final gf2 = (await bracketOf(o.openId)).nodeAt('GF2');
      expect(gf2.status, NodeStatus.ready);
      await play('GF2', p[0]);

      expect((await repo.watchOpen(o.openId).first)!.status, OpenStatus.finished);
      final entries = await repo.watchEntries(o.openId).first;
      expect({for (final e in entries) e.playerId: e.finalPlacement},
          {p[0]: 1, p[1]: 2, p[2]: 3, p[3]: 4});
      expect(await db.select(db.matches).get(), hasLength(7)); // 2N − 1
    });
  });

  group('Places finales persistées', () {
    // Base de l'Order of Merit : open_entries.final_placement.
    test('8 joueurs : 1er, 2e, 3e, 4e puis ex æquo par tour d\'élimination (5-5, 7-7)', () async {
      final o = await newOpen(8);
      await repo.generateBracket(o.openId);

      // Aucune place avant la fin.
      expect((await repo.watchEntries(o.openId).first).every((e) => e.finalPlacement == null), isTrue);

      // Le mieux classé (tête de série la plus basse) gagne toujours.
      while ((await repo.watchOpen(o.openId).first)!.status != OpenStatus.finished) {
        final node = (await bracketOf(o.openId)).readyNodes.first;
        final winner = o.players.indexOf(node.playerA!) < o.players.indexOf(node.playerB!)
            ? node.playerA!
            : node.playerB!;
        await playNode(node, winner);
      }

      final entries = await repo.watchEntries(o.openId).first;
      final byPlayer = {for (final e in entries) e.playerId: e.finalPlacement};
      expect(
        [for (final p in o.players) byPlayer[p]],
        [1, 2, 3, 4, 5, 5, 7, 7],
      );
    });

    test('toute la table est exploitable : pas de trou, ex æquo à la meilleure place', () async {
      // 6 joueurs (avec byes) : la place d'un joueur = 1 + nombre de joueurs
      // strictement mieux classés, donc les ex æquo se suivent d'un « saut ».
      final o = await newOpen(6);
      await repo.generateBracket(o.openId);
      final random = Random(3);
      while ((await repo.watchOpen(o.openId).first)!.status != OpenStatus.finished) {
        final ready = (await bracketOf(o.openId)).readyNodes.toList();
        final node = ready[random.nextInt(ready.length)];
        await playNode(node, random.nextBool() ? node.playerA! : node.playerB!);
      }
      final places = [
        for (final e in await repo.watchEntries(o.openId).first) e.finalPlacement!,
      ];
      expect(places.length, 6);
      expect(places.where((p) => p == 1), hasLength(1));
      expect(places.where((p) => p == 2), hasLength(1));
      for (final p in places) {
        expect(places.where((q) => q < p).length, p - 1, reason: 'place $p');
      }
    });
  });

  group('Opens complets simulés à travers le repository', () {
    // Même invariant que la simulation pure, mais la persistance en plus :
    // matchs enregistrés = 2N − 2 (+1 si GF2 joué), places finales cohérentes.
    for (final n in [3, 5, 6, 8, 11, 16]) {
      for (final reset in [false, true]) {
        test('N = $n, reset = $reset', () async {
          final o = await newOpen(n, reset: reset);
          await repo.generateBracket(o.openId);

          final random = Random(n);
          var guard = 0;
          while ((await repo.watchOpen(o.openId).first)!.status != OpenStatus.finished) {
            expect(guard++, lessThan(4 * n), reason: 'boucle infinie ?');
            final ready = (await bracketOf(o.openId)).readyNodes.toList();
            expect(ready, isNotEmpty, reason: 'tableau bloqué');
            final node = ready[random.nextInt(ready.length)];
            await playNode(node, random.nextBool() ? node.playerA! : node.playerB!);
          }

          final b = await bracketOf(o.openId);
          final gf2Played = b.nodeByKey('GF2')?.status == NodeStatus.finished;
          final matches = await db.select(db.matches).get();
          expect(matches.length, 2 * n - 2 + (gf2Played ? 1 : 0));
          expect(matches.every((m) => m.openId == o.openId), isTrue);

          // Les places persistées sont celles calculées par le domaine pur.
          final expected = const DoubleEliminationFormat().placements(b);
          final entries = await repo.watchEntries(o.openId).first;
          expect({for (final e in entries) e.playerId: e.finalPlacement}, expected);
          expect(expected[b.championId], 1);
        });
      }
    }
  });
}
