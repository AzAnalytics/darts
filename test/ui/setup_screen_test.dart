// Le match libre (SetupScreen) et le formulaire d'open proposent la MÊME liste
// de best-of : l'utilisateur ne doit jamais voir deux listes différentes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:darts/domain/open.dart';
import 'package:darts/main.dart';
import 'package:darts/ui/opens/open_form_screen.dart';

import 'test_harness.dart';

void main() {
  setUpUiTests();

  /// Ouvre le menu déroulant [dropdown] et renvoie les nombres de legs proposés.
  Future<List<int>> proposedLegs(
      WidgetTester tester, UiTestEnv env, Finder dropdown) async {
    await tester.tap(dropdown);
    await env.settle(tester);
    final found = <int>[];
    for (var n = 1; n <= 15; n++) {
      if (find.text('$n legs').evaluate().isNotEmpty) found.add(n);
    }
    return found;
  }

  uiTest('même liste dans le match libre et dans le formulaire d\'open',
      (tester, env) async {
    await env.pumpScreen(tester, SetupScreen(repo: env.repo));
    final inSetup = await proposedLegs(tester, env, find.byType(DropdownButton<int>));

    await tester.pumpWidget(const SizedBox());
    await env.pumpScreen(tester, OpenFormScreen(repo: env.repo));
    final inForm = await proposedLegs(tester, env, find.byKey(const ValueKey('open-bestof')));

    expect(inSetup, bestOfOptions);
    expect(inForm, bestOfOptions);
  });
}
