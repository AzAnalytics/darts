// lib/ui/opens/open_list_screen.dart
// Liste des opens. Écoute repo.watchOpens() : toute création, modification ou
// suppression (depuis n'importe où) met la liste à jour toute seule.

import 'package:flutter/material.dart';

import '../../data/repository.dart';
import '../../domain/open.dart';
import '../ui_helpers.dart';
import 'open_detail_screen.dart';
import 'open_form_screen.dart';

class OpenListScreen extends StatefulWidget {
  final DartsRepository repo;
  const OpenListScreen({super.key, required this.repo});

  @override
  State<OpenListScreen> createState() => _OpenListScreenState();
}

class _OpenListScreenState extends State<OpenListScreen> {
  // Créé une seule fois : évite de se réabonner à chaque reconstruction.
  late final Stream<List<OpenSummary>> _opens = widget.repo.watchOpens();

  void _openDetail(int openId) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OpenDetailScreen(repo: widget.repo, openId: openId),
    ));
  }

  Future<void> _create() async {
    final id = await Navigator.of(context).push<int>(MaterialPageRoute(
      builder: (_) => OpenFormScreen(repo: widget.repo),
    ));
    if (id != null && mounted) _openDetail(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opens')),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('new-open'),
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text('Nouvel open'),
      ),
      body: StreamBuilder<List<OpenSummary>>(
        stream: _opens,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Impossible de charger les opens.'));
          }
          final opens = snapshot.data;
          if (opens == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (opens.isEmpty) return const _EmptyState();
          return ListView.builder(
            // Marge basse : le bouton flottant ne masque pas la dernière carte.
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: opens.length,
            itemBuilder: (context, i) => _OpenCard(
              open: opens[i],
              onTap: () => _openDetail(opens[i].id),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_outlined, size: 64),
            SizedBox(height: 16),
            Text('Aucun open pour l\'instant.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Créez le premier avec le bouton « Nouvel open ».',
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _OpenCard extends StatelessWidget {
  final OpenSummary open;
  final VoidCallback onTap;
  const _OpenCard({required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final when = [
      open.date == null ? 'Date à définir' : formatDate(open.date!),
      if (open.location != null) open.location!,
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(open.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(when),
                    const SizedBox(height: 2),
                    Text('${formatLabel(open.format)} · best of ${open.bestOf}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(status: open.status),
                  const SizedBox(height: 8),
                  Text(entryCountLabel(open.entryCount)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pastille de statut d'un open (Inscriptions / En cours / Terminé).
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (status) {
      OpenStatus.running => (scheme.primaryContainer, scheme.onPrimaryContainer),
      OpenStatus.finished => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant
        ),
      _ => (scheme.secondaryContainer, scheme.onSecondaryContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(statusLabel(status),
          style:
              TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
