// lib/domain/bracket/bracket.dart
// Modèle pur d'un tableau de tournoi (aucune dépendance à Drift ni Flutter).
//
// Un tableau est un graphe de « cases » (BracketNode). Chaque case est un match
// à jouer entre deux joueurs (créneaux A et B). Le déroulement est décrit par
// des liens : « le vainqueur va dans tel créneau, le perdant dans tel autre ».
// Le moteur (BracketEngine) n'a besoin de rien d'autre pour faire avancer
// n'importe quel format (simple élimination, double élimination…).
//
// Modèle des byes : ils sont résolus À LA GÉNÉRATION et n'ont PAS de case.
// Un joueur exempté est simplement placé directement dans la case suivante.
// Le tableau ne contient donc que des matchs réellement joués :
// 2N − 2 cases pour N joueurs (2N − 1 avec le reset de la grande finale).

enum BracketSide { winners, losers, grandFinal }

/// Créneau d'une case : A (haut) ou B (bas).
enum Slot { a, b }

enum NodeStatus {
  /// Il manque au moins un joueur (adversaire pas encore connu).
  pending,

  /// Les deux joueurs sont connus : le match peut être joué.
  ready,

  /// Match terminé (joué ou forfait).
  finished,

  /// Case devenue inutile (ex. second match de finale non nécessaire).
  skipped,
}

/// Clés lisibles et stables des cases, uniques par open.
abstract final class BracketKeys {
  static String winners(int round, int position) => 'W$round-$position';
  static String losers(int round, int position) => 'L$round-$position';

  static const grandFinal = 'GF1';
  static const grandFinalReset = 'GF2';
}

class BracketConfig {
  /// Voir NewOpen.grandFinalReset.
  final bool grandFinalReset;
  const BracketConfig({this.grandFinalReset = false});
}

/// Destination d'un vainqueur ou d'un perdant : un créneau d'une autre case.
class SlotRef {
  final String nodeKey;
  final Slot slot;
  const SlotRef(this.nodeKey, this.slot);

  @override
  bool operator ==(Object other) =>
      other is SlotRef && other.nodeKey == nodeKey && other.slot == slot;

  @override
  int get hashCode => Object.hash(nodeKey, slot);

  @override
  String toString() => '$nodeKey.${slot.name}';
}

class BracketNode {
  /// Identifiant en base (null tant que le tableau n'est pas persisté).
  final int? id;
  final String key;
  final BracketSide side;

  /// Tour et position dans le tour (structurels : peuvent présenter des
  /// « trous » quand des byes ont supprimé des cases).
  final int round;
  final int position;

  final int? playerA;
  final int? playerB;

  /// Où vont le vainqueur / le perdant (null = sortie du tableau).
  final SlotRef? winnerTo;
  final SlotRef? loserTo;

  final NodeStatus status;
  final int? winnerId;

  /// Marqueur assigné (jamais l'un des deux joueurs).
  final int? markerId;

  /// Match joué correspondant dans `matches` (null si pas encore joué ou forfait).
  final int? matchId;

  const BracketNode({
    this.id,
    required this.key,
    required this.side,
    required this.round,
    required this.position,
    this.playerA,
    this.playerB,
    this.winnerTo,
    this.loserTo,
    this.status = NodeStatus.pending,
    this.winnerId,
    this.markerId,
    this.matchId,
  });

  bool get isReady => status == NodeStatus.ready;

  int? get loserId {
    final w = winnerId;
    if (w == null) return null;
    return w == playerA ? playerB : playerA;
  }

  /// Copie en modifiant des champs. Ne permet pas de remettre un champ à null
  /// (voir [withMarker] pour le marqueur).
  BracketNode copyWith({
    int? playerA,
    int? playerB,
    NodeStatus? status,
    int? winnerId,
    int? matchId,
  }) {
    return BracketNode(
      id: id,
      key: key,
      side: side,
      round: round,
      position: position,
      playerA: playerA ?? this.playerA,
      playerB: playerB ?? this.playerB,
      winnerTo: winnerTo,
      loserTo: loserTo,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      markerId: markerId,
      matchId: matchId ?? this.matchId,
    );
  }

  BracketNode withMarker(int? markerId) {
    return BracketNode(
      id: id,
      key: key,
      side: side,
      round: round,
      position: position,
      playerA: playerA,
      playerB: playerB,
      winnerTo: winnerTo,
      loserTo: loserTo,
      status: status,
      winnerId: winnerId,
      markerId: markerId,
      matchId: matchId,
    );
  }

  @override
  String toString() => 'BracketNode($key, $playerA vs $playerB, ${status.name})';
}

/// Un tableau complet. Immuable : le moteur en renvoie un nouveau à chaque coup.
class Bracket {
  final List<BracketNode> nodes;
  final Map<String, BracketNode> _byKey;

  Bracket(Iterable<BracketNode> nodes)
      : nodes = List.unmodifiable(nodes),
        _byKey = {for (final n in nodes) n.key: n};

  BracketNode? nodeByKey(String key) => _byKey[key];

  BracketNode nodeAt(String key) {
    final node = _byKey[key];
    if (node == null) throw ArgumentError('Case inconnue : $key');
    return node;
  }

  /// Vrai si le format prévoit un second match de grande finale.
  bool get hasGrandFinalReset => _byKey.containsKey(BracketKeys.grandFinalReset);

  Iterable<BracketNode> get readyNodes => nodes.where((n) => n.isReady);

  /// Tous les matchs nécessaires sont terminés.
  bool get isComplete {
    final gf1 = _byKey[BracketKeys.grandFinal];
    if (gf1 == null || gf1.status != NodeStatus.finished) return false;
    final gf2 = _byKey[BracketKeys.grandFinalReset];
    return gf2 == null ||
        gf2.status == NodeStatus.finished ||
        gf2.status == NodeStatus.skipped;
  }

  /// Case de la finale effectivement décisive (GF2 si jouée, sinon GF1).
  BracketNode? get decidingFinal {
    final gf2 = _byKey[BracketKeys.grandFinalReset];
    if (gf2 != null && gf2.status == NodeStatus.finished) return gf2;
    return _byKey[BracketKeys.grandFinal];
  }

  int? get championId => isComplete ? decidingFinal?.winnerId : null;

  /// Nouveau tableau où les cases données (même clé) remplacent les anciennes.
  Bracket replacing(Iterable<BracketNode> updated) {
    final byKey = {for (final n in updated) n.key: n};
    return Bracket([for (final n in nodes) byKey[n.key] ?? n]);
  }
}
