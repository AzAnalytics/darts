// lib/ui/opens/add_player_panel.dart
// Ajout d'un joueur à un open : on CHOISIT d'abord un joueur existant
// (autocomplétion sur watchPlayers) ; la création d'un nouveau joueur n'est que
// le repli. C'est le rempart contre les doublons (« jean » / « Jean »).
//
// Toute la décision (existant ? déjà inscrit ? suggestions ? création ?) est dans
// lookupPlayer (lib/domain/player.dart, pur et testé) ; ce widget ne fait que
// l'afficher et exécuter l'action choisie.

import 'package:flutter/material.dart';

import '../../data/repository.dart';
import '../../domain/player.dart';
import '../ui_helpers.dart';

class AddPlayerPanel extends StatefulWidget {
  final DartsRepository repo;
  final int openId;

  /// Tous les joueurs connus (flux watchPlayers).
  final List<PlayerSummary> known;

  /// Joueurs déjà inscrits à CET open.
  final Set<int> registeredIds;

  const AddPlayerPanel({
    super.key,
    required this.repo,
    required this.openId,
    required this.known,
    required this.registeredIds,
  });

  @override
  State<AddPlayerPanel> createState() => _AddPlayerPanelState();
}

class _AddPlayerPanelState extends State<AddPlayerPanel> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  PlayerLookup get _lookup => lookupPlayer(
        _controller.text,
        widget.known,
        registeredIds: widget.registeredIds,
      );

  /// Exécute [action] ; en cas de succès, vide le champ et garde le clavier
  /// pour enchaîner le joueur suivant.
  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    final ok = await runAction<bool>(context, () async {
      await action();
      return true;
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok == true) {
      _controller.clear();
      _focus.requestFocus();
      setState(() {});
    }
  }

  void _addExisting(PlayerSummary player) =>
      _run(() => widget.repo.registerPlayer(widget.openId, player.id));

  void _create(String name) => _run(() async {
        // getOrCreatePlayer est une seconde barrière : il ne crée pas de doublon
        // même si la liste affichée était périmée.
        final id = await widget.repo.getOrCreatePlayer(name);
        await widget.repo.registerPlayer(widget.openId, id);
      });

  /// Entrée / bouton « Ajouter » : uniquement si l'action est sans ambiguïté.
  void _submit() {
    if (_busy) return;
    final lookup = _lookup;
    switch (lookup.primaryAction) {
      case PlayerLookupAction.addExisting:
        _addExisting(lookup.existing!);
      case PlayerLookupAction.create:
        _create(lookup.query);
      case PlayerLookupAction.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lookup = _lookup;
    final existing = lookup.existing;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const ValueKey('add-player-field'),
          controller: _controller,
          focusNode: _focus,
          maxLength: maxPlayerNameLength,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Ajouter un joueur',
            hintText: 'Nom du joueur',
            counterText: '',
            suffixIcon: IconButton(
              key: const ValueKey('add-player-button'),
              tooltip: 'Ajouter',
              icon: const Icon(Icons.person_add_alt_1),
              onPressed: !_busy && lookup.primaryAction != PlayerLookupAction.none
                  ? _submit
                  : null,
            ),
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submit(),
        ),
        if (lookup.query.isNotEmpty) ...[
          if (lookup.existingIsRegistered && existing != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '« ${existing.name} » est déjà inscrit dans cet open.',
                key: const ValueKey('already-registered'),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          if (existing != null && !lookup.existingIsRegistered) ...[
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: ListTile(
                key: const ValueKey('existing-suggestion'),
                enabled: !_busy,
                leading: const Icon(Icons.check_circle_outline),
                title: Text(existing.name),
                subtitle: Text(lookup.existingDiffersFromQuery
                    ? 'Joueur existant (casse différente de votre saisie)'
                    : 'Joueur existant'),
                onTap: () => _addExisting(existing),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Text(
                '${lookup.existingDiffersFromQuery ? '« ${lookup.query} » correspond à « ${existing.name} » : le joueur existant sera utilisé. ' : ''}'
                'Deux joueurs différents portant le même nom ? '
                'Ajoutez une précision (ex. « ${existing.name} D. »).',
                key: const ValueKey('homonym-hint'),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
          if (lookup.suggestions.isNotEmpty)
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  for (final s in lookup.suggestions)
                    ListTile(
                      key: ValueKey('suggestion-${s.player.id}'),
                      enabled: !_busy,
                      leading: const Icon(Icons.person_outline),
                      title: Text(s.player.name),
                      onTap: () => _addExisting(s.player),
                    ),
                ],
              ),
            ),
          if (lookup.canCreate)
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: ListTile(
                key: const ValueKey('create-player'),
                enabled: !_busy,
                leading: const Icon(Icons.person_add),
                title: Text('Créer « ${lookup.query} »'),
                subtitle: const Text('Nouveau joueur'),
                onTap: () => _create(lookup.query),
              ),
            ),
        ],
      ],
    );
  }
}
