// lib/domain/bracket/bracket_engine.dart
// Fait avancer un tableau quand un match est terminé. Commun à tous les formats :
// il ne connaît que les liens « vainqueur -> créneau » / « perdant -> créneau ».

import '../open_state_exception.dart';
import 'bracket.dart';

class BracketUpdate {
  /// Le tableau après application du résultat.
  final Bracket bracket;

  /// Les cases modifiées (à persister) : la case jouée, celles qui ont reçu un
  /// joueur, et éventuellement GF2.
  final List<BracketNode> changed;
  const BracketUpdate(this.bracket, this.changed);
}

class BracketEngine {
  const BracketEngine();

  /// Enregistre le vainqueur de la case [nodeKey] et propage vainqueur et
  /// perdant. Lève OpenStateException si la case n'est pas jouable ou si
  /// [winnerId] n'est pas l'un de ses deux joueurs.
  BracketUpdate applyResult(
    Bracket bracket,
    String nodeKey,
    int winnerId, {
    int? matchId,
  }) {
    final node = bracket.nodeByKey(nodeKey);
    if (node == null) {
      throw OpenStateException('Match inconnu : $nodeKey.');
    }
    if (node.status == NodeStatus.finished) {
      throw const OpenStateException('Ce match est déjà terminé.');
    }
    if (!node.isReady) {
      throw const OpenStateException(
          'Ce match ne peut pas encore être joué : il manque un joueur.');
    }
    if (winnerId != node.playerA && winnerId != node.playerB) {
      throw const OpenStateException(
          'Le vainqueur doit être l\'un des deux joueurs du match.');
    }
    final loserId = winnerId == node.playerA ? node.playerB! : node.playerA!;

    final changed = <String, BracketNode>{};
    BracketNode current(String key) => changed[key] ?? bracket.nodeAt(key);

    changed[node.key] = node.copyWith(
      status: NodeStatus.finished,
      winnerId: winnerId,
      matchId: matchId,
    );

    void place(SlotRef? ref, int playerId) {
      if (ref == null) return;
      changed[ref.nodeKey] = _withPlayer(current(ref.nodeKey), ref.slot, playerId);
    }

    place(node.winnerTo, winnerId);
    place(node.loserTo, loserId);

    // Reset de la grande finale : si le vainqueur du tableau perdant (créneau B)
    // gagne GF1, les deux mêmes joueurs rejouent GF2 ; sinon GF2 est inutile.
    if (node.key == BracketKeys.grandFinal && bracket.hasGrandFinalReset) {
      final gf2 = current(BracketKeys.grandFinalReset);
      changed[gf2.key] = winnerId == node.playerB
          ? gf2.copyWith(
              playerA: node.playerA,
              playerB: node.playerB,
              status: NodeStatus.ready,
            )
          : gf2.copyWith(status: NodeStatus.skipped);
    }

    return BracketUpdate(
      bracket.replacing(changed.values),
      changed.values.toList(),
    );
  }

  BracketNode _withPlayer(BracketNode target, Slot slot, int playerId) {
    final occupied = slot == Slot.a ? target.playerA : target.playerB;
    if (occupied != null) {
      throw StateError('Créneau ${slot.name} de ${target.key} déjà occupé');
    }
    final a = slot == Slot.a ? playerId : target.playerA;
    final b = slot == Slot.b ? playerId : target.playerB;
    var updated = target.copyWith(
      playerA: a,
      playerB: b,
      status: a != null && b != null ? NodeStatus.ready : NodeStatus.pending,
    );
    // Un joueur ne marque jamais son propre match : si le marqueur déjà
    // désigné vient d'arriver dans la case, on lui retire l'assignation.
    if (updated.markerId == playerId) updated = updated.withMarker(null);
    return updated;
  }
}
