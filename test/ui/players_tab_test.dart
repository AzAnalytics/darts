// Onglet Joueurs : autocomplétion, ajout, têtes de série, génération, verrouillage.
//
// Rappel du harnais : on prépare les données AVANT l'affichage ; « en direct »,
// un seul geste à la fois (voir test_harness.dart).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:darts/domain/open.dart';

import 'test_harness.dart';

const _field = ValueKey('add-player-field');

void main() {
  setUpUiTests();

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(_field), text);
    await tester.pump();
  }

  Future<void> tapKey(WidgetTester tester, UiTestEnv env, Key key) async {
    await tester.tap(find.byKey(key));
    await env.settle(tester);
  }

  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(find.byKey(_field)).controller!.text;

  bool addButtonEnabled(WidgetTester tester) =>
      tester.widget<IconButton>(find.byKey(const ValueKey('add-player-button'))).onPressed != null;

  Future<void> goToTab(WidgetTester tester, UiTestEnv env, String label) async {
    await tester.tap(find.widgetWithText(Tab, label));
    await env.settle(tester);
  }

  // ---------------------------------------------------------------------------
  group('Autocomplétion', () {
    // Joueurs connus : Jean, Jeanne, Jean-Pierre, Émile, Éric ; Marie déjà inscrite.
    Future<({int openId, Map<String, int> ids})> setUpKnown(
        WidgetTester tester, UiTestEnv env) async {
      final ids = await env.createPlayers(
          tester, ['Jean', 'Jeanne', 'Jean-Pierre', 'Émile', 'Éric', 'Marie']);
      final openId = await env.createOpen(tester);
      await env.run(tester, () => env.repo.registerPlayer(openId, ids['Marie']!));
      await env.pumpDetail(tester, openId);
      return (openId: openId, ids: ids);
    }

    uiTest('« jea » : les joueurs qui commencent par jea, puis « Créer « jea » »',
        (tester, env) async {
      final k = await setUpKnown(tester, env);
      await type(tester, 'jea');

      for (final n in ['Jean', 'Jeanne', 'Jean-Pierre']) {
        expect(find.byKey(ValueKey('suggestion-${k.ids[n]}')), findsOneWidget, reason: n);
      }
      expect(find.byKey(ValueKey('suggestion-${k.ids['Marie']}')), findsNothing);
      expect(find.byKey(const ValueKey('existing-suggestion')), findsNothing);
      expect(find.byKey(const ValueKey('create-player')), findsOneWidget);
      expect(find.text('Créer « jea »'), findsOneWidget);
      // Correspondances partielles seulement : « Ajouter » ne fait rien.
      expect(addButtonEnabled(tester), isFalse);
    });

    uiTest('« jean » (casse différente) : Jean existant, pas de création, aide affichée',
        (tester, env) async {
      await setUpKnown(tester, env);
      await type(tester, 'jean');

      expect(find.byKey(const ValueKey('existing-suggestion')), findsOneWidget);
      expect(find.text('Joueur existant (casse différente de votre saisie)'), findsOneWidget);
      expect(find.byKey(const ValueKey('create-player')), findsNothing);
      expect(find.textContaining('« jean » correspond à « Jean » : le joueur existant sera utilisé.'),
          findsOneWidget);
      expect(find.textContaining('Ajoutez une précision (ex. « Jean D. »)'), findsOneWidget);
      expect(addButtonEnabled(tester), isTrue);
    });

    uiTest('« Jean » exact : existant, sans remarque de casse', (tester, env) async {
      await setUpKnown(tester, env);
      await type(tester, 'Jean');
      expect(find.text('Joueur existant'), findsOneWidget);
      expect(find.textContaining('correspond à'), findsNothing);
      expect(find.byKey(const ValueKey('create-player')), findsNothing);
      expect(find.byKey(const ValueKey('homonym-hint')), findsOneWidget);
    });

    uiTest('« émile » (majuscule accentuée) retrouve Émile', (tester, env) async {
      await setUpKnown(tester, env);
      await type(tester, 'émile');
      expect(find.byKey(const ValueKey('existing-suggestion')), findsOneWidget);
      expect(find.text('Émile'), findsOneWidget);
      expect(find.byKey(const ValueKey('create-player')), findsNothing);
    });

    uiTest('FILET DE SÉCURITÉ : taper « ér » (avec l\'accent) fait remonter « Éric »',
        (tester, env) async {
      final k = await setUpKnown(tester, env);
      await type(tester, 'ér');

      expect(find.byKey(ValueKey('suggestion-${k.ids['Éric']}')), findsOneWidget);
      expect(find.text('Éric'), findsOneWidget);
      // Émile ne commence pas par « ér » : pas proposé.
      expect(find.byKey(ValueKey('suggestion-${k.ids['Émile']}')), findsNothing);

      // Un tap sur la suggestion inscrit bien Éric (et n'en crée pas un autre).
      final before = await env.playerCount(tester);
      await tester.tap(find.byKey(ValueKey('suggestion-${k.ids['Éric']}')));
      await env.settle(tester);
      final entries = await env.entries(tester, k.openId);
      expect(entries.map((e) => e.playerName), contains('Éric'));
      expect(await env.playerCount(tester), before);
    });

    uiTest('LIMITE ASSUMÉE : « eric » sans accent ne retrouve pas Éric',
        (tester, env) async {
      final k = await setUpKnown(tester, env);
      await type(tester, 'eric');
      expect(find.byKey(ValueKey('suggestion-${k.ids['Éric']}')), findsNothing);
      expect(find.byKey(const ValueKey('existing-suggestion')), findsNothing);
      expect(find.text('Créer « eric »'), findsOneWidget);
    });

    uiTest('déjà inscrit : message, ni création ni ajout', (tester, env) async {
      await setUpKnown(tester, env);
      await type(tester, 'marie');
      expect(find.text('« Marie » est déjà inscrit dans cet open.'), findsOneWidget);
      expect(find.byKey(const ValueKey('existing-suggestion')), findsNothing);
      expect(find.byKey(const ValueKey('create-player')), findsNothing);
      expect(addButtonEnabled(tester), isFalse);
    });

    uiTest('nom inconnu : seulement « Créer », qui sert aussi d\'action principale',
        (tester, env) async {
      await setUpKnown(tester, env);
      await type(tester, 'Zoé');
      expect(find.text('Créer « Zoé »'), findsOneWidget);
      expect(find.text('Nouveau joueur'), findsOneWidget);
      expect(find.byKey(const ValueKey('existing-suggestion')), findsNothing);
      expect(addButtonEnabled(tester), isTrue);
    });

    uiTest('champ vide : aucune proposition', (tester, env) async {
      await setUpKnown(tester, env);
      expect(find.byKey(const ValueKey('create-player')), findsNothing);
      expect(find.byKey(const ValueKey('existing-suggestion')), findsNothing);
      expect(addButtonEnabled(tester), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  group('Ajout d\'un joueur', () {
    uiTest('choisir un joueur existant : inscrit, aucun doublon, champ vidé',
        (tester, env) async {
      final ids = await env.createPlayers(tester, ['Jean', 'Bob']);
      final openId = await env.createOpen(tester);
      await env.pumpDetail(tester, openId);

      await type(tester, 'jean'); // casse différente
      await tester.tap(find.byKey(const ValueKey('existing-suggestion')));
      await env.settle(tester);

      final entries = await env.entries(tester, openId);
      expect(entries.map((e) => (e.playerId, e.playerName)), [(ids['Jean'], 'Jean')]);
      expect(await env.playerCount(tester), 2); // aucun nouveau joueur
      expect(fieldText(tester), '');
      expect(find.byKey(ValueKey('entry-${ids['Jean']}')), findsOneWidget);
    });

    uiTest('créer un nouveau joueur : créé puis inscrit', (tester, env) async {
      await env.createPlayers(tester, ['Jean']);
      final openId = await env.createOpen(tester);
      await env.pumpDetail(tester, openId);

      await type(tester, 'Zoé');
      await tapKey(tester, env, const ValueKey('create-player'));

      final entries = await env.entries(tester, openId);
      expect(entries.map((e) => e.playerName), ['Zoé']);
      expect(await env.playerCount(tester), 2);
      expect(fieldText(tester), '');
    });

    uiTest('la saisie est normalisée à la création (espaces superflus)', (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.pumpDetail(tester, openId);
      await type(tester, '  Zoé   Martin ');
      expect(find.text('Créer « Zoé Martin »'), findsOneWidget);
      await tapKey(tester, env, const ValueKey('create-player'));
      expect((await env.entries(tester, openId)).map((e) => e.playerName), ['Zoé Martin']);
    });

    uiTest('Entrée avec un joueur du même nom (casse ignorée) : ajoute l\'existant',
        (tester, env) async {
      final ids = await env.createPlayers(tester, ['Jean', 'Jeanne']);
      final openId = await env.createOpen(tester);
      await env.pumpDetail(tester, openId);

      await type(tester, 'JEAN');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await env.settle(tester);

      final entries = await env.entries(tester, openId);
      expect(entries.map((e) => e.playerId), [ids['Jean']]);
      expect(await env.playerCount(tester), 2);
    });

    uiTest('Entrée sans aucune suggestion : crée le joueur', (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.pumpDetail(tester, openId);
      await type(tester, 'Zoé');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await env.settle(tester);
      expect((await env.entries(tester, openId)).map((e) => e.playerName), ['Zoé']);
    });

    uiTest('Entrée avec des suggestions PARTIELLES seulement : ne crée RIEN (faute de frappe)',
        (tester, env) async {
      await env.createPlayers(tester, ['Jean', 'Jeanne']);
      final openId = await env.createOpen(tester);
      await env.pumpDetail(tester, openId);

      await type(tester, 'jea');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await env.settle(tester);

      expect(await env.entries(tester, openId), isEmpty);
      expect(await env.playerCount(tester), 2); // pas de joueur « jea »
      expect(fieldText(tester), 'jea'); // la saisie est conservée
    });

    uiTest('on peut enchaîner plusieurs joueurs', (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.pumpDetail(tester, openId);
      for (final name in ['Alice', 'Bob', 'Carl']) {
        await type(tester, name);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await env.settle(tester);
      }
      expect((await env.entries(tester, openId)).map((e) => e.playerName).toSet(),
          {'Alice', 'Bob', 'Carl'});
    });

    uiTest('la saisie survit à un changement d\'onglet', (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.pumpDetail(tester, openId);
      await type(tester, 'brouillon');
      await goToTab(tester, env, 'Tableau');
      await goToTab(tester, env, 'Joueurs');
      expect(fieldText(tester), 'brouillon');
    });
  });

  // ---------------------------------------------------------------------------
  group('Têtes de série', () {
    uiTest('sans classement : bandeau, numéros « – », « Garder cet ordre » classe dans l\'ordre d\'inscription',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      final ids = await env.registerPlayers(tester, openId, 3, seeded: false);
      await env.pumpDetail(tester, openId);

      expect(find.text('Têtes de série non définies.'), findsOneWidget);
      for (final id in ids) {
        expect(tester.widget<Text>(find.byKey(ValueKey('seed-$id'))).data, '–');
      }

      await tapKey(tester, env, const ValueKey('keep-order'));

      final entries = await env.entries(tester, openId);
      expect(entries.map((e) => (e.playerName, e.seed)), [('J1', 1), ('J2', 2), ('J3', 3)]);
      expect(find.byKey(const ValueKey('seeding-banner')), findsNothing);
      expect(tester.widget<Text>(find.byKey(ValueKey('seed-${ids[2]}'))).data, '3');
    });

    uiTest('glisser un joueur change le classement (enregistré en base)',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      final ids = await env.registerPlayers(tester, openId, 3); // J1, J2, J3 classés
      await env.pumpDetail(tester, openId);

      // J3 remonte tout en haut.
      await env.dragBy(tester, find.byKey(ValueKey('drag-${ids[2]}')), const Offset(0, -160));

      final entries = await env.entries(tester, openId);
      expect(entries.map((e) => (e.playerName, e.seed)), [('J3', 1), ('J1', 2), ('J2', 3)]);
      // L'écran suit : J3 est affiché en premier avec le numéro 1.
      expect(tester.widget<Text>(find.byKey(ValueKey('seed-${ids[2]}'))).data, '1');
      final yJ3 = tester.getTopLeft(find.byKey(ValueKey('entry-${ids[2]}'))).dy;
      final yJ1 = tester.getTopLeft(find.byKey(ValueKey('entry-${ids[0]}'))).dy;
      expect(yJ3, lessThan(yJ1));
    });

    uiTest('glisser sur une liste sans classement : tous reçoivent une tête de série',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      final ids = await env.registerPlayers(tester, openId, 3, seeded: false);
      await env.pumpDetail(tester, openId);

      await env.dragBy(tester, find.byKey(ValueKey('drag-${ids[0]}')), const Offset(0, 160));

      final entries = await env.entries(tester, openId);
      expect(entries.every((e) => e.seed != null), isTrue);
      expect(entries.map((e) => e.seed), [1, 2, 3]);
      expect(entries.map((e) => e.playerName), ['J2', 'J3', 'J1']);
      expect(find.byKey(const ValueKey('seeding-banner')), findsNothing);
    });

    uiTest('tirage au sort sans classement : direct, classement complet', (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.registerPlayers(tester, openId, 4, seeded: false);
      await env.pumpDetail(tester, openId);

      await tapKey(tester, env, const ValueKey('shuffle-seeds'));

      expect(find.text('Refaire le tirage au sort ?'), findsNothing); // pas de confirmation
      final entries = await env.entries(tester, openId);
      expect(entries.map((e) => e.seed), [1, 2, 3, 4]);
      expect(entries.map((e) => e.playerName).toSet(), {'J1', 'J2', 'J3', 'J4'});
      expect(find.byKey(const ValueKey('seeding-banner')), findsNothing);
    });

    uiTest('tirage au sort avec classement : confirmation ; annuler ne change rien',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.registerPlayers(tester, openId, 4); // classés J1..J4
      await env.pumpDetail(tester, openId);

      await tapKey(tester, env, const ValueKey('shuffle-seeds'));
      expect(find.text('Refaire le tirage au sort ?'), findsOneWidget);
      expect(find.text('Le classement actuel des têtes de série sera remplacé.'), findsOneWidget);
      await tester.tap(find.text('Annuler'));
      await env.settle(tester);

      final entries = await env.entries(tester, openId);
      expect(entries.map((e) => (e.playerName, e.seed)),
          [('J1', 1), ('J2', 2), ('J3', 3), ('J4', 4)]);
    });

    uiTest('tirage au sort avec classement : confirmer refait un classement complet',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.registerPlayers(tester, openId, 6);
      await env.pumpDetail(tester, openId);

      await tapKey(tester, env, const ValueKey('shuffle-seeds'));
      await tester.tap(find.text('Refaire le tirage'));
      await env.settle(tester);

      final entries = await env.entries(tester, openId);
      expect(entries.map((e) => e.seed), [1, 2, 3, 4, 5, 6]);
      expect(entries.map((e) => e.playerName).toSet(),
          {'J1', 'J2', 'J3', 'J4', 'J5', 'J6'});
    });

    uiTest('tirage au sort grisé avec moins de 2 joueurs', (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.registerPlayers(tester, openId, 1, seeded: false);
      await env.pumpDetail(tester, openId);
      final button = tester.widget<ButtonStyleButton>(find.byKey(const ValueKey('shuffle-seeds')));
      expect(button.onPressed, isNull);
    });

    uiTest('retirer un joueur : les têtes de série se resserrent', (tester, env) async {
      final openId = await env.createOpen(tester);
      final ids = await env.registerPlayers(tester, openId, 4); // J1..J4
      await env.pumpDetail(tester, openId);

      await tapKey(tester, env, ValueKey('remove-${ids[1]}')); // J2 part

      final entries = await env.entries(tester, openId);
      expect(entries.map((e) => (e.playerName, e.seed)), [('J1', 1), ('J3', 2), ('J4', 3)]);
      expect(find.byKey(ValueKey('entry-${ids[1]}')), findsNothing);
      expect(find.byKey(const ValueKey('seeding-banner')), findsNothing);
    });

    uiTest('joueur ajouté APRÈS le classement : dernière tête de série automatique, prêt à générer',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.registerPlayers(tester, openId, 3); // classés
      await env.pumpDetail(tester, openId);

      await type(tester, 'Zoé');
      await tapKey(tester, env, const ValueKey('create-player'));

      final entries = await env.entries(tester, openId);
      expect(entries.map((e) => (e.playerName, e.seed)),
          [('J1', 1), ('J2', 2), ('J3', 3), ('Zoé', 4)]);
      expect(find.byKey(const ValueKey('seeding-banner')), findsNothing);
      expect(find.text('Prêt : 4 joueurs.'), findsOneWidget);
    });

    uiTest('joueur ajouté quand il n\'y a PAS de classement : pas de tête de série',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.registerPlayers(tester, openId, 3, seeded: false);
      await env.pumpDetail(tester, openId);

      await type(tester, 'Zoé');
      await tapKey(tester, env, const ValueKey('create-player'));

      expect((await env.entries(tester, openId)).every((e) => e.seed == null), isTrue);
      expect(find.text('Têtes de série non définies.'), findsOneWidget);
    });

    uiTest('classement partiel : bandeau « N joueur(s) sans tête de série »',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.registerPlayers(tester, openId, 4);
      await env.run(
        tester,
        () => env.db.customUpdate(
          'UPDATE open_entries SET seed = NULL WHERE seed >= 3',
          updates: {env.db.openEntries},
        ),
      );
      await env.pumpDetail(tester, openId);
      expect(find.text('2 joueurs sans tête de série.'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  group('Bouton « Générer le tableau » : état et message', () {
    String message(WidgetTester tester) =>
        tester.widget<Text>(find.byKey(const ValueKey('generate-message'))).data!;

    bool generateEnabled(WidgetTester tester) =>
        tester.widget<ButtonStyleButton>(find.byKey(const ValueKey('generate-bracket'))).onPressed !=
        null;

    uiTest('aucun joueur : grisé, « 0 inscrit »', (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.pumpDetail(tester, openId);
      expect(message(tester), 'Il faut au moins 3 joueurs : 0 inscrit pour l\'instant.');
      expect(generateEnabled(tester), isFalse);
    });

    uiTest('2 joueurs classés : grisé, « 2 inscrits »', (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.registerPlayers(tester, openId, 2);
      await env.pumpDetail(tester, openId);
      expect(message(tester), 'Il faut au moins 3 joueurs : 2 inscrits pour l\'instant.');
      expect(generateEnabled(tester), isFalse);
    });

    uiTest('3 joueurs sans classement : grisé, message sur les têtes de série',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.registerPlayers(tester, openId, 3, seeded: false);
      await env.pumpDetail(tester, openId);
      expect(message(tester),
          'Définissez les têtes de série : glissez les joueurs pour les classer, ou faites le tirage au sort.');
      expect(generateEnabled(tester), isFalse);
    });

    uiTest('classement partiel : grisé, « 1 joueur n\'a pas de tête de série »',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.registerPlayers(tester, openId, 3);
      await env.run(
        tester,
        () => env.db.customUpdate('UPDATE open_entries SET seed = NULL WHERE seed = 3',
            updates: {env.db.openEntries}),
      );
      await env.pumpDetail(tester, openId);
      expect(message(tester),
          '1 joueur n\'a pas de tête de série : classez-le ou refaites le tirage.');
      expect(generateEnabled(tester), isFalse);
    });

    uiTest('format non disponible (open hérité de la v1) : grisé, message dédié',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.registerPlayers(tester, openId, 3);
      await env.run(
        tester,
        () => env.db.customUpdate("UPDATE opens SET format = 'single_elim'",
            updates: {env.db.opens}),
      );
      await env.pumpDetail(tester, openId);
      expect(message(tester),
          'Le format « Élimination simple » n\'est pas encore disponible : modifiez le format de l\'open (menu ⋮ › Modifier).');
      expect(generateEnabled(tester), isFalse);
    });

    uiTest('tout est prêt : actif, « Prêt : N joueurs. »', (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.registerPlayers(tester, openId, 5);
      await env.pumpDetail(tester, openId);
      expect(message(tester), 'Prêt : 5 joueurs.');
      expect(generateEnabled(tester), isTrue);
    });

    uiTest('le message suit les changements en direct : 2 joueurs → 3 → classé',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.registerPlayers(tester, openId, 2, seeded: false);
      await env.pumpDetail(tester, openId);
      expect(message(tester), contains('Il faut au moins 3 joueurs'));

      // Un troisième joueur arrive (un seul geste en direct).
      await type(tester, 'Zoé');
      await tapKey(tester, env, const ValueKey('create-player'));
      expect(message(tester), startsWith('Définissez les têtes de série'));
      expect(generateEnabled(tester), isFalse);

      // « Garder cet ordre » : classement complet, la génération devient possible.
      await tapKey(tester, env, const ValueKey('keep-order'));
      expect(message(tester), 'Prêt : 3 joueurs.');
      expect(generateEnabled(tester), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  group('Génération et verrouillage', () {
    uiTest('annuler la confirmation : rien n\'est généré', (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.registerPlayers(tester, openId, 4);
      await env.pumpDetail(tester, openId);

      await tapKey(tester, env, const ValueKey('generate-bracket'));
      expect(find.text('Générer le tableau ?'), findsOneWidget);
      expect(
          find.text('Après la génération, les inscriptions et les têtes de série ne pourront plus être modifiées.'),
          findsOneWidget);
      await tester.tap(find.text('Annuler'));
      await env.settle(tester);

      final open = (await env.opens(tester)).single;
      expect(open.status, OpenStatus.setup);
      expect(find.byKey(const ValueKey('generate-bracket')), findsOneWidget);
    });

    uiTest('confirmer : open en cours, bascule sur le tableau, inscriptions verrouillées',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      final ids = await env.registerPlayers(tester, openId, 4);
      await env.pumpDetail(tester, openId);

      await tapKey(tester, env, const ValueKey('generate-bracket'));
      await tester.tap(find.text('Générer'));
      await env.settle(tester);

      // Statut passé de « Inscriptions » à « En cours », tableau généré (2N − 2).
      final open = (await env.opens(tester)).single;
      expect(open.status, OpenStatus.running);
      final bracket = await env.run(tester, () => env.repo.watchBracket(openId).first);
      expect(bracket.nodes.length, 2 * 4 - 2);
      expect(find.text('En cours'), findsOneWidget);
      expect(find.text('Tableau généré.'), findsOneWidget); // confirmation

      // L'écran bascule sur l'onglet Tableau.
      expect(find.text('L\'affichage du tableau arrive bientôt.'), findsOneWidget);

      // Joueurs : plus rien de modifiable.
      await goToTab(tester, env, 'Joueurs');
      expect(find.byKey(_field), findsNothing);
      expect(find.byKey(const ValueKey('generate-bracket')), findsNothing);
      expect(find.byKey(const ValueKey('shuffle-seeds')), findsNothing);
      expect(find.byKey(const ValueKey('keep-order')), findsNothing);
      for (final id in ids) {
        expect(find.byKey(ValueKey('remove-$id')), findsNothing);
        expect(find.byKey(ValueKey('drag-$id')), findsNothing);
        expect(find.byKey(ValueKey('entry-$id')), findsOneWidget); // toujours listés
      }
      expect(find.text('Tableau généré : les inscriptions sont closes.'), findsOneWidget);
    });

    uiTest('côté repository aussi : inscription et classement refusés une fois généré',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      final ids = await env.registerPlayers(tester, openId, 3);
      await env.run(tester, () => env.repo.generateBracket(openId));
      final late = (await env.createPlayers(tester, ['Retardataire']))['Retardataire']!;
      await expectLater(
          env.run(tester, () => env.repo.registerPlayer(openId, late)), throwsA(anything));
      await expectLater(
          env.run(tester, () => env.repo.unregisterPlayer(openId, ids[0])), throwsA(anything));
      await expectLater(
          env.run(tester, () => env.repo.setSeeds(openId, ids)), throwsA(anything));
      await expectLater(
          env.run(tester, () => env.repo.shuffleSeeds(openId)), throwsA(anything));
      await expectLater(
          env.run(tester, () => env.repo.generateBracket(openId)), throwsA(anything));
    });

    uiTest('open déjà démarré : s\'ouvre sur Tableau, Joueurs en lecture seule avec les têtes de série',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      final ids = await env.registerPlayers(tester, openId, 3);
      await env.run(tester, () => env.repo.generateBracket(openId));
      await env.pumpDetail(tester, openId);

      expect(find.text('L\'affichage du tableau arrive bientôt.'), findsOneWidget);
      await goToTab(tester, env, 'Joueurs');
      expect(find.byKey(const ValueKey('closed-banner')), findsOneWidget);
      for (var i = 0; i < ids.length; i++) {
        expect(tester.widget<Text>(find.byKey(ValueKey('seed-${ids[i]}'))).data, '${i + 1}');
      }
    });

    uiTest('open terminé : s\'ouvre sur Classement, bandeau « Open terminé. »',
        (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.registerPlayers(tester, openId, 3);
      await env.run(tester, () async {
        await env.repo.generateBracket(openId);
        // Forfaits jusqu'à la fin de l'open (aucune donnée de match nécessaire).
        while ((await env.repo.watchOpen(openId).first)!.status != OpenStatus.finished) {
          final node = (await env.repo.watchBracket(openId).first).readyNodes.first;
          await env.repo.reportWalkover(node.id!, node.playerA!);
        }
      });
      await env.pumpDetail(tester, openId);

      expect(find.text('Terminé'), findsOneWidget);
      expect(find.text('Le classement final apparaîtra ici à la fin de l\'open.'), findsOneWidget);
      await goToTab(tester, env, 'Joueurs');
      expect(find.text('Open terminé.'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  group('Onglets', () {
    uiTest('trois onglets ; open en inscriptions : s\'ouvre sur Joueurs', (tester, env) async {
      final openId = await env.createOpen(tester);
      await env.pumpDetail(tester, openId);
      for (final label in ['Joueurs', 'Tableau', 'Classement']) {
        expect(find.widgetWithText(Tab, label), findsOneWidget, reason: label);
      }
      expect(find.byKey(_field), findsOneWidget);
    });

    uiTest('détails de l\'open repliés par défaut, dépliables', (tester, env) async {
      final openId = await env.createOpen(tester, location: 'Gymnase', bestOf: 7);
      await env.pumpDetail(tester, openId);
      expect(find.text('Gymnase'), findsNothing);
      await tester.tap(find.text('Détails de l\'open'));
      await env.settle(tester);
      expect(find.text('Gymnase'), findsOneWidget);
      expect(find.text('Best of 7 legs par défaut'), findsOneWidget);
    });
  });
}
