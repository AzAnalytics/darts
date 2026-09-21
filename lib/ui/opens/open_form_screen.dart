// lib/ui/opens/open_form_screen.dart
// Création et modification d'un open. Aucun flux : action ponctuelle. Renvoie
// l'id de l'open (Navigator.pop) quand l'enregistrement a réussi.

import 'package:flutter/material.dart';

import '../../data/repository.dart';
import '../../domain/open.dart';
import '../ui_helpers.dart';

class OpenFormScreen extends StatefulWidget {
  final DartsRepository repo;

  /// null = création ; sinon modification de cet open (statut `setup` requis,
  /// sinon le repository refuse et le message s'affiche).
  final OpenSummary? existing;
  const OpenFormScreen({super.key, required this.repo, this.existing});

  @override
  State<OpenFormScreen> createState() => _OpenFormScreenState();
}

class _OpenFormScreenState extends State<OpenFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _location;
  DateTime? _date;
  late int _bestOf;
  late String _format;
  late bool _reset;
  bool _busy = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name);
    _location = TextEditingController(text: e?.location);
    _date = e?.date;
    _bestOf = e?.bestOf ?? 5;
    // Un open hérité de la v1 est en « élimination simple » (défaut SQL), format
    // pas encore disponible : on propose directement la double élimination.
    _format = e != null && isFormatAvailable(e.format)
        ? e.format
        : OpenFormat.doubleElim;
    _reset = e?.grandFinalReset ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Date de l\'open',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final data = NewOpen(
      name: _name.text,
      location: _location.text,
      date: _date,
      format: _format,
      bestOf: _bestOf,
      grandFinalReset: _format == OpenFormat.doubleElim && _reset,
    );
    final existing = widget.existing;
    // runAction lit null comme un échec : on renvoie donc toujours un id.
    final id = await runAction<int>(context, () async {
      if (existing == null) return widget.repo.createOpen(data);
      await widget.repo.updateOpen(existing.id, data);
      return existing.id;
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (id != null) Navigator.of(context).pop(id);
  }

  @override
  Widget build(BuildContext context) {
    // Les options habituelles + la valeur de l'open s'il en a une autre.
    final bestOfChoices = {...bestOfOptions, _bestOf}.toList()..sort();
    final legacy = widget.existing;
    final legacyFormat = legacy != null && !isFormatAvailable(legacy.format);

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Modifier l\'open' : 'Nouvel open')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            key: const ValueKey('save-open'),
            onPressed: _busy ? null : _save,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18)),
            child: _busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_editing ? 'Enregistrer' : 'Créer l\'open',
                    style: const TextStyle(fontSize: 18)),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const ValueKey('open-name'),
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Nom de l\'open'),
              validator: (v) => (v ?? '').trim().isEmpty
                  ? 'Le nom est obligatoire'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('open-location'),
              controller: _location,
              textCapitalization: TextCapitalization.sentences,
              decoration:
                  const InputDecoration(labelText: 'Lieu (facultatif)'),
            ),
            const SizedBox(height: 8),
            ListTile(
              key: const ValueKey('open-date'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(_date == null
                  ? 'Date (facultative)'
                  : formatDate(_date!)),
              trailing: _date == null
                  ? null
                  : IconButton(
                      tooltip: 'Effacer la date',
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _date = null),
                    ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              key: const ValueKey('open-bestof'),
              initialValue: _bestOf,
              decoration: const InputDecoration(
                labelText: 'Best of par défaut',
                helperText: 'Nombre de legs proposé pour les matchs de l\'open.',
              ),
              items: bestOfChoices
                  .map((n) => DropdownMenuItem(value: n, child: Text('$n legs')))
                  .toList(),
              onChanged: (v) => setState(() => _bestOf = v ?? 5),
            ),
            const SizedBox(height: 24),
            Text('Format', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in OpenFormat.all)
                  ChoiceChip(
                    key: ValueKey('format-$f'),
                    label: Text(isFormatAvailable(f)
                        ? formatLabel(f)
                        : '${formatLabel(f)} (bientôt)'),
                    selected: _format == f,
                    onSelected: isFormatAvailable(f)
                        ? (_) => setState(() => _format = f)
                        : null,
                  ),
              ],
            ),
            if (legacyFormat)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Cet open utilise l\'ancien format par défaut '
                  '(${formatLabel(legacy.format)}), pas encore disponible : '
                  'il passera en double élimination à l\'enregistrement.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (_format == OpenFormat.doubleElim)
              SwitchListTile(
                key: const ValueKey('open-reset'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Reset de la grande finale'),
                subtitle: const Text(
                    'Si le vainqueur du tableau perdant gagne la grande finale, '
                    'un second match est joué. Sinon : grande finale en un seul match.'),
                value: _reset,
                onChanged: (v) => setState(() => _reset = v),
              ),
          ],
        ),
      ),
    );
  }
}
