// lib/data/database.dart
// Couche de données locale (SQLite via Drift).
// Après avoir collé ce fichier, lance : dart run build_runner build
// pour générer database.g.dart.

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ---------------------------------------------------------------------------
// Tables
// ---------------------------------------------------------------------------
class Players extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Opens extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get location => text().nullable()();
  DateTimeColumn get date => dateTime().nullable()();
  // Best-of PAR DÉFAUT des matchs de l'open : chaque match garde le sien
  // (matches.bestOf), donc un best-of variable par tour reste possible.
  IntColumn get bestOf => integer().withDefault(const Constant(5))();
  // Valeurs : voir OpenFormat. Le défaut SQL ('single_elim') est hérité de la
  // v1 (SQLite ne permet pas de le changer sans reconstruire la table) : le
  // repository fournit toujours le format explicitement (double_elim par défaut).
  TextColumn get format => text().withDefault(const Constant('single_elim'))();
  // Valeurs : voir OpenStatus (setup / running / finished).
  TextColumn get status => text().withDefault(const Constant('setup'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // v2 — double élimination : second match de grande finale si le vainqueur du
  // tableau perdant gagne la première. Désactivé par défaut (finale sèche).
  BoolColumn get grandFinalReset =>
      boolean().withDefault(const Constant(false))();
}

// v2 — inscription d'un joueur à un open.
@DataClassName('OpenEntryRow')
class OpenEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get openId => integer().references(Opens, #id)();
  IntColumn get playerId => integer().references(Players, #id)();
  // Tête de série (1 = meilleure). Null tant que le seeding n'est pas fait.
  IntColumn get seed => integer().nullable()();
  // Place finale, renseignée à la fin de l'open (base de l'Order of Merit).
  IntColumn get finalPlacement => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {openId, playerId},
      ];
}

// v2 — structure du tableau d'un open : une ligne par match À JOUER (les byes
// n'ont pas de case). Le match réellement joué est une ligne de `matches`,
// reliée via matchId. Voir lib/domain/bracket/bracket.dart.
@DataClassName('BracketNodeRow')
class BracketNodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get openId => integer().references(Opens, #id)();
  // Clé lisible et stable : 'W1-3', 'L2-1', 'GF1', 'GF2'.
  TextColumn get nodeKey => text()();
  // BracketSide.name : 'winners' | 'losers' | 'grandFinal'.
  TextColumn get bracket => text()();
  IntColumn get round => integer()();
  IntColumn get position => integer()();
  IntColumn get playerAId => integer().nullable().references(Players, #id)();
  IntColumn get playerBId => integer().nullable().references(Players, #id)();
  // Où vont le vainqueur / le perdant : clé de la case + créneau ('a' | 'b').
  TextColumn get winnerToKey => text().nullable()();
  TextColumn get winnerToSlot => text().nullable()();
  TextColumn get loserToKey => text().nullable()();
  TextColumn get loserToSlot => text().nullable()();
  // NodeStatus.name : 'pending' | 'ready' | 'finished' | 'skipped'.
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get winnerId => integer().nullable().references(Players, #id)();
  IntColumn get markerId => integer().nullable().references(Players, #id)();
  IntColumn get matchId => integer().nullable().references(Matches, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {openId, nodeKey},
      ];
}

// 'Match' est un type de dart:core → on nomme la data class DartMatch.
@DataClassName('DartMatch')
class Matches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get openId => integer().nullable().references(Opens, #id)();
  IntColumn get player1Id => integer().references(Players, #id)();
  IntColumn get player2Id => integer().references(Players, #id)();
  IntColumn get markerId => integer().nullable().references(Players, #id)();
  IntColumn get bestOf => integer()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get winnerId => integer().nullable().references(Players, #id)();
  IntColumn get round => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get finishedAt => dateTime().nullable()();
}

class Legs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get matchId => integer().references(Matches, #id)();
  IntColumn get legNumber => integer()();
  IntColumn get starterId => integer().references(Players, #id)();
  IntColumn get winnerId => integer().nullable().references(Players, #id)();
}

class Turns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get legId => integer().references(Legs, #id)();
  IntColumn get playerId => integer().references(Players, #id)();
  IntColumn get turnNumber => integer()();
  IntColumn get score => integer()();
  IntColumn get dartsUsed => integer().withDefault(const Constant(3))();
  BoolColumn get isBust => boolean().withDefault(const Constant(false))();
  BoolColumn get isCheckout => boolean().withDefault(const Constant(false))();
}

// ---------------------------------------------------------------------------
// DTOs (objets simples, sans dépendance à Drift : réutilisables avec un
// futur backend)
// ---------------------------------------------------------------------------
class TurnData {
  final int legNumber;
  final int playerId;
  final int score;
  final int dartsUsed;
  final bool isBust;
  final bool isCheckout;
  const TurnData({
    required this.legNumber,
    required this.playerId,
    required this.score,
    required this.dartsUsed,
    required this.isBust,
    required this.isCheckout,
  });
}

class FinishedMatchData {
  final int player1Id;
  final int player2Id;
  final int winnerId;
  final int bestOf;
  final List<TurnData> turns;

  // Renseignés quand le match fait partie d'un open (voir reportNodeResult).
  final int? openId;
  final int? round;
  final int? markerId;
  const FinishedMatchData({
    required this.player1Id,
    required this.player2Id,
    required this.winnerId,
    required this.bestOf,
    required this.turns,
    this.openId,
    this.round,
    this.markerId,
  });
}

class Standing {
  final String name;
  final num value;
  const Standing(this.name, this.value);
}

class MatchSummary {
  final String p1;
  final String p2;
  final String? winner;
  final DateTime? finishedAt;
  const MatchSummary(this.p1, this.p2, this.winner, this.finishedAt);
}

// ---------------------------------------------------------------------------
// Base de données
// ---------------------------------------------------------------------------
@DriftDatabase(
    tables: [Players, Opens, Matches, Legs, Turns, OpenEntries, BracketNodes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  /// Pour les tests : base en mémoire (NativeDatabase.memory()).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v1 -> v2 : gestion des opens (inscriptions + tableau).
          if (from < 2) {
            await m.addColumn(opens, opens.grandFinalReset);
            await m.createTable(openEntries);
            await m.createTable(bracketNodes);
          }
        },
        beforeOpen: (details) async {
          // SQLite n'applique les clés étrangères que sur demande.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<int> getOrCreatePlayer(String name) async {
    final existing =
        await (select(players)..where((t) => t.name.equals(name)))
            .getSingleOrNull();
    if (existing != null) return existing.id;
    return into(players).insert(PlayersCompanion.insert(name: name));
  }

  Future<int> saveFinishedMatch(FinishedMatchData data) {
    return transaction(() async {
      final matchId = await into(matches).insert(MatchesCompanion.insert(
        openId: Value(data.openId),
        player1Id: data.player1Id,
        player2Id: data.player2Id,
        markerId: Value(data.markerId),
        bestOf: data.bestOf,
        status: const Value('finished'),
        winnerId: Value(data.winnerId),
        round: Value(data.round),
        finishedAt: Value(DateTime.now()),
      ));

      // Regroupe les volées par leg
      final byLeg = <int, List<TurnData>>{};
      for (final t in data.turns) {
        byLeg.putIfAbsent(t.legNumber, () => []).add(t);
      }
      final legNumbers = byLeg.keys.toList()..sort();

      for (final n in legNumbers) {
        final legTurns = byLeg[n]!;
        final starterId = legTurns.first.playerId;
        int? legWinner;
        for (final t in legTurns) {
          if (t.isCheckout) legWinner = t.playerId;
        }
        final legId = await into(legs).insert(LegsCompanion.insert(
          matchId: matchId,
          legNumber: n,
          starterId: starterId,
          winnerId: Value(legWinner),
        ));
        var turnNo = 1;
        for (final t in legTurns) {
          await into(turns).insert(TurnsCompanion.insert(
            legId: legId,
            playerId: t.playerId,
            turnNumber: turnNo++,
            score: t.score,
            dartsUsed: Value(t.dartsUsed),
            isBust: Value(t.isBust),
            isCheckout: Value(t.isCheckout),
          ));
        }
      }
      return matchId;
    });
  }

  // ----- Classements (SQL réactif : se rafraîchit tout seul) -----
  Stream<List<Standing>> watch180() {
    return customSelect(
      'SELECT p.name AS name, COUNT(*) AS v '
      'FROM turns t JOIN players p ON p.id = t.player_id '
      'WHERE t.score = 180 '
      'GROUP BY p.id ORDER BY v DESC',
      readsFrom: {turns, players},
    ).watch().map((rows) => rows
        .map((r) => Standing(r.read<String>('name'), r.read<int>('v')))
        .toList());
  }

  Stream<List<Standing>> watchAverages() {
    return customSelect(
      'SELECT p.name AS name, '
      'ROUND(CAST(SUM(t.score) AS REAL) / SUM(t.darts_used) * 3, 1) AS v '
      'FROM turns t JOIN players p ON p.id = t.player_id '
      'GROUP BY p.id HAVING SUM(t.darts_used) >= 9 ORDER BY v DESC',
      readsFrom: {turns, players},
    ).watch().map((rows) => rows
        .map((r) => Standing(r.read<String>('name'), r.read<double>('v')))
        .toList());
  }

  Stream<List<Standing>> watchCheckouts() {
    return customSelect(
      'SELECT p.name AS name, MAX(t.score) AS v '
      'FROM turns t JOIN players p ON p.id = t.player_id '
      'WHERE t.is_checkout = 1 '
      'GROUP BY p.id ORDER BY v DESC',
      readsFrom: {turns, players},
    ).watch().map((rows) => rows
        .map((r) => Standing(r.read<String>('name'), r.read<int>('v')))
        .toList());
  }

  Stream<List<MatchSummary>> watchHistory() {
    return customSelect(
      'SELECT p1.name AS p1, p2.name AS p2, w.name AS winner, '
      'm.finished_at AS finished_at '
      'FROM matches m '
      'JOIN players p1 ON p1.id = m.player1_id '
      'JOIN players p2 ON p2.id = m.player2_id '
      'LEFT JOIN players w ON w.id = m.winner_id '
      'ORDER BY m.finished_at DESC',
      readsFrom: {matches, players},
    ).watch().map((rows) => rows
        .map((r) => MatchSummary(
              r.read<String>('p1'),
              r.read<String>('p2'),
              r.readNullable<String>('winner'),
              r.readNullable<DateTime>('finished_at'),
            ))
        .toList());
  }
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'darts.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
