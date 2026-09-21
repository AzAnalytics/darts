// lib/domain/bracket/double_elimination.dart
// Double élimination : tableau gagnant (W), tableau perdant / repêchage (L),
// grande finale (GF1) et, en option, second match de finale (GF2).
//
// Notation : N = nombre de joueurs. Le tableau « complet » a la taille de la
// plus petite puissance de 2 >= N (variable `size`, interne à la génération).
//
// Génération en deux temps :
//  1. On dessine la structure complète (avec `size` places) : chaque créneau de
//     chaque case a une SOURCE (une tête de série, ou le vainqueur / le perdant
//     d'une autre case).
//  2. On résout les byes : les têtes de série > N n'existent pas. Une case dont
//     un créneau est vide ne se joue pas : elle est supprimée et l'autre joueur
//     (déjà connu, ou « à venir ») est relié directement à la case suivante.
//     Cette contraction se propage toute seule dans le tableau perdant.
// Il ne reste que les matchs réellement joués : 2N − 2 cases (+1 avec GF2).

import '../open.dart';
import '../open_state_exception.dart';
import 'bracket.dart';
import 'bracket_format.dart';
import 'seeding.dart';

class DoubleEliminationFormat implements BracketFormat {
  const DoubleEliminationFormat();

  @override
  String get id => OpenFormat.doubleElim;

  @override
  int get minPlayers => 3;

  @override
  Bracket generate(List<int> playersBySeed, BracketConfig config) {
    final n = playersBySeed.length;
    if (n < minPlayers) {
      throw OpenStateException(
          'Il faut au moins $minPlayers joueurs pour une double élimination.');
    }
    if (playersBySeed.toSet().length != n) {
      throw const OpenStateException('Un joueur est inscrit deux fois.');
    }

    final drafts = _draftStructure(nextPowerOfTwo(n));
    final draftByKey = {for (final d in drafts) d.key: d};

    // --- Résolution des byes (récursion sur un graphe sans cycle) ---
    final memo = <String, _Resolved>{};
    // resolveSource et resolvePort s'appellent l'une l'autre.
    late final _Resolved Function(String, bool) resolvePort;

    _Resolved resolveSource(_Source source) {
      switch (source) {
        case _SeedSource(:final seed):
          return seed > n
              ? const _Empty()
              : _Player(playersBySeed[seed - 1]);
        case _PortSource(:final key, :final winnerPort):
          return resolvePort(key, winnerPort);
      }
    }

    resolvePort = (String key, bool winnerPort) {
      final memoKey = '$key/${winnerPort ? 'w' : 'l'}';
      final cached = memo[memoKey];
      if (cached != null) return cached;
      final draft = draftByKey[key]!;
      final a = resolveSource(draft.a);
      final b = resolveSource(draft.b);
      final _Resolved result;
      if (a is _Empty && b is _Empty) {
        result = const _Empty(); // aucune case, personne n'en sort
      } else if (a is _Empty) {
        result = winnerPort ? b : const _Empty(); // bye : b passe, personne ne perd
      } else if (b is _Empty) {
        result = winnerPort ? a : const _Empty();
      } else {
        result = _Live(key, winnerPort); // vrai match : sortie réelle
      }
      return memo[memoKey] = result;
    };

    // --- Cases réelles et liens entrants -> sortants ---
    final winnerLinks = <String, SlotRef>{};
    final loserLinks = <String, SlotRef>{};
    final real = <_Draft, (_Resolved, _Resolved)>{};

    for (final draft in drafts) {
      final a = resolveSource(draft.a);
      final b = resolveSource(draft.b);
      if (a is _Empty || b is _Empty) continue; // case supprimée (bye)
      real[draft] = (a, b);
      for (final (slot, resolved) in [(Slot.a, a), (Slot.b, b)]) {
        if (resolved is! _Live) continue;
        final links = resolved.winnerPort ? winnerLinks : loserLinks;
        if (links.containsKey(resolved.key)) {
          throw StateError('Sortie de ${resolved.key} reliée deux fois');
        }
        links[resolved.key] = SlotRef(draft.key, slot);
      }
    }

    final nodes = <BracketNode>[
      for (final MapEntry(key: draft, value: (a, b)) in real.entries)
        BracketNode(
          key: draft.key,
          side: draft.side,
          round: draft.round,
          position: draft.position,
          playerA: a is _Player ? a.playerId : null,
          playerB: b is _Player ? b.playerId : null,
          winnerTo: winnerLinks[draft.key],
          loserTo: loserLinks[draft.key],
          status: a is _Player && b is _Player
              ? NodeStatus.ready
              : NodeStatus.pending,
        ),
    ];

    if (config.grandFinalReset) {
      // Rempli par le moteur si (et seulement si) le vainqueur du tableau
      // perdant gagne GF1.
      nodes.add(const BracketNode(
        key: BracketKeys.grandFinalReset,
        side: BracketSide.grandFinal,
        round: 2,
        position: 1,
      ));
    }
    return Bracket(nodes);
  }

