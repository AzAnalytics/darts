// lib/data/open_store.dart
// Persistance Drift des opens : inscriptions, seeding, tableau, progression.
// Toute la logique de tournoi (génération, byes, avancement, places) vit dans
// lib/domain/bracket/ (pur, testé sans base) : ce fichier ne fait que charger
// l'état, appeler le domaine, et enregistrer le résultat DANS UNE TRANSACTION.
// Les widgets n'y touchent jamais : ils passent par DartsRepository.

import 'dart:math';

import 'package:drift/drift.dart';

import '../domain/bracket/bracket.dart';
import '../domain/bracket/bracket_engine.dart';
import '../domain/bracket/bracket_formats.dart';
import '../domain/bracket/seeding.dart';
import '../domain/open.dart';
import '../domain/open_state_exception.dart';
import 'database.dart';

class OpenStore {
  final AppDatabase db;
  final BracketEngine _engine = const BracketEngine();

  OpenStore(this.db);

  // -------------------------------------------------------------------------
  // Opens
  // -------------------------------------------------------------------------
  Future<int> createOpen(NewOpen data) async {
    _validate(data);
    return db.into(db.opens).insert(OpensCompanion.insert(
          name: data.name.trim(),
          location: Value(_blankToNull(data.location)),
          date: Value(data.date),
          bestOf: Value(data.bestOf),
          format: Value(data.format),
          grandFinalReset: Value(data.grandFinalReset),
        ));
  }

  Future<void> updateOpen(int openId, NewOpen data) async {
    _validate(data);
    await db.transaction(() async {
      await _requireSetup(openId, 'Cet open a déjà démarré : il n\'est plus modifiable.');
      await (db.update(db.opens)..where((t) => t.id.equals(openId))).write(
        OpensCompanion(
          name: Value(data.name.trim()),
          location: Value(_blankToNull(data.location)),
          date: Value(data.date),
          bestOf: Value(data.bestOf),
          format: Value(data.format),
          grandFinalReset: Value(data.grandFinalReset),
        ),
      );
    });
  }

  Future<void> deleteOpen(int openId) async {
    await db.transaction(() async {
      await _requireSetup(openId, 'Cet open a déjà démarré : il ne peut plus être supprimé.');
      await (db.delete(db.openEntries)..where((t) => t.openId.equals(openId))).go();
      await (db.delete(db.opens)..where((t) => t.id.equals(openId))).go();
    });
  }

  static const _openSelect =
      'SELECT o.id AS id, o.name AS name, o.location AS location, '
      'o.date AS date, o.best_of AS best_of, o.format AS format, '
      'o.grand_final_reset AS grand_final_reset, o.status AS status, '
      '(SELECT COUNT(*) FROM open_entries e WHERE e.open_id = o.id) '
      'AS entry_count FROM opens o';

  Stream<List<OpenSummary>> watchOpens() {
    return db
        .customSelect(
          '$_openSelect ORDER BY o.date IS NULL, o.date DESC, o.id DESC',
          readsFrom: {db.opens, db.openEntries},
        )
        .watch()
        .map((rows) => rows.map(_toSummary).toList());
  }

  Stream<OpenSummary?> watchOpen(int openId) {
    return db
        .customSelect(
          '$_openSelect WHERE o.id = ?',
          variables: [Variable.withInt(openId)],
          readsFrom: {db.opens, db.openEntries},
        )
        .watchSingleOrNull()
        .map((row) => row == null ? null : _toSummary(row));
  }

  // -------------------------------------------------------------------------
  // Inscriptions et seeding
  // -------------------------------------------------------------------------
  Future<void> registerPlayer(int openId, int playerId) async {
    await db.transaction(() async {
      await _requireSetup(openId, 'Les inscriptions sont closes : le tableau est déjà généré.');
      final existing = await (db.select(db.openEntries)
            ..where((t) => t.openId.equals(openId) & t.playerId.equals(playerId)))
          .getSingleOrNull();
      if (existing != null) {
        throw const OpenStateException('Ce joueur est déjà inscrit.');
      }
      await db.into(db.openEntries).insert(
            OpenEntriesCompanion.insert(openId: openId, playerId: playerId),
          );
    });
  }

