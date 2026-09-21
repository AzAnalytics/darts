// Harnais de test des écrans : vrai repository sur SQLite en mémoire.
//
// Recette VÉRIFIÉE pour les flux Drift sous testWidgets :
//  - tout appel au repository (vrai async) passe par tester.runAsync ;
//  - pour laisser un flux émettre : attente réelle (runAsync) puis pump ;
//  - EN FIN DE TEST : démonter l'arbre, faire avancer le temps SIMULÉ d'1 s (le
//    minuteur de fermeture des flux Drift y vit), PUIS fermer la base.
//    Fermer sans avoir fait avancer le temps bloque indéfiniment ; ne pas
//    fermer laisse « A Timer is still pending ».
// MISE EN GARDE — écritures pendant qu'un flux est affiché : la relecture d'un
// flux démarre dans le temps SIMULÉ et ne progresse qu'aux pump(), alors que
// tester.runAsync attend sans pump. Une série d'écritures (ex. startOpen :
// inscriptions + génération) lancée pendant qu'un écran écoute peut donc rester
// bloquée. Préparer les données AVANT pumpScreen, et ne déclencher « en direct »
// qu'un seul geste (une écriture, ou une transaction unique comme
// generateBracket), suivi de settle().
// Lancer les tests d'écran avec `--timeout` : un test bloqué laisse un processus
// flutter_tester.exe à arrêter à la main.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:darts/data/database.dart';
import 'package:darts/data/repository.dart';
import 'package:darts/domain/open.dart';
import 'package:darts/ui/app_localization.dart';
import 'package:darts/ui/opens/open_detail_screen.dart';

/// Données de date françaises pour formatDate(). À appeler dans main() du test.
void setUpUiTests() {
  setUpAll(() => initializeDateFormatting('fr'));
}

class UiTestEnv {
  final AppDatabase db = AppDatabase.forTesting(NativeDatabase.memory());
  late final DriftDartsRepository repo = DriftDartsRepository(db);

  /// Exécute du vrai async (appels au repository) et renvoie le résultat.
  /// Une exception de l'action est RELANCÉE : tester.runAsync, seul, l'avale et
  /// renvoie null, ce qui masquerait une préparation de test échouée.
  Future<T> run<T>(WidgetTester tester, Future<T> Function() action) async {
    T? value;
    Object? error;
    StackTrace? stack;
    await tester.runAsync(() async {
      try {
        value = await action();
      } catch (e, s) {
        error = e;
        stack = s;
      }
    });
    if (error != null) Error.throwWithStackTrace(error!, stack!);
    return value as T;
  }

  /// Glisse un élément par étapes (le glisser-déposer a besoin de frames
  /// intermédiaires pour évaluer la position ; un seul déplacement ne suffit pas).
  Future<void> dragBy(WidgetTester tester, Finder handle, Offset offset) async {
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(const Duration(milliseconds: 50));
    const steps = 6;
    for (var i = 0; i < steps; i++) {
      await gesture.moveBy(offset / steps.toDouble());
      await tester.pump(const Duration(milliseconds: 30));
    }
    await gesture.up();
    await settle(tester);
  }

  /// Laisse les flux Drift émettre, puis reconstruit l'arbre (et joue les
  /// animations : navigation, SnackBar, menus).
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 60)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  /// Affiche [home] dans une MaterialApp localisée en français.
  Future<void> pumpScreen(WidgetTester tester, Widget home) async {
    // Grand écran : les formulaires tiennent sans défilement.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      locale: appLocale,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      home: home,
    ));
    await settle(tester);
  }

  /// Démonte, avance le temps simulé, ferme la base (voir la recette ci-dessus).
  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  }

  // --- Raccourcis de mise en place ---

  Future<int> createOpen(
    WidgetTester tester, {
    String name = 'Open test',
    String? location,
    DateTime? date,
    int bestOf = 5,
    bool grandFinalReset = false,
  }) {
    return run(
      tester,
      () => repo.createOpen(NewOpen(
        name: name,
        location: location,
        date: date,
        bestOf: bestOf,
        grandFinalReset: grandFinalReset,
      )),
    );
  }

  /// Inscrit [players] joueurs J1..Jn à l'open ; classés dans l'ordre si [seeded].
  Future<List<int>> registerPlayers(
      WidgetTester tester, int openId, int players,
      {bool seeded = true}) {
    return run(tester, () async {
      final ids = <int>[];
      for (var i = 1; i <= players; i++) {
        final id = await repo.getOrCreatePlayer('J$i');
        ids.add(id);
        await repo.registerPlayer(openId, id);
      }
      if (seeded && ids.isNotEmpty) await repo.setSeeds(openId, ids);
      return ids;
    });
  }

  /// Crée des joueurs connus (sans les inscrire) et renvoie leurs ids par nom.
  Future<Map<String, int>> createPlayers(
      WidgetTester tester, List<String> names) {
    return run(tester, () async {
      return {for (final n in names) n: await repo.getOrCreatePlayer(n)};
    });
  }

  /// Affiche le détail d'un open, poussé sur un écran d'accueil factice.
  Future<void> pumpDetail(WidgetTester tester, int openId) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => OpenDetailScreen(repo: repo, openId: openId),
              )),
              child: const Text('ouvrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await settle(tester);
  }

  Future<List<OpenEntry>> entries(WidgetTester tester, int openId) =>
      run(tester, () => repo.watchEntries(openId).first);

  Future<int> playerCount(WidgetTester tester) =>
      run(tester, () async => (await db.select(db.players).get()).length);

  /// Inscrit [players] joueurs puis génère le tableau : l'open passe en `running`.
  Future<void> startOpen(WidgetTester tester, int openId, {int players = 3}) {
    return run(tester, () async {
      final ids = <int>[];
      for (var i = 1; i <= players; i++) {
        final id = await repo.getOrCreatePlayer('J$i');
        ids.add(id);
        await repo.registerPlayer(openId, id);
      }
      await repo.setSeeds(openId, ids);
      await repo.generateBracket(openId);
    });
  }

  Future<List<OpenSummary>> opens(WidgetTester tester) =>
      run(tester, () => repo.watchOpens().first);
}

/// testWidgets avec environnement : crée la base, exécute [body], puis démonte
/// et ferme dans le bon ordre même si le test échoue. Délai maximal de 30 s.
void uiTest(
  String description,
  Future<void> Function(WidgetTester tester, UiTestEnv env) body,
) {
  testWidgets(
    description,
    (tester) async {
      final env = UiTestEnv();
      try {
        await body(tester, env);
      } finally {
        await env.dispose(tester);
      }
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
