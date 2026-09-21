// lib/ui/opens/players_tab.dart
// Onglet « Joueurs » d'un open : inscriptions, têtes de série, génération.
//
// ÉCOUTE : repo.watchEntries(openId) (inscrits, dans l'ordre des têtes de série)
//          repo.watchPlayers() (tous les joueurs, pour l'autocomplétion).
// L'open (statut, format…) est fourni par l'écran parent, qui écoute watchOpen.
//
// En `setup` : ajout, glisser pour classer, retrait, tirage au sort, génération.
// Ensuite (`running` / `finished`) : lecture seule, les inscriptions sont closes.

import 'package:flutter/material.dart';

import '../../data/repository.dart';
import '../../domain/open.dart';
import '../../domain/open_rules.dart';
import '../../domain/player.dart';
import '../ui_helpers.dart';
import 'add_player_panel.dart';
import 'open_info_tile.dart';

class PlayersTab extends StatefulWidget {
  final DartsRepository repo;
  final OpenSummary open;
  const PlayersTab({super.key, required this.repo, required this.open});

  @override
  State<PlayersTab> createState() => _PlayersTabState();
}

class _PlayersTabState extends State<PlayersTab>
    with AutomaticKeepAliveClientMixin {
  late final Stream<List<OpenEntry>> _entries =
      widget.repo.watchEntries(widget.open.id);
  late final Stream<List<PlayerSummary>> _players = widget.repo.watchPlayers();

  /// Ordre affiché juste après un glisser, en attendant que la base le confirme
  /// (évite que la ligne « saute » en arrière le temps du aller-retour).
  List<int>? _localOrder;

  @override
  bool get wantKeepAlive => true; // garde la saisie et l'ordre en changeant d'onglet

  // ---------------------------------------------------------------------------
  // Ordre affiché
  // ---------------------------------------------------------------------------

  /// Inscrits dans l'ordre à afficher : l'ordre local tant que la base ne l'a pas
  /// rattrapé, sinon celui de la base (source de vérité).
  List<OpenEntry> _displayed(List<OpenEntry> entries) {
    final local = _localOrder;
    if (local == null) return entries;
    final byId = {for (final e in entries) e.playerId: e};
    final sameSet =
        local.length == entries.length && local.every(byId.containsKey);
    if (!sameSet) {
      _localOrder = null; // quelqu'un a été ajouté/retiré : la base fait foi
      return entries;
    }
    final ordered = [for (final id in local) byId[id]!];
    final caughtUp = seedingStatus(entries) == SeedingStatus.complete &&
        [for (final e in entries) e.playerId].join(',') == local.join(',');
    if (caughtUp) {
      _localOrder = null;
      return entries;
    }
    return ordered;
  }

  Future<void> _saveOrder(List<int> playerIds) async {
    setState(() => _localOrder = playerIds);
    final ok = await runAction<bool>(context, () async {
      await widget.repo.setSeeds(widget.open.id, playerIds);
      return true;
    });
    if (!mounted) return;
    // Échec : on revient à l'ordre réel de la base.
    if (ok == null) setState(() => _localOrder = null);
  }

  /// [newIndex] est déjà ajusté pour l'élément retiré (onReorderItem).
  void _onReorder(List<OpenEntry> shown, int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final ids = [for (final e in shown) e.playerId];
    ids.insert(newIndex, ids.removeAt(oldIndex));
    _saveOrder(ids);
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _remove(OpenEntry entry) async {
    await runAction<bool>(context, () async {
      await widget.repo.unregisterPlayer(widget.open.id, entry.playerId);
      return true;
    });
  }

  Future<void> _shuffle(SeedingStatus status) async {
    if (status == SeedingStatus.complete) {
      final confirmed = await _confirm(
        title: 'Refaire le tirage au sort ?',
        message: 'Le classement actuel des têtes de série sera remplacé.',
        action: 'Refaire le tirage',
      );
      if (!confirmed || !mounted) return;
    }
    setState(() => _localOrder = null);
    await runAction<bool>(context, () async {
      await widget.repo.shuffleSeeds(widget.open.id);
      return true;
    });
  }

  Future<void> _generate() async {
    final confirmed = await _confirm(
      title: 'Générer le tableau ?',
      message: 'Après la génération, les inscriptions et les têtes de série '
          'ne pourront plus être modifiées.',
      action: 'Générer',
    );
    if (!confirmed || !mounted) return;
    final done = await runAction<bool>(context, () async {
      await widget.repo.generateBracket(widget.open.id);
      return true;
    });
    if (done == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Tableau généré.')));
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return result == true;
  }

  // ---------------------------------------------------------------------------
  // Affichage
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin
    return StreamBuilder<List<OpenEntry>>(
      stream: _entries,
      builder: (context, entriesSnapshot) {
        if (entriesSnapshot.hasError) {
          return const Center(child: Text('Impossible de charger les joueurs.'));
        }
        final entries = entriesSnapshot.data;
        if (entries == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return StreamBuilder<List<PlayerSummary>>(
          stream: _players,
          builder: (context, playersSnapshot) =>
              _content(entries, playersSnapshot.data ?? const []),
        );
      },
    );
  }

  Widget _content(List<OpenEntry> entries, List<PlayerSummary> known) {
    final open = widget.open;
    final editable = open.status == OpenStatus.setup;
    final shown = _displayed(entries);
    // Le statut du classement et le bouton de génération se basent sur la BASE,
    // jamais sur l'ordre affiché provisoirement.
    final seeding = seedingStatus(entries);
    final missing = entries.where((e) => e.seed == null).length;

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: OpenInfoTile(open: open)),
              if (!editable) SliverToBoxAdapter(child: _ClosedBanner(open: open)),
              if (editable)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: AddPlayerPanel(
                      repo: widget.repo,
                      openId: open.id,
                      known: known,
                      registeredIds: {for (final e in entries) e.playerId},
                    ),
                  ),
                ),
              if (editable && entries.isNotEmpty && seeding != SeedingStatus.complete)
                SliverToBoxAdapter(
                  child: _SeedingBanner(
                    status: seeding,
                    missing: missing,
                    onKeepOrder: () =>
                        _saveOrder([for (final e in shown) e.playerId]),
                  ),
                ),
              SliverToBoxAdapter(
                child: _ListHeader(
                  showShuffle: editable,
                  canShuffle: entries.length >= 2,
                  onShuffle: () => _shuffle(seeding),
                ),
              ),
              if (shown.isEmpty)
                const SliverToBoxAdapter(child: _EmptyEntries())
              else if (editable)
                SliverReorderableList(
                  itemCount: shown.length,
                  onReorderItem: (o, n) => _onReorder(shown, o, n),
                  itemBuilder: (context, i) => _EntryTile(
                    key: ValueKey('entry-${shown[i].playerId}'),
                    entry: shown[i],
                    index: i,
                    // Pendant un glisser, le numéro suit la position affichée.
                    seedLabel: _localOrder != null ? '${i + 1}' : null,
                    editable: true,
                    onRemove: () => _remove(shown[i]),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: shown.length,
                  itemBuilder: (context, i) => _EntryTile(
                    key: ValueKey('entry-${shown[i].playerId}'),
                    entry: shown[i],
                    index: i,
                    editable: false,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
        ),
        if (editable) _GenerateBar(open: open, entries: entries, onGenerate: _generate),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Éléments de l'onglet
// -----------------------------------------------------------------------------

/// Bandeau des inscriptions closes (open démarré ou terminé).
class _ClosedBanner extends StatelessWidget {
  final OpenSummary open;
  const _ClosedBanner({required this.open});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      key: const ValueKey('closed-banner'),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    open.status == OpenStatus.finished
                        ? 'Open terminé.'
                        : 'Tableau généré : les inscriptions sont closes.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Cet open a démarré : il n\'est plus modifiable.'),
          ],
        ),
      ),
    );
  }
}

