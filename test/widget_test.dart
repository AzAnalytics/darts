// Test de fumée : l'app démarre sur l'accueil, sans base de données réelle.

import 'package:flutter_test/flutter_test.dart';

import 'package:darts/data/database.dart';
import 'package:darts/data/repository.dart';
import 'package:darts/main.dart';

/// Repository factice : aucune persistance, listes vides. Étend Fake : toute
/// méthode non surchargée ici lève une erreur si un écran l'appelle.
class _FakeRepository extends Fake implements DartsRepository {
  @override
  Future<int> getOrCreatePlayer(String name) async => 1;

  @override
  Future<int> saveFinishedMatch(FinishedMatchData data) async => 1;

  @override
  Stream<List<MatchSummary>> watchHistory() => Stream.value(const []);

  @override
  Stream<List<Standing>> watch180() => Stream.value(const []);

  @override
  Stream<List<Standing>> watchAverages() => Stream.value(const []);

  @override
  Stream<List<Standing>> watchCheckouts() => Stream.value(const []);
}

void main() {
  testWidgets("L'accueil affiche les deux entrées principales",
      (tester) async {
    await tester.pumpWidget(DartsApp(repo: _FakeRepository()));

    expect(find.text('Nouveau match'), findsOneWidget);
    expect(find.text('Historique & classements'), findsOneWidget);
  });
}
