// lib/main.dart
// 501 Darts Scorer — Phase 1 + persistance locale (Phase 2, étape 1)
// Le moteur 501 enregistre désormais chaque match terminé en base,
// avec historique et classements en direct.

import 'package:flutter/material.dart';
import 'data/database.dart';
import 'data/repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  final repo = DriftDartsRepository(db);
  runApp(DartsApp(repo: repo));
}

class DartsApp extends StatelessWidget {
  final DartsRepository repo;
  const DartsApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Darts 501',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.dark,
        ),
      ),
      home: HomeScreen(repo: repo),
    );
  }
}

// ---------------------------------------------------------------------------
// Accueil
// ---------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  final DartsRepository repo;
  const HomeScreen({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AZ Darts')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.sports_esports),
              label: const Text('Nouveau match'),
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SetupScreen(repo: repo)),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.leaderboard),
              label: const Text('Historique & classements'),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryScreen(repo: repo)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Configuration du match
// ---------------------------------------------------------------------------
class SetupScreen extends StatefulWidget {
  final DartsRepository repo;
  const SetupScreen({super.key, required this.repo});
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _p1 = TextEditingController(text: 'Joueur 1');
  final _p2 = TextEditingController(text: 'Joueur 2');
  int _bestOf = 5;
  bool _busy = false;

  @override
  void dispose() {
    _p1.dispose();
    _p2.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => _busy = true);
    final n1 = _p1.text.trim().isEmpty ? 'Joueur 1' : _p1.text.trim();
    final n2 = _p2.text.trim().isEmpty ? 'Joueur 2' : _p2.text.trim();
    final id1 = await widget.repo.getOrCreatePlayer(n1);
    final id2 = await widget.repo.getOrCreatePlayer(n2);
    if (!mounted) return;
    final legsToWin = (_bestOf ~/ 2) + 1;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => MatchScreen(
        repo: widget.repo,
        names: [n1, n2],
        playerIds: [id1, id2],
        legsToWin: legsToWin,
        bestOf: _bestOf,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('501 — Nouveau match')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _p1,
              decoration: const InputDecoration(labelText: 'Joueur 1'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _p2,
              decoration: const InputDecoration(labelText: 'Joueur 2'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Format : best of '),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _bestOf,
                  items: const [3, 5, 7, 9, 11]
                      .map((n) =>
                          DropdownMenuItem(value: n, child: Text('$n legs')))
                      .toList(),
                  onChanged: (v) => setState(() => _bestOf = v ?? 5),
                ),
              ],
            ),
            const Spacer(),
            FilledButton(
              onPressed: _busy ? null : _start,
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18)),
              child: _busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Démarrer', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Modèle en mémoire
// ---------------------------------------------------------------------------
class TurnLog {
  final int legNumber;
  final int playerIndex;
  final int score;
  final int dartsUsed;
  final bool isBust;
  final bool isCheckout;
  const TurnLog({
    required this.legNumber,
    required this.playerIndex,
    required this.score,
    required this.dartsUsed,
    required this.isBust,
    required this.isCheckout,
  });
}

class PlayerStats {
  int dartsThrown;
  int pointsScored;
  int count180;
  int highestCheckout;
  int legsWon;
  List<int> winningLegDarts;

  PlayerStats({
    this.dartsThrown = 0,
    this.pointsScored = 0,
    this.count180 = 0,
    this.highestCheckout = 0,
    this.legsWon = 0,
    List<int>? winningLegDarts,
  }) : winningLegDarts = winningLegDarts ?? [];

  double get average => dartsThrown == 0 ? 0 : pointsScored / dartsThrown * 3;
  int? get bestLeg => winningLegDarts.isEmpty
      ? null
      : winningLegDarts.reduce((a, b) => a < b ? a : b);

  PlayerStats clone() => PlayerStats(
        dartsThrown: dartsThrown,
        pointsScored: pointsScored,
        count180: count180,
        highestCheckout: highestCheckout,
        legsWon: legsWon,
        winningLegDarts: List.of(winningLegDarts),
      );
}