  Future<void> unregisterPlayer(int openId, int playerId) async {
    await db.transaction(() async {
      await _requireSetup(openId, 'Les inscriptions sont closes : le tableau est déjà généré.');
      final entry = await (db.select(db.openEntries)
            ..where((t) => t.openId.equals(openId) & t.playerId.equals(playerId)))
          .getSingleOrNull();
      if (entry == null) return;
      await (db.delete(db.openEntries)..where((t) => t.id.equals(entry.id))).go();
      // Garde les têtes de série contiguës (1..N) : on comble le trou.
      final seed = entry.seed;
      if (seed != null) {
        await db.customUpdate(
          'UPDATE open_entries SET seed = seed - 1 '
          'WHERE open_id = ? AND seed > ?',
          variables: [Variable.withInt(openId), Variable.withInt(seed)],
          updates: {db.openEntries},
        );
      }
    });
  }

  /// Seeding manuel : [playerIdsBySeed] classe TOUS les inscrits (index 0 =
  /// tête de série 1).
  Future<void> setSeeds(int openId, List<int> playerIdsBySeed) async {
    await db.transaction(() async {
      await _requireSetup(openId, 'Le tableau est déjà généré : les têtes de série sont figées.');
      final entries = await (db.select(db.openEntries)
            ..where((t) => t.openId.equals(openId)))
          .get();
      final registered = entries.map((e) => e.playerId).toSet();
      if (playerIdsBySeed.length != registered.length ||
          playerIdsBySeed.toSet().length != playerIdsBySeed.length ||
          !registered.containsAll(playerIdsBySeed)) {
        throw const OpenStateException(
            'Le classement doit contenir exactement les joueurs inscrits, une fois chacun.');
      }
      for (var i = 0; i < playerIdsBySeed.length; i++) {
        await (db.update(db.openEntries)
              ..where((t) =>
                  t.openId.equals(openId) & t.playerId.equals(playerIdsBySeed[i])))
            .write(OpenEntriesCompanion(seed: Value(i + 1)));
      }
    });
  }

  /// Seeding aléatoire. [random] est injectable pour les tests.
  Future<void> shuffleSeeds(int openId, {Random? random}) async {
    await db.transaction(() async {
      final entries = await (db.select(db.openEntries)
            ..where((t) => t.openId.equals(openId)))
          .get();
      await setSeeds(
        openId,
        shuffledSeeds(entries.map((e) => e.playerId), random ?? Random()),
      );
    });
  }

  Stream<List<OpenEntry>> watchEntries(int openId) {
    return db
        .customSelect(
          'SELECT e.player_id AS player_id, p.name AS name, e.seed AS seed, '
          'e.final_placement AS final_placement '
          'FROM open_entries e JOIN players p ON p.id = e.player_id '
          'WHERE e.open_id = ? '
          'ORDER BY e.seed IS NULL, e.seed, p.name COLLATE NOCASE',
          variables: [Variable.withInt(openId)],
          readsFrom: {db.openEntries, db.players},
        )
        .watch()
        .map((rows) => rows
            .map((r) => OpenEntry(
                  playerId: r.read<int>('player_id'),
                  playerName: r.read<String>('name'),
                  seed: r.readNullable<int>('seed'),
                  finalPlacement: r.readNullable<int>('final_placement'),
                ))
            .toList());
  }

  // -------------------------------------------------------------------------
  // Tableau
  // -------------------------------------------------------------------------
  Future<void> generateBracket(int openId) async {
    await db.transaction(() async {
      final open = await _requireSetup(openId, 'Le tableau de cet open est déjà généré.');
      final format = BracketFormats.byId(open.format);

      final entries = await (db.select(db.openEntries)
            ..where((t) => t.openId.equals(openId)))
          .get();
      final n = entries.length;
      if (n < format.minPlayers) {
        throw OpenStateException(
            'Il faut au moins ${format.minPlayers} joueurs inscrits ($n actuellement).');
      }
      final seeds = entries.map((e) => e.seed).toList();
      if (seeds.contains(null) ||
          seeds.toSet().length != n ||
          !seeds.toSet().containsAll(List.generate(n, (i) => i + 1))) {
        throw const OpenStateException(
            'Les têtes de série ne sont pas toutes définies : classez les joueurs ou faites le tirage au sort.');
      }
      entries.sort((a, b) => a.seed!.compareTo(b.seed!));

      final bracket = format.generate(
        entries.map((e) => e.playerId).toList(),
        BracketConfig(grandFinalReset: open.grandFinalReset),
      );
      for (final node in bracket.nodes) {
        await db.into(db.bracketNodes).insert(BracketNodesCompanion.insert(
              openId: openId,
              nodeKey: node.key,
              bracket: node.side.name,
              round: node.round,
              position: node.position,
              playerAId: Value(node.playerA),
              playerBId: Value(node.playerB),
              winnerToKey: Value(node.winnerTo?.nodeKey),
              winnerToSlot: Value(node.winnerTo?.slot.name),
              loserToKey: Value(node.loserTo?.nodeKey),
              loserToSlot: Value(node.loserTo?.slot.name),
              status: Value(node.status.name),
            ));
      }
      await _setOpenStatus(openId, OpenStatus.running);
    });
  }

