import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:darts/main.dart';
import 'package:darts/ui/opens/open_detail_screen.dart';
import 'package:darts/ui/opens/open_form_screen.dart';
import 'package:darts/ui/opens/open_list_screen.dart';

import 'test_harness.dart';

void main() {
  setUpUiTests();

  uiTest('liste vide : message et bouton « Nouvel open »', (tester, env) async {
    await env.pumpScreen(tester, OpenListScreen(repo: env.repo));
    expect(find.text('Aucun open pour l\'instant.'), findsOneWidget);
    expect(find.byKey(const ValueKey('new-open')), findsOneWidget);
  });

  uiTest('affiche nom, date, lieu, format, best-of, statut et inscrits',
      (tester, env) async {
    final a = await env.createOpen(tester,
        name: 'Open de printemps',
        location: 'Salle des fêtes',
        date: DateTime(2026, 10, 3),
        bestOf: 7);
    await env.registerPlayers(tester, a, 2);
    await env.createOpen(tester, name: 'Open sans date');

    await env.pumpScreen(tester, OpenListScreen(repo: env.repo));

    expect(find.text('Open de printemps'), findsOneWidget);
    expect(find.text('sam. 3 oct. 2026 · Salle des fêtes'), findsOneWidget);
    expect(find.text('Double élimination · best of 7'), findsOneWidget);
    expect(find.text('2 inscrits'), findsOneWidget);
    expect(find.text('Open sans date'), findsOneWidget);
    expect(find.text('Date à définir'), findsOneWidget);
    expect(find.text('0 inscrit'), findsOneWidget);
    expect(find.text('Inscriptions'), findsNWidgets(2));

    // Ordre : le plus récent d'abord, sans date en dernier.
    final firstY = tester.getTopLeft(find.text('Open de printemps')).dy;
    final lastY = tester.getTopLeft(find.text('Open sans date')).dy;
    expect(firstY, lessThan(lastY));
  });

  uiTest('réactif : un open créé ailleurs apparaît sans rechargement',
      (tester, env) async {
    await env.pumpScreen(tester, OpenListScreen(repo: env.repo));
    expect(find.text('Aucun open pour l\'instant.'), findsOneWidget);

    await env.createOpen(tester, name: 'Open surprise');
    await env.settle(tester);

    expect(find.text('Open surprise'), findsOneWidget);
    expect(find.text('Aucun open pour l\'instant.'), findsNothing);
  });

  uiTest('statut « En cours » pour un open démarré', (tester, env) async {
    final id = await env.createOpen(tester, name: 'Open lancé');
    await env.startOpen(tester, id);
    await env.pumpScreen(tester, OpenListScreen(repo: env.repo));
    expect(find.text('En cours'), findsOneWidget);
    expect(find.text('3 inscrits'), findsOneWidget);
  });

  uiTest('créer un open : formulaire, puis détail, puis retour à la liste',
      (tester, env) async {
    await env.pumpScreen(tester, OpenListScreen(repo: env.repo));

    await tester.tap(find.byKey(const ValueKey('new-open')));
    await env.settle(tester);
    expect(find.byType(OpenFormScreen), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('open-name')), 'Open d\'automne');
    await tester.tap(find.byKey(const ValueKey('save-open')));
    await env.settle(tester);

    // Après la création : on arrive sur le détail de l'open créé.
    expect(find.byType(OpenDetailScreen), findsOneWidget);
    expect(find.text('Open d\'automne'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await env.settle(tester);
    expect(find.byType(OpenListScreen), findsOneWidget);
    expect(find.text('Open d\'automne'), findsOneWidget);
  });

  uiTest('toucher une carte ouvre le détail', (tester, env) async {
    await env.createOpen(tester, name: 'Open à ouvrir');
    await env.pumpScreen(tester, OpenListScreen(repo: env.repo));

    await tester.tap(find.text('Open à ouvrir'));
    await env.settle(tester);
    expect(find.byType(OpenDetailScreen), findsOneWidget);
  });

  uiTest('l\'accueil propose « Opens » qui ouvre la liste', (tester, env) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(DartsApp(repo: env.repo));
    await env.settle(tester);

    expect(find.text('Nouveau match'), findsOneWidget);
    expect(find.text('Historique & classements'), findsOneWidget);
    await tester.tap(find.text('Opens'));
    await env.settle(tester);
    expect(find.byType(OpenListScreen), findsOneWidget);
  });
}
