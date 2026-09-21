// lib/ui/opens/open_detail_screen.dart
// Détail d'un open : trois onglets Joueurs / Tableau / Classement.
// Écoute repo.watchOpen(id) : si l'open est supprimé (ici ou ailleurs) l'écran se
// referme tout seul ; quand le tableau est généré, on bascule sur l'onglet Tableau.
// Les onglets Tableau et Classement sont provisoires (étapes suivantes).

import 'package:flutter/material.dart';

import '../../data/repository.dart';
import '../../domain/open.dart';
import '../ui_helpers.dart';
import 'open_form_screen.dart';
import 'open_list_screen.dart' show StatusChip;
import 'players_tab.dart';

enum _DetailAction { edit, delete }

class OpenDetailScreen extends StatefulWidget {
  final DartsRepository repo;
  final int openId;
  const OpenDetailScreen({super.key, required this.repo, required this.openId});

  @override
  State<OpenDetailScreen> createState() => _OpenDetailScreenState();
}

class _OpenDetailScreenState extends State<OpenDetailScreen>
    with SingleTickerProviderStateMixin {
  late final Stream<OpenSummary?> _open = widget.repo.watchOpen(widget.openId);
  bool _leaving = false; // évite de se refermer plusieurs fois

  // Créé à la première réception de l'open : l'onglet de départ dépend de son statut.
  TabController? _tabs;
  String? _lastStatus;

  static const _playersTab = 0;
  static const _bracketTab = 1;
  static const _rankingTab = 2;

  int _initialTab(String status) => switch (status) {
        OpenStatus.running => _bracketTab,
        OpenStatus.finished => _rankingTab,
        _ => _playersTab,
      };

  @override
  void dispose() {
    _tabs?.dispose();
    super.dispose();
  }

  Future<void> _edit(OpenSummary open) async {
    await Navigator.of(context).push<int>(MaterialPageRoute(
      builder: (_) => OpenFormScreen(repo: widget.repo, existing: open),
    ));
    // Rien à faire au retour : le flux met l'écran à jour.
  }

  Future<void> _delete(OpenSummary open) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet open ?'),
        content: Text('« ${open.name} » et ses inscriptions seront supprimés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    // La fermeture de l'écran vient du flux (open disparu), pas d'ici.
    await runAction<bool>(context, () async {
      await widget.repo.deleteOpen(open.id);
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OpenSummary?>(
      stream: _open,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Impossible de charger cet open.')),
          );
        }
        // Pas encore d'événement : chargement (≠ événement null = open supprimé).
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final open = snapshot.data;
        if (open == null) {
          if (!_leaving) {
            _leaving = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.of(context).maybePop();
            });
          }
          return Scaffold(appBar: AppBar());
        }
        return _buildOpen(context, open);
      },
    );
  }

  Widget _buildOpen(BuildContext context, OpenSummary open) {
    final tabs =
        _tabs ??= TabController(length: 3, vsync: this, initialIndex: _initialTab(open.status));
    // Le tableau vient d'être généré : on montre le tableau.
    if (_lastStatus == OpenStatus.setup && open.status == OpenStatus.running) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) tabs.animateTo(_bracketTab);
      });
    }
    _lastStatus = open.status;

    final editable = open.status == OpenStatus.setup;
    return Scaffold(
      appBar: AppBar(
        title: Text(open.name),
        actions: [
          PopupMenuButton<_DetailAction>(
            key: const ValueKey('detail-menu'),
            onSelected: (a) => switch (a) {
              _DetailAction.edit => _edit(open),
              _DetailAction.delete => _delete(open),
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _DetailAction.edit,
                enabled: editable,
                child: const Text('Modifier'),
              ),
              PopupMenuItem(
                value: _DetailAction.delete,
                enabled: editable,
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: tabs,
          tabs: const [
            Tab(text: 'Joueurs'),
            Tab(text: 'Tableau'),
            Tab(text: 'Classement'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                StatusChip(status: open.status),
                const SizedBox(width: 12),
                Text(entryCountLabel(open.entryCount)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabs,
              children: [
                PlayersTab(repo: widget.repo, open: open),
                _PlaceholderTab(
                  icon: Icons.account_tree_outlined,
                  text: open.status == OpenStatus.setup
                      ? 'Le tableau sera disponible une fois généré '
                          '(bouton « Générer le tableau » de l\'onglet Joueurs).'
                      : 'L\'affichage du tableau arrive bientôt.',
                ),
                const _PlaceholderTab(
                  icon: Icons.emoji_events_outlined,
                  text: 'Le classement final apparaîtra ici à la fin de l\'open.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PlaceholderTab({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
