import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:darts/domain/open.dart';
import 'package:darts/ui/opens/open_form_screen.dart';
import 'package:darts/ui/ui_helpers.dart';

import 'test_harness.dart';

/// Résultat de la dernière ouverture du formulaire (id renvoyé au pop).
class _Popped {
  bool closed = false;
  int? id;
}

void main() {
  setUpUiTests();

  /// Affiche un écran d'accueil factice, puis ouvre le formulaire dessus pour
  /// pouvoir observer ce qu'il renvoie en se fermant.
  Future<_Popped> openForm(
    WidgetTester tester,
    UiTestEnv env, {
    OpenSummary? existing,
  }) async {
    final popped = _Popped();
    await env.pumpScreen(
      tester,
      Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                popped.id = await Navigator.of(context).push<int>(
                  MaterialPageRoute(
                    builder: (_) =>
                        OpenFormScreen(repo: env.repo, existing: existing),
                  ),
                );
                popped.closed = true;
              },
              child: const Text('ouvrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await env.settle(tester);
    expect(find.byType(OpenFormScreen), findsOneWidget);
    return popped;
  }

  Future<void> setName(WidgetTester tester, String name) =>
      tester.enterText(find.byKey(const ValueKey('open-name')), name);

  Future<void> save(WidgetTester tester, UiTestEnv env) async {
    await tester.tap(find.byKey(const ValueKey('save-open')));
    await env.settle(tester);
  }

  group('Valeurs par défaut', () {
    uiTest('double élimination, best of 5, finale sèche, formats à venir grisés',
        (tester, env) async {
      await openForm(tester, env);

      expect(find.text('Nouvel open'), findsOneWidget);
      expect(find.text('5 legs'), findsOneWidget);

      final double = tester.widget<ChoiceChip>(find.byKey(const ValueKey('format-double_elim')));
      expect(double.selected, isTrue);
      for (final f in [OpenFormat.singleElim, OpenFormat.groupsKnockout]) {
        final chip = tester.widget<ChoiceChip>(find.byKey(ValueKey('format-$f')));
        expect(chip.onSelected, isNull, reason: '$f doit être grisé');
        expect(chip.selected, isFalse);
      }
      expect(find.text('Élimination simple (bientôt)'), findsOneWidget);
      expect(find.text('Poules + phase finale (bientôt)'), findsOneWidget);

      final reset = tester.widget<SwitchListTile>(find.byKey(const ValueKey('open-reset')));
      expect(reset.value, isFalse);
    });

    uiTest('la liste de best-of est celle du match libre (bestOfOptions)',
        (tester, env) async {
      await openForm(tester, env);
      await tester.tap(find.byKey(const ValueKey('open-bestof')));
      await env.settle(tester);
      for (final n in bestOfOptions) {
        expect(find.text('$n legs'), findsWidgets, reason: '$n legs proposé');
      }
      // Rien d'autre que ces valeurs dans le menu.
      expect(find.text('1 legs'), findsNothing);
      expect(find.text('4 legs'), findsNothing);
    });
  });

  group('Création', () {
    uiTest('nom vide refusé : rien n\'est créé et le formulaire reste ouvert',
        (tester, env) async {
      final popped = await openForm(tester, env);
      await save(tester, env);

      expect(find.text('Le nom est obligatoire'), findsOneWidget);
      expect(popped.closed, isFalse);
      expect(await env.opens(tester), isEmpty);

      await setName(tester, '   '); // espaces seuls : toujours refusé
      await save(tester, env);
      expect(find.text('Le nom est obligatoire'), findsOneWidget);
      expect(await env.opens(tester), isEmpty);
    });

    uiTest('création complète : les valeurs saisies sont enregistrées',
        (tester, env) async {
      final popped = await openForm(tester, env);

      await setName(tester, '  Open de rentrée ');
      await tester.enterText(find.byKey(const ValueKey('open-location')), ' Salle Jean Moulin ');
      // best of 7
      await tester.tap(find.byKey(const ValueKey('open-bestof')));
      await env.settle(tester);
      await tester.tap(find.text('7 legs').last);
      await env.settle(tester);
      // reset de la grande finale
      await tester.tap(find.byKey(const ValueKey('open-reset')));
      await env.settle(tester);
      await save(tester, env);

      expect(popped.closed, isTrue);
      final open = (await env.opens(tester)).single;
      expect(popped.id, open.id);
      expect(open.name, 'Open de rentrée');
      expect(open.location, 'Salle Jean Moulin');
      expect(open.bestOf, 7);
      expect(open.format, OpenFormat.doubleElim);
      expect(open.grandFinalReset, isTrue);
      expect(open.status, OpenStatus.setup);
    });

    uiTest('sans rien changer : best of 5 et grande finale en un seul match',
        (tester, env) async {
      await openForm(tester, env);
      await setName(tester, 'Open simple');
      await save(tester, env);
      final open = (await env.opens(tester)).single;
      expect(open.bestOf, 5);
      expect(open.grandFinalReset, isFalse);
      expect(open.location, isNull);
      expect(open.date, isNull);
    });

    uiTest('date : sélecteur en français, puis effacement', (tester, env) async {
      final popped = await openForm(tester, env);
      await setName(tester, 'Open daté');

      await tester.tap(find.byKey(const ValueKey('open-date')));
      await env.settle(tester);
      // Boutons du sélecteur en français (et non CANCEL anglais).
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('CANCEL'), findsNothing);
      await tester.tap(find.text('OK'));
      await env.settle(tester);
      expect(find.text(formatDate(DateTime.now())), findsOneWidget);

      await save(tester, env);
      final open = (await env.opens(tester)).single;
      expect(open.date, isNotNull);
      expect(popped.closed, isTrue);
    });

    uiTest('effacer la date', (tester, env) async {
      await openForm(tester, env);
      await tester.tap(find.byKey(const ValueKey('open-date')));
      await env.settle(tester);
      await tester.tap(find.text('OK'));
      await env.settle(tester);
      await tester.tap(find.byTooltip('Effacer la date'));
      await env.settle(tester);
      expect(find.text('Date (facultative)'), findsOneWidget);
    });
  });

  group('Modification', () {
    uiTest('champs préremplis, enregistrement met l\'open à jour',
        (tester, env) async {
      final id = await env.createOpen(tester,
          name: 'Ancien nom',
          location: 'Ancien lieu',
          date: DateTime(2026, 10, 3),
          bestOf: 9,
          grandFinalReset: true);
      final existing = (await env.opens(tester)).single;
      final popped = await openForm(tester, env, existing: existing);

      expect(find.text('Modifier l\'open'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Ancien nom'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Ancien lieu'), findsOneWidget);
      expect(find.text('sam. 3 oct. 2026'), findsOneWidget);
      expect(find.text('9 legs'), findsOneWidget);
      expect(tester.widget<SwitchListTile>(find.byKey(const ValueKey('open-reset'))).value, isTrue);

      await setName(tester, 'Nouveau nom');
      await save(tester, env);

      expect(popped.id, id);
      final open = (await env.opens(tester)).single;
      expect(open.name, 'Nouveau nom');
      expect(open.location, 'Ancien lieu');
      expect(open.bestOf, 9);
    });

    uiTest('un best-of hors liste (ancien open) reste sélectionnable',
        (tester, env) async {
      await env.createOpen(tester, name: 'Open bo1', bestOf: 1);
      final existing = (await env.opens(tester)).single;
      await openForm(tester, env, existing: existing);
      expect(find.text('1 legs'), findsOneWidget);
    });

    uiTest('open hérité de la v1 en « élimination simple » : proposé en double élimination',
        (tester, env) async {
      final id = await env.createOpen(tester, name: 'Open v1');
      await env.run(tester, () => env.db.customUpdate(
            "UPDATE opens SET format = 'single_elim' WHERE id = $id",
            updates: {env.db.opens},
          ));
      final existing = (await env.opens(tester)).single;
      expect(existing.format, OpenFormat.singleElim);

      await openForm(tester, env, existing: existing);
      expect(find.textContaining('ancien format par défaut'), findsOneWidget);
      expect(tester.widget<ChoiceChip>(find.byKey(const ValueKey('format-double_elim'))).selected, isTrue);

      await save(tester, env);
      expect((await env.opens(tester)).single.format, OpenFormat.doubleElim);
    });

    uiTest('erreur du repository affichée : open démarré entre-temps',
        (tester, env) async {
      final id = await env.createOpen(tester, name: 'Open qui démarre');
      final existing = (await env.opens(tester)).single;
      final popped = await openForm(tester, env, existing: existing);

      // Pendant que le formulaire est ouvert, le tableau est généré ailleurs.
      await env.startOpen(tester, id);

      await setName(tester, 'Nom refusé');
      await save(tester, env);

      expect(find.text('Cet open a déjà démarré : il n\'est plus modifiable.'), findsOneWidget);
      expect(popped.closed, isFalse); // formulaire toujours ouvert
      expect((await env.opens(tester)).single.name, 'Open qui démarre');
    });
  });
}
