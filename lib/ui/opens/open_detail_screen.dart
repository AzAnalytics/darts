// lib/ui/opens/open_detail_screen.dart
// Détail d'un open. Écoute repo.watchOpen(id) : si l'open est supprimé (ici ou
// ailleurs) l'écran se referme tout seul. Les onglets Joueurs / Tableau /
// Classement viendront ici aux étapes suivantes.

import 'package:flutter/material.dart';

import '../../data/repository.dart';
import '../../domain/open.dart';
import '../ui_helpers.dart';
import 'open_form_screen.dart';
import 'open_list_screen.dart' show StatusChip;

enum _DetailAction { edit, delete }

class OpenDetailScreen extends StatefulWidget {
  final DartsRepository repo;
  final int openId;
  const OpenDetailScreen({super.key, required this.repo, required this.openId});

  @override
  State<OpenDetailScreen> createState() => _OpenDetailScreenState();
}

class _OpenDetailScreenState extends State<OpenDetailScreen> {
  late final Stream<OpenSummary?> _open = widget.repo.watchOpen(widget.openId);
  bool _leaving = false; // évite de se refermer plusieurs fois

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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              StatusChip(status: open.status),
              const SizedBox(width: 12),
              Text(entryCountLabel(open.entryCount)),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.calendar_today,
            text: open.date == null ? 'Date à définir' : formatDate(open.date!),
          ),
          _InfoRow(
            icon: Icons.place_outlined,
            text: open.location ?? 'Lieu non précisé',
          ),
          _InfoRow(icon: Icons.account_tree_outlined, text: formatLabel(open.format)),
          _InfoRow(
            icon: Icons.sports_score,
            text: 'Best of ${open.bestOf} legs par défaut',
          ),
          if (open.format == OpenFormat.doubleElim)
            _InfoRow(
              icon: Icons.emoji_events_outlined,
              text: open.grandFinalReset
                  ? 'Grande finale avec reset possible'
                  : 'Grande finale en un seul match',
            ),
          const SizedBox(height: 24),
          Text(
            editable
                ? 'Inscriptions et tableau : bientôt disponibles.'
                : 'Cet open a démarré : il n\'est plus modifiable.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