class GameState {
  final int legsToWin;
  final List<String> names;
  List<int> remaining;
  List<int> legDarts;
  List<PlayerStats> stats;
  List<TurnLog> turnLog;
  int thrower;
  int legStarter;
  int legNumber;
  int? winner;

  GameState({
    required this.legsToWin,
    required this.names,
    required this.remaining,
    required this.legDarts,
    required this.stats,
    required this.turnLog,
    required this.thrower,
    required this.legStarter,
    required this.legNumber,
    this.winner,
  });

  factory GameState.initial(List<String> names, int legsToWin) => GameState(
        legsToWin: legsToWin,
        names: names,
        remaining: [501, 501],
        legDarts: [0, 0],
        stats: [PlayerStats(), PlayerStats()],
        turnLog: [],
        thrower: 0,
        legStarter: 0,
        legNumber: 1,
      );

  bool get matchOver => winner != null;

  GameState clone() => GameState(
        legsToWin: legsToWin,
        names: List.of(names),
        remaining: List.of(remaining),
        legDarts: List.of(legDarts),
        stats: [stats[0].clone(), stats[1].clone()],
        turnLog: List.of(turnLog),
        thrower: thrower,
        legStarter: legStarter,
        legNumber: legNumber,
        winner: winner,
      );
}

// ---------------------------------------------------------------------------
// Suggestions de checkout
// ---------------------------------------------------------------------------
class _Throw {
  final int value;
  final String label;
  const _Throw(this.value, this.label);
}

List<_Throw>? _allCache;
List<_Throw>? _finalCache;

List<_Throw> _buildAll() {
  final l = <_Throw>[];
  for (int i = 1; i <= 20; i++) l.add(_Throw(i, '$i'));
  l.add(const _Throw(25, '25'));
  for (int i = 1; i <= 20; i++) l.add(_Throw(2 * i, 'D$i'));
  l.add(const _Throw(50, 'Bull'));
  for (int i = 1; i <= 20; i++) l.add(_Throw(3 * i, 'T$i'));
  l.sort((a, b) => b.value.compareTo(a.value));
  return l;
}

List<_Throw> _buildFinals() {
  final l = <_Throw>[];
  for (int i = 1; i <= 20; i++) l.add(_Throw(2 * i, 'D$i'));
  l.add(const _Throw(50, 'Bull'));
  l.sort((a, b) => b.value.compareTo(a.value));
  return l;
}

String? suggestCheckout(int rem) {
  if (rem < 2 || rem > 170) return null;
  final all = _allCache ??= _buildAll();
  final finals = _finalCache ??= _buildFinals();
  for (final f in finals) {
    if (f.value == rem) return f.label;
  }
  for (final a in all) {
    for (final f in finals) {
      if (a.value + f.value == rem) return '${a.label} ${f.label}';
    }
  }
  for (final a in all) {
    for (final b in all) {
      final need = rem - a.value - b.value;
      if (need < 2) continue;
      for (final f in finals) {
        if (f.value == need) return '${a.label} ${b.label} ${f.label}';
      }
    }
  }
  return null;
}