/// Têtes de série non définies ou incomplètes : raccourci « Garder cet ordre ».
class _SeedingBanner extends StatelessWidget {
  final SeedingStatus status;
  final int missing;
  final VoidCallback onKeepOrder;
  const _SeedingBanner({
    required this.status,
    required this.missing,
    required this.onKeepOrder,
  });

  String get _text {
    if (status == SeedingStatus.none) return 'Têtes de série non définies.';
    if (missing == 1) return '1 joueur sans tête de série.';
    if (missing > 1) return '$missing joueurs sans tête de série.';
    return 'Têtes de série incohérentes.';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      key: const ValueKey('seeding-banner'),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(_text,
                  style: TextStyle(color: scheme.onTertiaryContainer)),
            ),
            TextButton(
              key: const ValueKey('keep-order'),
              onPressed: onKeepOrder,
              child: const Text('Garder cet ordre'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  final bool showShuffle;
  final bool canShuffle;
  final VoidCallback onShuffle;
  const _ListHeader({
    required this.showShuffle,
    required this.canShuffle,
    required this.onShuffle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Text('Joueurs inscrits',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          if (showShuffle)
            TextButton.icon(
              key: const ValueKey('shuffle-seeds'),
              onPressed: canShuffle ? onShuffle : null,
              icon: const Icon(Icons.shuffle),
              label: const Text('Tirage au sort'),
            ),
        ],
      ),
    );
  }
}

class _EmptyEntries extends StatelessWidget {
  const _EmptyEntries();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Aucun joueur inscrit. Ajoutez des joueurs ci-dessus.',
        key: ValueKey('no-entries'),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final OpenEntry entry;
  final int index;
  final bool editable;
  final String? seedLabel; // remplace le numéro de la base pendant un glisser
  final VoidCallback? onRemove;
  const _EntryTile({
    super.key,
    required this.entry,
    required this.index,
    required this.editable,
    this.seedLabel,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final label = seedLabel ?? (entry.seed?.toString() ?? '–');
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          child: Text(label,
              key: ValueKey('seed-${entry.playerId}'),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(entry.playerName, style: const TextStyle(fontSize: 17)),
        trailing: editable
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: ValueKey('remove-${entry.playerId}'),
                    tooltip: 'Retirer ${entry.playerName}',
                    icon: const Icon(Icons.person_remove_outlined),
                    onPressed: onRemove,
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      key: ValueKey('drag-${entry.playerId}'),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.drag_handle),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

/// Bas de l'onglet : motif du blocage, ou « Prêt », et bouton de génération.
class _GenerateBar extends StatelessWidget {
  final OpenSummary open;
  final List<OpenEntry> entries;
  final VoidCallback onGenerate;
  const _GenerateBar({
    required this.open,
    required this.entries,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final blocker = generationBlocker(open, entries);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 4,
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                blocker ?? 'Prêt : ${entries.length} joueurs.',
                key: const ValueKey('generate-message'),
                style: TextStyle(
                  color: blocker == null ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                key: const ValueKey('generate-bracket'),
                onPressed: blocker == null ? onGenerate : null,
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Générer le tableau',
                    style: TextStyle(fontSize: 17)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
