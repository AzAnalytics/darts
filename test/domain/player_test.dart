import 'package:flutter_test/flutter_test.dart';

import 'package:darts/domain/player.dart';

void main() {
  group('normalizePlayerName', () {
    test('retire les espaces en trop', () {
      expect(normalizePlayerName('  Jean  '), 'Jean');
      expect(normalizePlayerName('Jean   Paul'), 'Jean Paul');
      expect(normalizePlayerName('\tJean\n Paul '), 'Jean Paul');
      expect(normalizePlayerName('   '), '');
    });

    test('ne touche ni à la casse ni aux accents', () {
      expect(normalizePlayerName('Émile'), 'Émile');
      expect(normalizePlayerName('jEaN'), 'jEaN');
    });
  });

  group('isSameName : casse ignorée (Unicode), accents significatifs', () {
    test('casse ASCII', () {
      expect(isSameName('jean', 'Jean'), isTrue);
      expect(isSameName('JEAN', 'jean'), isTrue);
      expect(isSameName('Jean-Paul', 'jean-paul'), isTrue);
    });

    test('majuscules accentuées : ce que NOCASE de SQLite ne sait pas faire', () {
      expect(isSameName('éric', 'Éric'), isTrue);
      expect(isSameName('ÉMILE', 'émile'), isTrue);
      expect(isSameName('émilie', 'Émilie'), isTrue);
    });

    test('espaces normalisés', () {
      expect(isSameName('  jean   paul ', 'Jean Paul'), isTrue);
    });

    test('LIMITE ASSUMÉE : les accents ne sont pas pliés', () {
      expect(isSameName('eric', 'Éric'), isFalse);
      expect(isSameName('emile', 'Émile'), isFalse);
      expect(isSameName('Zoe', 'Zoé'), isFalse);
    });

    test('des noms différents restent différents', () {
      expect(isSameName('Jean', 'Jeanne'), isFalse);
      expect(isSameName('Jean', 'Jean D.'), isFalse);
    });
  });

  group('nameSortKey : tri alphabétique français (accents et casse ignorés)', () {
    test('Émile se range avec les E, pas après Z', () {
      final names = ['zoé', 'Émile', 'Bob', 'éric', 'Alice', 'Eve', 'Zack'];
      names.sort((a, b) => nameSortKey(a).compareTo(nameSortKey(b)));
      expect(names, ['Alice', 'Bob', 'Émile', 'éric', 'Eve', 'Zack', 'zoé']);
    });

    test("n'affecte pas l'identité : accents toujours significatifs", () {
      expect(nameSortKey('Éric'), nameSortKey('eric')); // même rang de tri…
      expect(isSameName('Éric', 'eric'), isFalse); // …mais pas le même joueur
    });
  });

  group('lookupPlayer', () {
    // Joueurs connus ; Marie est déjà inscrite à l'open courant.
    const jean = PlayerSummary(1, 'Jean');
    const jeanne = PlayerSummary(2, 'Jeanne');
    const jeanPierre = PlayerSummary(3, 'Jean-Pierre');
    const emile = PlayerSummary(4, 'Émile');
    const marie = PlayerSummary(5, 'Marie');
    const eric = PlayerSummary(6, 'Éric');
    final known = [jean, jeanne, jeanPierre, emile, marie, eric];
    final registered = {marie.id};

    PlayerLookup look(String q, {Set<int>? reg, List<PlayerSummary>? players}) =>
        lookupPlayer(q, players ?? known, registeredIds: reg ?? registered);

    List<String> names(PlayerLookup l) =>
        l.suggestions.map((s) => s.player.name).toList();

    test('saisie vide : rien à proposer', () {
      for (final q in ['', '   ']) {
        final l = look(q);
        expect(l.query, '');
        expect(l.existing, isNull);
        expect(l.suggestions, isEmpty);
        expect(l.canCreate, isFalse);
        expect(l.primaryAction, PlayerLookupAction.none);
      }
    });

    test('« jea » : les joueurs qui commencent par jea + création proposée', () {
      final l = look('jea');
      expect(l.existing, isNull);
      expect(names(l), ['Jean', 'Jean-Pierre', 'Jeanne']);
      expect(l.suggestions.every((s) => s.kind == SuggestionKind.prefix), isTrue);
      expect(l.canCreate, isTrue);
      // Correspondances partielles seulement : Entrée ne crée rien.
      expect(l.primaryAction, PlayerLookupAction.none);
    });

    test('« jean » (casse différente) : Jean est le joueur existant, pas de création',
        () {
      final l = look('jean');
      expect(l.existing, jean);
      expect(l.existingDiffersFromQuery, isTrue); // « jean » ≠ « Jean » à la lettre
      expect(l.canCreate, isFalse);
      expect(l.existingIsRegistered, isFalse);
      // Les autres Jean restent proposés, sans doublonner l'existant.
      expect(names(l), ['Jean-Pierre', 'Jeanne']);
      expect(l.primaryAction, PlayerLookupAction.addExisting);
    });

    test('« Jean » exact : existant, casse identique', () {
      final l = look('Jean');
      expect(l.existing, jean);
      expect(l.existingDiffersFromQuery, isFalse);
      expect(l.canCreate, isFalse);
    });

    test('« JEAN », « jEaN » et « ␣jean␣ » donnent le même résultat', () {
      for (final q in ['JEAN', 'jEaN', '  jean  ', 'jean ']) {
        final l = look(q);
        expect(l.existing, jean, reason: '"$q"');
        expect(l.canCreate, isFalse, reason: '"$q"');
        expect(l.primaryAction, PlayerLookupAction.addExisting, reason: '"$q"');
      }
    });

    test('la saisie normalisée est celle qui serait créée', () {
      expect(look('  Zoé   Martin ').query, 'Zoé Martin');
    });

    test('« émile » / « ÉMILE » (majuscule accentuée) retrouvent Émile', () {
      for (final q in ['émile', 'ÉMILE', 'Émile']) {
        final l = look(q);
        expect(l.existing, emile, reason: '"$q"');
        expect(l.canCreate, isFalse, reason: '"$q"');
      }
    });

    test('FILET DE SÉCURITÉ : taper avec l\'accent (« ér ») fait remonter « Éric »', () {
      // C'est ce qui rend acceptable la limite « eric » ≠ « Éric » : le président
      // qui tape la première lettre accentuée voit tout de suite « Éric ».
      for (final q in ['ér', 'Ér', 'ÉR', 'é', 'éri']) {
        final l = look(q);
        expect(names(l), contains('Éric'), reason: '"$q" doit proposer Éric');
        expect(l.suggestions.firstWhere((s) => s.player.name == 'Éric').kind,
            SuggestionKind.prefix,
            reason: '"$q"');
      }
      // « ér » ne propose pas Émile (préfixe différent), mais « é » propose les deux.
      expect(names(look('ér')), ['Éric']);
      expect(names(look('é')), ['Émile', 'Éric']);
    });

    test('LIMITE ASSUMÉE : sans accent (« eric »), Éric n\'est pas retrouvé', () {
      final l = look('eric');
      expect(l.existing, isNull);
      expect(names(l), isNot(contains('Éric')));
      expect(l.suggestions, isEmpty);
      // Aucune suggestion : on crée « eric » (limite connue, figée ici).
      expect(l.canCreate, isTrue);
      expect(l.primaryAction, PlayerLookupAction.create);
    });

    test('déjà inscrit à l\'open : jamais suggéré, ni ajouté, ni créé', () {
      final l = look('marie');
      expect(l.existing, marie);
      expect(l.existingIsRegistered, isTrue);
      expect(l.canCreate, isFalse);
      expect(l.primaryAction, PlayerLookupAction.none);
      // Et un joueur inscrit n'apparaît pas dans les suggestions partielles.
      expect(names(look('mar')), isNot(contains('Marie')));
    });

    test('nom inconnu : création seule, action sans ambiguïté', () {
      final l = look('Zoé');
      expect(l.existing, isNull);
      expect(l.suggestions, isEmpty);
      expect(l.canCreate, isTrue);
      expect(l.primaryAction, PlayerLookupAction.create);
    });

    test('correspondance « contient » : après les préfixes', () {
      final l = look('ean');
      expect(names(l), ['Jean', 'Jean-Pierre', 'Jeanne']); // tous contiennent « ean »
      expect(l.suggestions.every((s) => s.kind == SuggestionKind.contains), isTrue);
      final mixed = lookupPlayer('ar', [
        const PlayerSummary(1, 'Marie'), // contient
        const PlayerSummary(2, 'Arnaud'), // préfixe
      ], registeredIds: {});
      expect(mixed.suggestions.map((s) => s.player.name), ['Arnaud', 'Marie']);
      expect(mixed.suggestions.map((s) => s.kind),
          [SuggestionKind.prefix, SuggestionKind.contains]);
    });

    test('limite du nombre de suggestions', () {
      final many = [for (var i = 0; i < 20; i++) PlayerSummary(i, 'Paul $i')];
      expect(lookupPlayer('pau', many, registeredIds: {}).suggestions, hasLength(6));
      expect(lookupPlayer('pau', many, registeredIds: {}, limit: 3).suggestions,
          hasLength(3));
    });

    test('anciens doublons de casse en base : le plus ancien non inscrit est proposé',
        () {
      final dup = [const PlayerSummary(7, 'jean'), const PlayerSummary(2, 'Jean')];
      var l = lookupPlayer('JEAN', dup, registeredIds: {});
      expect(l.existing!.id, 2); // le plus ancien
      // Le plus ancien est déjà inscrit : on propose l'autre.
      l = lookupPlayer('JEAN', dup, registeredIds: {2});
      expect(l.existing!.id, 7);
      expect(l.existingIsRegistered, isFalse);
      // Les deux inscrits : « déjà inscrit ».
      l = lookupPlayer('JEAN', dup, registeredIds: {2, 7});
      expect(l.existingIsRegistered, isTrue);
      expect(l.primaryAction, PlayerLookupAction.none);
    });
  });
}