// ---------------------------------------------------------------------------
// Écran de match
// ---------------------------------------------------------------------------
class MatchScreen extends StatefulWidget {
  final DartsRepository repo;
  final List<String> names;
  final List<int> playerIds;
  final int legsToWin;
  final int bestOf;
  const MatchScreen({
    super.key,
    required this.repo,
    required this.names,
    required this.playerIds,
    required this.legsToWin,
    required this.bestOf,
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late GameState state;
  final List<GameState> _history = [];
  String _entry = '';
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    state = GameState.initial(widget.names, widget.legsToWin);
  }

  void _pushUndo() => _history.add(state.clone());

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      state = _history.removeLast();
      _entry = '';
    });
  }

  void _tapDigit(String d) {
    if (state.matchOver) return;
    if (_entry.length >= 3) return;
    final next = _entry + d;
    if (int.parse(next) > 180) return;
    setState(() => _entry = next);
  }

  void _submit() {
    if (state.matchOver || _entry.isEmpty) return;
    final s = int.parse(_entry);
    if (s > 180) return;
    final p = state.thrower;
    final rem = state.remaining[p];
    final newRem = rem - s;

    if (newRem == 0) {
      _askDartsUsed(s);
      return;
    }

    _pushUndo();
    setState(() {
      final st = state.stats[p];
      st.dartsThrown += 3;
      state.legDarts[p] += 3;
      final bust = newRem < 0 || newRem == 1;
      if (!bust) {
        st.pointsScored += s;
        state.remaining[p] = newRem;
        if (s == 180) st.count180 += 1;
      }
      state.turnLog.add(TurnLog(
        legNumber: state.legNumber,
        playerIndex: p,
        score: bust ? 0 : s,
        dartsUsed: 3,
        isBust: bust,
        isCheckout: false,
      ));
      state.thrower = 1 - p;
      _entry = '';
    });
  }

  Future<void> _askDartsUsed(int s) async {
    final darts = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Checkout de $s !'),
        content: const Text('Combien de fléchettes pour finir le leg ?'),
        actions: [1, 2, 3]
            .map((n) => TextButton(
                onPressed: () => Navigator.pop(ctx, n), child: Text('$n')))
            .toList(),
      ),
    );
    if (darts == null) {
      setState(() => _entry = '');
      return;
    }
    _finishCheckout(s, darts);
  }

  void _finishCheckout(int s, int dartsUsed) {
    _pushUndo();
    bool ended = false;
    setState(() {
      final p = state.thrower;
      final st = state.stats[p];
      st.dartsThrown += dartsUsed;
      st.pointsScored += s;
      if (s > st.highestCheckout) st.highestCheckout = s;
      st.winningLegDarts.add(state.legDarts[p] + dartsUsed);
      st.legsWon += 1;
      state.remaining[p] = 0;
      state.turnLog.add(TurnLog(
        legNumber: state.legNumber,
        playerIndex: p,
        score: s,
        dartsUsed: dartsUsed,
        isBust: false,
        isCheckout: true,
      ));

      if (st.legsWon >= state.legsToWin) {
        state.winner = p;
        ended = true;
      } else {
        state.legNumber += 1;
        state.legStarter = 1 - state.legStarter;
        state.thrower = state.legStarter;
        state.remaining = [501, 501];
        state.legDarts = [0, 0];
      }
      _entry = '';
    });
    if (ended) _save();
  }

  Future<void> _save() async {
    if (_saved) return;
    _saved = true;
    final turns = state.turnLog
        .map((t) => TurnData(
              legNumber: t.legNumber,
              playerId: widget.playerIds[t.playerIndex],
              score: t.score,
              dartsUsed: t.dartsUsed,
              isBust: t.isBust,
              isCheckout: t.isCheckout,
            ))
        .toList();
    final data = FinishedMatchData(
      player1Id: widget.playerIds[0],
      player2Id: widget.playerIds[1],
      winnerId: widget.playerIds[state.winner!],
      bestOf: widget.bestOf,
      turns: turns,
    );
    await widget.repo.saveFinishedMatch(data);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match enregistré ✓')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('501 — Bo${widget.bestOf}  ·  Leg ${state.legNumber}'),
        actions: [
          IconButton(
            onPressed: _history.isEmpty ? null : _undo,
            icon: const Icon(Icons.undo),
            tooltip: 'Annuler',
          ),
        ],
      ),
      body: state.matchOver ? _resultView() : _matchView(),
    );
  }

  Widget _matchView() {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Row(
            children: [
              Expanded(child: _playerCard(0)),
              Expanded(child: _playerCard(1)),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            _entry.isEmpty ? '—' : _entry,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: _keypad()),
      ],
    );
  }

  Widget _playerCard(int i) {
    final active = state.thrower == i;
    final st = state.stats[i];
    final hint = active ? suggestCheckout(state.remaining[i]) : null;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.all(8),
      color: active ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: active
            ? BorderSide(color: scheme.primary, width: 3)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.names[i],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text('${state.remaining[i]}',
                style: const TextStyle(
                    fontSize: 60, fontWeight: FontWeight.bold, height: 1)),
            const SizedBox(height: 8),
            Text(
                'Legs ${st.legsWon}   ·   moy ${st.average.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            SizedBox(
              height: 18,
              child: hint != null
                  ? Text('→ $hint',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.primary))
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keypad() {
    Widget key(String label, VoidCallback? onTap, {Color? bg, Color? fg}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: fg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onTap,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    Widget row(List<Widget> children) =>
        Expanded(child: Row(children: children));

    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          row([
            key('1', () => _tapDigit('1')),
            key('2', () => _tapDigit('2')),
            key('3', () => _tapDigit('3')),
          ]),
          row([
            key('4', () => _tapDigit('4')),
            key('5', () => _tapDigit('5')),
            key('6', () => _tapDigit('6')),
          ]),
          row([
            key('7', () => _tapDigit('7')),
            key('8', () => _tapDigit('8')),
            key('9', () => _tapDigit('9')),
          ]),
          row([
            key('C', () => setState(() => _entry = ''),
                bg: scheme.errorContainer, fg: scheme.onErrorContainer),
            key('0', () => _tapDigit('0')),
            key('OK', _submit, bg: scheme.primary, fg: scheme.onPrimary),
          ]),
        ],
      ),
    );
  }

  Widget _resultView() {
    final w = state.winner!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text('🏆  ${state.names[w]} gagne !',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _statBlock(0)),
                Expanded(child: _statBlock(1)),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18)),
            child: const Text('Terminer', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _statBlock(int i) {
    final st = state.stats[i];
    final best = st.bestLeg;
    Widget line(String k, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(k, style: const TextStyle(fontSize: 13)),
              Text(v,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        );
    return Card(
      margin: const EdgeInsets.all(6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(state.names[i],
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
            const Divider(),
            line('Legs gagnés', '${st.legsWon}'),
            line('Moyenne', st.average.toStringAsFixed(1)),
            line('180', '${st.count180}'),
            line('Meilleur checkout', '${st.highestCheckout}'),
            line('Meilleur leg', best == null ? '—' : '$best fléch.'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Historique & classements
// ---------------------------------------------------------------------------
class HistoryScreen extends StatelessWidget {
  final DartsRepository repo;
  const HistoryScreen({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historique & classements'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Historique'),
              Tab(text: '180'),
              Tab(text: 'Moyenne'),
              Tab(text: 'Checkout'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _history(),
            _leaderboard(repo.watch180(), (v) => '$v'),
            _leaderboard(repo.watchAverages(),
                (v) => (v as double).toStringAsFixed(1)),
            _leaderboard(repo.watchCheckouts(), (v) => '$v'),
          ],
        ),
      ),
    );
  }

  Widget _history() {
    return StreamBuilder<List<MatchSummary>>(
      stream: repo.watchHistory(),
      builder: (context, snap) {
        final rows = snap.data ?? const [];
        if (rows.isEmpty) return const _Empty('Aucun match enregistré');
        return ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final m = rows[i];
            return ListTile(
              title: Text('${m.p1}  vs  ${m.p2}'),
              subtitle: Text(m.winner == null
                  ? 'En cours'
                  : 'Vainqueur : ${m.winner}'),
            );
          },
        );
      },
    );
  }

  Widget _leaderboard(
      Stream<List<Standing>> stream, String Function(num) fmt) {
    return StreamBuilder<List<Standing>>(
      stream: stream,
      builder: (context, snap) {
        final rows = snap.data ?? const [];
        if (rows.isEmpty) return const _Empty('Pas encore de données');
        return ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final s = rows[i];
            return ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(s.name),
              trailing: Text(fmt(s.value),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            );
          },
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty(this.text);
  @override
  Widget build(BuildContext context) =>
      Center(child: Text(text, style: const TextStyle(color: Colors.grey)));
}