  /// Structure complète (sans byes) pour un tableau de [size] places.
  List<_Draft> _draftStructure(int size) {
    var rounds = 0;
    for (var s = size; s > 1; s ~/= 2) {
      rounds++;
    }
    final order = standardSeedOrder(size);
    final drafts = <_Draft>[];

    _PortSource winnerOf(String key) => _PortSource(key, true);
    _PortSource loserOf(String key) => _PortSource(key, false);

    // Tableau gagnant : `rounds` tours.
    for (var r = 1; r <= rounds; r++) {
      final count = size >> r;
      for (var i = 1; i <= count; i++) {
        drafts.add(_Draft(
          BracketKeys.winners(r, i),
          BracketSide.winners,
          r,
          i,
          r == 1
              ? _SeedSource(order[2 * i - 2])
              : winnerOf(BracketKeys.winners(r - 1, 2 * i - 1)),
          r == 1
              ? _SeedSource(order[2 * i - 1])
              : winnerOf(BracketKeys.winners(r - 1, 2 * i)),
        ));
      }
    }

    // Tableau perdant : 2 * (rounds - 1) tours, par paires (j) :
    //  - tour 2j-1 : les survivants s'affrontent entre eux (pour j = 1, ce sont
    //    les perdants du 1er tour du tableau gagnant) ;
    //  - tour 2j   : les survivants affrontent les perdants du tour j+1 du
    //    tableau gagnant, dans l'ordre donné par _dropPosition (motif croisé
    //    qui repousse les revanches).
    for (var j = 1; j <= rounds - 1; j++) {
      final count = size >> (j + 1);
      for (var i = 1; i <= count; i++) {
        drafts.add(_Draft(
          BracketKeys.losers(2 * j - 1, i),
          BracketSide.losers,
          2 * j - 1,
          i,
          j == 1
              ? loserOf(BracketKeys.winners(1, 2 * i - 1))
              : winnerOf(BracketKeys.losers(2 * j - 2, 2 * i - 1)),
          j == 1
              ? loserOf(BracketKeys.winners(1, 2 * i))
              : winnerOf(BracketKeys.losers(2 * j - 2, 2 * i)),
        ));
      }
      for (var i = 1; i <= count; i++) {
        final drop = _dropPosition(j, i, count);
        drafts.add(_Draft(
          BracketKeys.losers(2 * j, i),
          BracketSide.losers,
          2 * j,
          i,
          winnerOf(BracketKeys.losers(2 * j - 1, i)),
          loserOf(BracketKeys.winners(j + 1, drop)),
        ));
      }
    }

    // Grande finale : champion du tableau gagnant (A) contre celui du tableau
    // perdant (B). La convention A = côté gagnant sert à décider du reset.
    drafts.add(_Draft(
      BracketKeys.grandFinal,
      BracketSide.grandFinal,
      1,
      1,
      winnerOf(BracketKeys.winners(rounds, 1)),
      winnerOf(BracketKeys.losers(2 * (rounds - 1), 1)),
    ));
    return drafts;
  }

