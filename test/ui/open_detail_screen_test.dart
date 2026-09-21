import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:darts/ui/opens/open_detail_screen.dart';
import 'package:darts/ui/opens/open_form_screen.dart';

import 'test_harness.dart';

void main() {
  setUpUiTests();

  /// Écran d'accueil factice + détail poussé dessus : on voit ainsi si le
  /// détail se referme bien (retour sur « ouvrir »).
  Future<void> openDetail(WidgetTester tester, UiTestEnv env, int openId) async {
    await env.pumpScreen(
      tester,
      Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => OpenDetailScreen(repo: env.repo, openId: openId),
              )),
              child: const Text('ouvrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await env.settle(tester);
    expect(find.byType(OpenDetailScreen), findsOneWidget);
  }

  Future<void> openMenu(WidgetTester tester, UiTestEnv env) async {
    await tester.tap(find.byKey(const ValueKey('detail-menu')));
    await env.settle(tester);
  }

  bool menuItemEnabled(WidgetTester tester, String label) {
    final item = find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((w) => w is PopupMenuItem),
    );
    return (tester.widget(item) as PopupMenuItem).enabled;
  }

  /// Les détails de l'open sont repliés par défaut dans l'onglet Joueurs.
  Future<void> expandDetails(WidgetTester tester, UiTestEnv env) async {
    await tester.tap(find.text('Détails de l\'open'));
    await env.settle(tester);
  }

  /// Ouvre l'onglet Joueurs (un open démarré s'ouvre sur l'onglet Tableau).
  Future<void> goToPlayersTab(WidgetTester tester, UiTestEnv env) async {
    await tester.tap(find.widgetWithText(Tab, 'Joueurs'));
    await env.settle(tester);
  }

  uiTest('affiche les informations de l\'open', (tester, env) async {
    final id = await env.createOpen(tester,
        name: 'Open des champions',
        location: 'Gymnase',
        date: DateTime(2026, 10, 3),
        bestOf: 7);
    await env.registerPlayers(tester, id, 2);
    await openDetail(tester, env, id);
    await expandDetails(tester, env);

    expect(find.text('Open des champions'), findsOneWidget); // titre
    expect(find.text('Inscriptions'), findsOneWidget); // statut
    expect(find.text('2 inscrits'), findsOneWidget);
    expect(find.text('sam. 3 oct. 2026'), findsOneWidget);
    expect(find.text('Gymnase'), findsOneWidget);
    expect(find.text('Double élimination'), findsOneWidget);
    expect(find.text('Best of 7 legs par défaut'), findsOneWidget);
    expect(find.text('Grande finale en un seul match'), findsOneWidget);
  });

  uiTest('reset activé : la ligne le mentionne', (tester, env) async {
    final id = await env.createOpen(tester, grandFinalReset: true);
    await openDetail(tester, env, id);
    await expandDetails(tester, env);
    expect(find.text('Grande finale avec reset possible'), findsOneWidget);
  });

  group('Modifier', () {
    uiTest('ouvre le formulaire prérempli ; le titre se met à jour ensuite',
        (tester, env) async {
      final id = await env.createOpen(tester, name: 'Avant');
      await openDetail(tester, env, id);

      await openMenu(tester, env);
      await tester.tap(find.text('Modifier'));
      await env.settle(tester);
      expect(find.byType(OpenFormScreen), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Avant'), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('open-name')), 'Après');
      await tester.tap(find.byKey(const ValueKey('save-open')));
      await env.settle(tester);

      // Retour sur le détail, mis à jour par le flux (rien à recharger).
      expect(find.byType(OpenDetailScreen), findsOneWidget);
      expect(find.text('Après'), findsOneWidget);
      expect(find.text('Avant'), findsNothing);
    });
  });

  group('Supprimer', () {
    uiTest('confirmation, puis l\'écran se referme et l\'open disparaît',
        (tester, env) async {
      final id = await env.createOpen(tester, name: 'À supprimer');
      await openDetail(tester, env, id);

      await openMenu(tester, env);
      await tester.tap(find.text('Supprimer'));
      await env.settle(tester);
      expect(find.text('Supprimer cet open ?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
      await env.settle(tester);

      expect(find.byType(OpenDetailScreen), findsNothing);
      expect(find.text('ouvrir'), findsOneWidget); // retour à l'écran précédent
      expect(await env.opens(tester), isEmpty);
    });

    uiTest('annuler la confirmation conserve l\'open', (tester, env) async {
      final id = await env.createOpen(tester, name: 'Je reste');
      await openDetail(tester, env, id);

      await openMenu(tester, env);
      await tester.tap(find.text('Supprimer'));
      await env.settle(tester);
      await tester.tap(find.text('Annuler'));
      await env.settle(tester);

      expect(find.byType(OpenDetailScreen), findsOneWidget);
      expect((await env.opens(tester)).single.name, 'Je reste');
    });

    uiTest('supprimé depuis ailleurs : l\'écran se referme tout seul',
        (tester, env) async {
      final id = await env.createOpen(tester, name: 'Supprimé ailleurs');
      await openDetail(tester, env, id);

      await env.run(tester, () => env.repo.deleteOpen(id));
      await env.settle(tester);

      expect(find.byType(OpenDetailScreen), findsNothing);
      expect(find.text('ouvrir'), findsOneWidget);
    });
  });

  group('Open démarré : verrouillage', () {
    uiTest('Modifier et Supprimer sont grisés, le message l\'explique',
        (tester, env) async {
      final id = await env.createOpen(tester, name: 'Déjà lancé');
      await env.startOpen(tester, id);
      await openDetail(tester, env, id);

      expect(find.text('En cours'), findsOneWidget);
      await goToPlayersTab(tester, env);
      expect(find.text('Cet open a démarré : il n\'est plus modifiable.'), findsOneWidget);

      await openMenu(tester, env);
      expect(menuItemEnabled(tester, 'Modifier'), isFalse);
      expect(menuItemEnabled(tester, 'Supprimer'), isFalse);

      // Toucher un élément grisé ne fait rien.
      await tester.tap(find.text('Modifier'), warnIfMissed: false);
      await env.settle(tester);
      expect(find.byType(OpenFormScreen), findsNothing);
    });

    uiTest('à l\'inverse, actifs tant que l\'open est en inscriptions',
        (tester, env) async {
      final id = await env.createOpen(tester);
      await openDetail(tester, env, id);
      await openMenu(tester, env);
      expect(menuItemEnabled(tester, 'Modifier'), isTrue);
      expect(menuItemEnabled(tester, 'Supprimer'), isTrue);
    });

    uiTest('le verrouillage apparaît en direct quand le tableau est généré',
        (tester, env) async {
      final id = await env.createOpen(tester);
      // Joueurs inscrits AVANT l'affichage ; un seul geste « en direct » ensuite
      // (voir la mise en garde du harnais sur les écritures multiples).
      await env.registerPlayers(tester, id, 3);
      await openDetail(tester, env, id);
      expect(find.text('Inscriptions'), findsOneWidget);

      await env.run(tester, () => env.repo.generateBracket(id));
      await env.settle(tester);

      expect(find.text('En cours'), findsOneWidget);
      // L'écran bascule tout seul sur l'onglet Tableau…
      expect(find.text('L\'affichage du tableau arrive bientôt.'), findsOneWidget);
      // …et l'onglet Joueurs explique le verrouillage.
      await goToPlayersTab(tester, env);
      expect(find.text('Cet open a démarré : il n\'est plus modifiable.'), findsOneWidget);
    });
  });
}
