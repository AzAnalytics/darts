// lib/ui/opens/open_info_tile.dart
// Détails d'un open (date, lieu, format, best-of, grande finale), repliés par
// défaut en tête de l'onglet Joueurs pour laisser la place à l'inscription.

import 'package:flutter/material.dart';

import '../../domain/open.dart';
import '../ui_helpers.dart';

class OpenInfoTile extends StatelessWidget {
  final OpenSummary open;
  const OpenInfoTile({super.key, required this.open});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: const ValueKey('open-details'),
      leading: const Icon(Icons.info_outline),
      title: const Text('Détails de l\'open'),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          icon: Icons.calendar_today,
          text: open.date == null ? 'Date à définir' : formatDate(open.date!),
        ),
        _InfoRow(
          icon: Icons.place_outlined,
          text: open.location ?? 'Lieu non précisé',
        ),
        _InfoRow(
            icon: Icons.account_tree_outlined, text: formatLabel(open.format)),
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
      ],
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