  /// Motif croisé de la « descente » : parmi les [count] cases du tour 2j du
  /// tableau perdant, renvoie quelle case du tour j+1 du tableau gagnant y
  /// envoie son perdant, pour la case [i] (1-based).
  ///
  /// L'ordre d'arrivée doit changer à chaque descente, sinon un joueur retrouve
  /// vite celui qui l'a déjà battu. Motif retenu (mesuré, voir
  /// test/domain/bracket/rematch_test.dart) :
  ///  - j impair : ordre inversé ;
  ///  - j pair   : moitiés échangées (droit quand il ne reste que 2 cases, où
  ///    l'échange n'apporte rien à 16 joueurs).
  /// Effet : la première revanche possible n'arrive pas avant le tour k du
  /// tableau perdant (k = log2 de la taille du tableau, ex. tour 5 pour 17 à 32
  /// joueurs), alors qu'une descente « droite » l'autorise dès le tour 2 et un
  /// motif inversé/droit alterné plafonne au tour 4 dès 17 joueurs.
  int _dropPosition(int j, int i, int count) {
    if (j.isOdd) return count + 1 - i;
    if (count >= 4) return ((i - 1) ^ (count ~/ 2)) + 1;
    return i;
  }

  @override
  Map<int, int> placements(Bracket bracket) {
    final decidingFinal = bracket.decidingFinal;
    if (!bracket.isComplete || decidingFinal == null) {
      throw const OpenStateException(
          'Les places finales ne sont connues qu\'à la fin de l\'open.');
    }
    final result = <int, int>{
      decidingFinal.winnerId!: 1,
      decidingFinal.loserId!: 2,
    };

    // Les autres joueurs sont éliminés dans le tableau perdant : plus le tour
    // est avancé, meilleure est la place ; même tour = même place (ex æquo).
    final eliminatedByRound = <int, List<int>>{};
    for (final node in bracket.nodes) {
      if (node.side == BracketSide.losers &&
          node.status == NodeStatus.finished) {
        eliminatedByRound.putIfAbsent(node.round, () => []).add(node.loserId!);
      }
    }
    final rounds = eliminatedByRound.keys.toList()
      ..sort((x, y) => y.compareTo(x));
    var place = 3;
    for (final round in rounds) {
      final players = eliminatedByRound[round]!;
      for (final playerId in players) {
        result[playerId] = place;
      }
      place += players.length;
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// Types internes à la génération
// ---------------------------------------------------------------------------

/// D'où vient un créneau dans la structure complète.
sealed class _Source {
  const _Source();
}

final class _SeedSource extends _Source {
  final int seed;
  const _SeedSource(this.seed);
}

/// Sortie d'une autre case : son vainqueur (winnerPort) ou son perdant.
final class _PortSource extends _Source {
  final String key;
  final bool winnerPort;
  const _PortSource(this.key, this.winnerPort);
}

class _Draft {
  final String key;
  final BracketSide side;
  final int round;
  final int position;
  final _Source a;
  final _Source b;
  const _Draft(this.key, this.side, this.round, this.position, this.a, this.b);
}

/// Ce qu'un créneau contiendra réellement une fois les byes résolus.
sealed class _Resolved {
  const _Resolved();
}

/// Personne n'arrivera jamais dans ce créneau (bye).
final class _Empty extends _Resolved {
  const _Empty();
}

/// Joueur déjà connu à la génération.
final class _Player extends _Resolved {
  final int playerId;
  const _Player(this.playerId);
}

/// Joueur à venir : sortie d'une vraie case.
final class _Live extends _Resolved {
  final String key;
  final bool winnerPort;
  const _Live(this.key, this.winnerPort);
}
