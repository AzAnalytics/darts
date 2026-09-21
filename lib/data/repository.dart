// lib/data/repository.dart
// La couche d'abstraction : l'UI ne parle qu'à cette interface.
// Passer du local à un backend distant plus tard = créer une autre
// implémentation, sans toucher aux écrans.
//
// Toutes les méthodes « open » lèvent une OpenStateException (message en
// français, affichable tel quel) quand l'action est refusée : open déjà démarré,
// joueur déjà inscrit, résultat invalide, etc.

import 'dart:math';

import '../domain/bracket/bracket.dart';
import '../domain/open.dart';
import '../domain/player.dart';
import 'database.dart';
import 'open_store.dart';

abstract class DartsRepository {
  // --- Joueurs, matchs libres, statistiques ---

  /// Renvoie le joueur de ce nom (normalisé, casse ignorée, accents significatifs)
  /// ou le crée : « éric » retrouve « Éric ».
  Future<int> getOrCreatePlayer(String name);

  /// Tous les joueurs connus, triés par nom : alimente l'autocomplétion.
  Stream<List<PlayerSummary>> watchPlayers();
  Future<int> saveFinishedMatch(FinishedMatchData data);
  Stream<List<MatchSummary>> watchHistory();
  Stream<List<Standing>> watch180();
  Stream<List<Standing>> watchAverages();
  Stream<List<Standing>> watchCheckouts();

  // --- Opens ---
  Future<int> createOpen(NewOpen data);

  /// Modifiable tant que l'open n'a pas démarré (status `setup`).
  Future<void> updateOpen(int openId, NewOpen data);

  /// Supprimable tant que l'open n'a pas démarré.
  Future<void> deleteOpen(int openId);
  Stream<List<OpenSummary>> watchOpens();
  Stream<OpenSummary?> watchOpen(int openId);

  // --- Inscriptions et seeding (status `setup` uniquement) ---

  /// Inscrit un joueur. Si les têtes de série sont déjà complètes, il prend
  /// automatiquement la dernière (même transaction) ; sinon il n'en a pas.
  Future<void> registerPlayer(int openId, int playerId);
  Future<void> unregisterPlayer(int openId, int playerId);

  /// Seeding manuel : [playerIdsBySeed] classe tous les inscrits
  /// (index 0 = tête de série 1).
  Future<void> setSeeds(int openId, List<int> playerIdsBySeed);

  /// Seeding aléatoire. [random] injectable pour les tests.
  Future<void> shuffleSeeds(int openId, {Random? random});
  Stream<List<OpenEntry>> watchEntries(int openId);

  // --- Tableau ---

  /// Génère le tableau (refuse : moins de 3 joueurs, têtes de série
  /// incomplètes) et passe l'open en `running`.
  Future<void> generateBracket(int openId);

  /// Annule le tableau tant qu'aucun match n'est joué (retour à `setup`).
  Future<void> resetBracket(int openId);

  /// Le tableau en direct. Les noms des joueurs s'obtiennent via [watchEntries].
  Stream<Bracket> watchBracket(int openId);

  // --- Marqueur ---

  /// Assigne (ou retire, avec null) le marqueur d'un match. Refuse l'un des deux
  /// joueurs du match, ou un joueur non inscrit à l'open.
  Future<void> assignMarker(int nodeId, int? markerId);

  // --- Progression ---

  /// Enregistre le match joué (stats comprises) ET fait avancer le tableau, de
  /// façon atomique. Renvoie l'id du match enregistré.
  Future<int> reportNodeResult(int nodeId, FinishedMatchData data);

  /// Forfait : fait avancer le tableau sans match ni statistiques.
  Future<void> reportWalkover(int nodeId, int winnerId);
}

class DriftDartsRepository implements DartsRepository {
  final AppDatabase db;
  final OpenStore _opens;
  DriftDartsRepository(this.db) : _opens = OpenStore(db);

  @override
  Future<int> getOrCreatePlayer(String name) => db.getOrCreatePlayer(name);

  @override
  Stream<List<PlayerSummary>> watchPlayers() => db.watchPlayers();

  @override
  Future<int> saveFinishedMatch(FinishedMatchData data) =>
      db.saveFinishedMatch(data);

  @override
  Stream<List<MatchSummary>> watchHistory() => db.watchHistory();

  @override
  Stream<List<Standing>> watch180() => db.watch180();

  @override
  Stream<List<Standing>> watchAverages() => db.watchAverages();

  @override
  Stream<List<Standing>> watchCheckouts() => db.watchCheckouts();

  @override
  Future<int> createOpen(NewOpen data) => _opens.createOpen(data);

  @override
  Future<void> updateOpen(int openId, NewOpen data) =>
      _opens.updateOpen(openId, data);

  @override
  Future<void> deleteOpen(int openId) => _opens.deleteOpen(openId);

  @override
  Stream<List<OpenSummary>> watchOpens() => _opens.watchOpens();

  @override
  Stream<OpenSummary?> watchOpen(int openId) => _opens.watchOpen(openId);

  @override
  Future<void> registerPlayer(int openId, int playerId) =>
      _opens.registerPlayer(openId, playerId);

  @override
  Future<void> unregisterPlayer(int openId, int playerId) =>
      _opens.unregisterPlayer(openId, playerId);

  @override
  Future<void> setSeeds(int openId, List<int> playerIdsBySeed) =>
      _opens.setSeeds(openId, playerIdsBySeed);

  @override
  Future<void> shuffleSeeds(int openId, {Random? random}) =>
      _opens.shuffleSeeds(openId, random: random);

  @override
  Stream<List<OpenEntry>> watchEntries(int openId) =>
      _opens.watchEntries(openId);

  @override
  Future<void> generateBracket(int openId) => _opens.generateBracket(openId);

  @override
  Future<void> resetBracket(int openId) => _opens.resetBracket(openId);

  @override
  Stream<Bracket> watchBracket(int openId) => _opens.watchBracket(openId);

  @override
  Future<void> assignMarker(int nodeId, int? markerId) =>
      _opens.assignMarker(nodeId, markerId);

  @override
  Future<int> reportNodeResult(int nodeId, FinishedMatchData data) =>
      _opens.reportNodeResult(nodeId, data);

  @override
  Future<void> reportWalkover(int nodeId, int winnerId) =>
      _opens.reportWalkover(nodeId, winnerId);
}
