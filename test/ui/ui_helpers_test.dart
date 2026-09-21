import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:darts/domain/open.dart';
import 'package:darts/domain/open_state_exception.dart';
import 'package:darts/ui/ui_helpers.dart';

import 'test_harness.dart';

void main() {
  setUpUiTests();

  group('Libellés', () {
    test('statusLabel', () {
      expect(statusLabel(OpenStatus.setup), 'Inscriptions');
      expect(statusLabel(OpenStatus.running), 'En cours');
      expect(statusLabel(OpenStatus.finished), 'Terminé');
      expect(statusLabel('inconnu'), 'inconnu'); // jamais de plantage
    });

    test('formatLabel', () {
      expect(formatLabel(OpenFormat.singleElim), 'Élimination simple');
      expect(formatLabel(OpenFormat.doubleElim), 'Double élimination');
      expect(formatLabel(OpenFormat.groupsKnockout), 'Poules + phase finale');
    });

    test('isFormatAvailable : seule la double élimination est générable', () {
      expect(isFormatAvailable(OpenFormat.doubleElim), isTrue);
      expect(isFormatAvailable(OpenFormat.singleElim), isFalse);
      expect(isFormatAvailable(OpenFormat.groupsKnockout), isFalse);
    });

    test('entryCountLabel : singulier jusqu\'à 1', () {
      expect(entryCountLabel(0), '0 inscrit');
      expect(entryCountLabel(1), '1 inscrit');
      expect(entryCountLabel(2), '2 inscrits');
      expect(entryCountLabel(16), '16 inscrits');
    });

    test('formatDate : jour abrégé, mois abrégé, en français', () {
      expect(formatDate(DateTime(2026, 10, 3)), 'sam. 3 oct. 2026');
      expect(formatDate(DateTime(2027, 1, 1)), 'ven. 1 janv. 2027');
    });
  });

  test('bestOfOptions : les valeurs proposées pour un match', () {
    expect(bestOfOptions, [3, 5, 7, 9, 11]);
    expect(bestOfOptions.every((n) => n.isOdd), isTrue);
  });

  group('runAction', () {
    late BuildContext context;

    Future<void> pumpHost(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (c) {
            context = c;
            return const SizedBox();
          }),
        ),
      ));
    }

    testWidgets('succès : renvoie le résultat, aucun message', (tester) async {
      await pumpHost(tester);
      int? result;
      await tester.runAsync(() async {
        result = await runAction<int>(context, () async => 42);
      });
      await tester.pump();
      expect(result, 42);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('OpenStateException : son message s\'affiche tel quel, renvoie null',
        (tester) async {
      await pumpHost(tester);
      int? result = 0;
      await tester.runAsync(() async {
        result = await runAction<int>(
            context, () async => throw const OpenStateException('Open déjà démarré.'));
      });
      await tester.pump();
      expect(result, isNull);
      expect(find.text('Open déjà démarré.'), findsOneWidget);
    });

    testWidgets('autre erreur : message générique, renvoie null', (tester) async {
      await pumpHost(tester);
      int? result = 0;
      await tester.runAsync(() async {
        result = await runAction<int>(context, () async => throw StateError('boom'));
      });
      await tester.pump();
      expect(result, isNull);
      expect(find.text('Une erreur est survenue. Réessayez.'), findsOneWidget);
      expect(find.textContaining('boom'), findsNothing); // pas de détail technique
    });

    testWidgets(
        'hypothèse documentée : un null de SUCCÈS est indistinguable d\'un échec '
        '(aucun message)', (tester) async {
      // Voir le commentaire de runAction : aucune action actuelle ne renvoie
      // null ; une future action à retour nullable devra être enveloppée.
      await pumpHost(tester);
      int? result = 1;
      await tester.runAsync(() async {
        result = await runAction<int?>(context, () async => null);
      });
      await tester.pump();
      expect(result, isNull);
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