  /// Annule le tableau (retour aux inscriptions) tant qu'aucun match n'est joué.
  Future<void> resetBracket(int openId) async {
    await db.transaction(() async {
      final open = await _requireOpen(openId);
      if (open.status != OpenStatus.running) {
        throw const OpenStateException('Aucun tableau à annuler pour cet open.');
      }
      final played = await (db.select(db.bracketNodes)
            ..where((t) =>
                t.openId.equals(openId) &
                t.status.equals(NodeStatus.finished.name)))
          .get();
      if (played.isNotEmpty) {
        throw const OpenStateException(
            'Des matchs ont déjà été joués : le tableau ne peut plus être annulé.');
      }
      await (db.delete(db.bracketNodes)..where((t) => t.openId.equals(openId))).go();
      await _setOpenStatus(openId, OpenStatus.setup);
    });
  }

  Stream<Bracket> watchBracket(int openId) {
    return (db.select(db.bracketNodes)
          ..where((t) => t.openId.equals(openId))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .watch()
        .map((rows) => Bracket(rows.map(_toNode)));
  }

  // -------------------------------------------------------------------------
  // Marqueur
  // -------------------------------------------------------------------------
  Future<void> assignMarker(int nodeId, int? markerId) async {
    await db.transaction(() async {
      final row = await _requireNodeRow(nodeId);
      final status = row.status;
      if (status == NodeStatus.finished.name || status == NodeStatus.skipped.name) {
        throw const OpenStateException(
            'Ce match est terminé : on ne peut plus changer son marqueur.');
      }
      if (markerId != null) {
        if (markerId == row.playerAId || markerId == row.playerBId) {
          throw const OpenStateException(
              'Un joueur ne peut pas marquer son propre match.');
        }
        final registered = await (db.select(db.openEntries)
              ..where((t) => t.openId.equals(row.openId) & t.playerId.equals(markerId)))
            .getSingleOrNull();
        if (registered == null) {
          throw const OpenStateException(
              'Le marqueur doit être un joueur inscrit à l\'open.');
        }
      }
      await (db.update(db.bracketNodes)..where((t) => t.id.equals(nodeId)))
          .write(BracketNodesCompanion(markerId: Value(markerId)));
    });
  }

  // -------------------------------------------------------------------------
  // Progression
  // -------------------------------------------------------------------------

  /// Enregistre le match joué ET fait avancer le tableau, en une transaction :
  /// si quoi que ce soit échoue, rien n'est enregistré.
  Future<int> reportNodeResult(int nodeId, FinishedMatchData data) async {
    final matchId = await _progress(nodeId, data.winnerId, data: data);
    return matchId!;
  }

  /// Forfait : fait avancer le tableau sans match ni statistiques.
  Future<void> reportWalkover(int nodeId, int winnerId) async {
    await _progress(nodeId, winnerId);
  }

  Future<int?> _progress(int nodeId, int winnerId, {FinishedMatchData? data}) {
    return db.transaction(() async {
      final row = await _requireNodeRow(nodeId);
      final openId = row.openId;
      final open = await _requireOpen(openId);
      if (open.status != OpenStatus.running) {
        throw const OpenStateException('Cet open n\'est pas en cours.');
      }
      final bracket = await _loadBracket(openId);
      final node = bracket.nodes.firstWhere((n) => n.id == nodeId);

      int? matchId;
      if (data != null) {
        // Refuse avant d'écrire quoi que ce soit si le match saisi n'est pas
        // celui de la case (les erreurs du moteur couvrent le reste).
        final dataPlayers = {data.player1Id, data.player2Id};
        if (node.isReady &&
            (dataPlayers.length != 2 ||
                !dataPlayers.containsAll([node.playerA!, node.playerB!]))) {
          throw const OpenStateException(
              'Les joueurs du match ne correspondent pas à ceux de la case du tableau.');
        }
        matchId = await db.saveFinishedMatch(FinishedMatchData(
          player1Id: data.player1Id,
          player2Id: data.player2Id,
          winnerId: data.winnerId,
          bestOf: data.bestOf,
          turns: data.turns,
          openId: openId,
          round: node.round,
          markerId: node.markerId,
        ));
      }

      final update = _engine.applyResult(bracket, node.key, winnerId, matchId: matchId);
      for (final changed in update.changed) {
        await (db.update(db.bracketNodes)..where((t) => t.id.equals(changed.id!))).write(
          BracketNodesCompanion(
            playerAId: Value(changed.playerA),
            playerBId: Value(changed.playerB),
            status: Value(changed.status.name),
            winnerId: Value(changed.winnerId),
            markerId: Value(changed.markerId),
            matchId: Value(changed.matchId),
          ),
        );
      }

      if (update.bracket.isComplete) {
        final placements =
            BracketFormats.byId(open.format).placements(update.bracket);
        for (final entry in placements.entries) {
          await (db.update(db.openEntries)
                ..where((t) =>
                    t.openId.equals(openId) & t.playerId.equals(entry.key)))
              .write(OpenEntriesCompanion(finalPlacement: Value(entry.value)));
        }
        await _setOpenStatus(openId, OpenStatus.finished);
      }
      return matchId;
    });
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------
  void _validate(NewOpen data) {
    if (data.name.trim().isEmpty) {
      throw const OpenStateException('Le nom de l\'open est obligatoire.');
    }
    if (data.bestOf < 1 || data.bestOf.isEven) {
      throw const OpenStateException(
          'Le nombre de legs doit être impair (1, 3, 5…).');
    }
    if (!OpenFormat.all.contains(data.format)) {
      throw OpenStateException('Format inconnu : ${data.format}.');
    }
  }

  String? _blankToNull(String? s) {
    final trimmed = s?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  Future<Open> _requireOpen(int openId) async {
    final open = await (db.select(db.opens)..where((t) => t.id.equals(openId)))
        .getSingleOrNull();
    if (open == null) throw const OpenStateException('Open introuvable.');
    return open;
  }

  Future<Open> _requireSetup(int openId, String messageIfStarted) async {
    final open = await _requireOpen(openId);
    if (open.status != OpenStatus.setup) throw OpenStateException(messageIfStarted);
    return open;
  }

  Future<BracketNodeRow> _requireNodeRow(int nodeId) async {
    final row = await (db.select(db.bracketNodes)..where((t) => t.id.equals(nodeId)))
        .getSingleOrNull();
    if (row == null) throw const OpenStateException('Match introuvable.');
    return row;
  }

  Future<void> _setOpenStatus(int openId, String status) {
    return (db.update(db.opens)..where((t) => t.id.equals(openId)))
        .write(OpensCompanion(status: Value(status)));
  }

  Future<Bracket> _loadBracket(int openId) async {
    final rows = await (db.select(db.bracketNodes)
          ..where((t) => t.openId.equals(openId))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    return Bracket(rows.map(_toNode));
  }

  OpenSummary _toSummary(QueryRow r) => OpenSummary(
        id: r.read<int>('id'),
        name: r.read<String>('name'),
        location: r.readNullable<String>('location'),
        date: r.readNullable<DateTime>('date'),
        format: r.read<String>('format'),
        bestOf: r.read<int>('best_of'),
        grandFinalReset: r.read<bool>('grand_final_reset'),
        status: r.read<String>('status'),
        entryCount: r.read<int>('entry_count'),
      );

  SlotRef? _slotRef(String? key, String? slot) =>
      key == null || slot == null ? null : SlotRef(key, Slot.values.byName(slot));

  BracketNode _toNode(BracketNodeRow r) => BracketNode(
        id: r.id,
        key: r.nodeKey,
        side: BracketSide.values.byName(r.bracket),
        round: r.round,
        position: r.position,
        playerA: r.playerAId,
        playerB: r.playerBId,
        winnerTo: _slotRef(r.winnerToKey, r.winnerToSlot),
        loserTo: _slotRef(r.loserToKey, r.loserToSlot),
        status: NodeStatus.values.byName(r.status),
        winnerId: r.winnerId,
        markerId: r.markerId,
        matchId: r.matchId,
      );
}
