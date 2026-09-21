import 'package:flutter_test/flutter_test.dart';

import 'package:darts/domain/open.dart';
import 'package:darts/domain/open_rules.dart';

OpenSummary _open({String status = OpenStatus.setup, String format = OpenFormat.doubleElim}) =>
    OpenSummary(
      id: 1,
      name: 'Open',
      location: null,
      date: null,
      format: format,
      bestOf: 5,
      grandFinalReset: false,
      status: status,
      entryCount: 0,
    );

/// Inscrits J1..Jn avec les têtes de série données (null = pas de tête de série).
List<OpenEntry> _entries(List<int?> seeds) => [
      for (var i = 0; i < seeds.length; i++)
        OpenEntry(
            playerId: i + 1,
            playerName: 'J${i + 1}',
            seed: seeds[i],
            finalPlacement: null),
    ];

void main() {
  group('seedingStatusOf', () {
    test('aucun inscrit ou personne classé : none', () {
      expect(seedingStatusOf([]), SeedingStatus.none);
      expect(seedingStatusOf([null, null, null]), SeedingStatus.none);
    });

    test('1..N sans trou, dans n\'importe quel ordre : complete', () {
      expect(seedingStatusOf([1]), SeedingStatus.complete);
      expect(seedingStatusOf([1, 2, 3]), SeedingStatus.complete);
      expect(seedingStatusOf([3, 1, 2]), SeedingStatus.complete);
    });

    test('un joueur sans tête de série : partial', () {
      expect(seedingStatusOf([1, 2, null]), SeedingStatus.partial);
      expect(seedingStatusOf([null, 1, null]), SeedingStatus.partial);
    });

    test('valeurs incohérentes (trou, doublon, hors bornes) : partial', () {
      expect(seedingStatusOf([1, 3]), SeedingStatus.partial); // trou
      expect(seedingStatusOf([1, 1, 2]), SeedingStatus.partial); // doublon
      expect(seedingStatusOf([2, 3, 4]), SeedingStatus.partial); // ne commence pas à 1
      expect(seedingStatusOf([0, 1, 2]), SeedingStatus.partial); // 0 invalide
    });
  });

  group('generationBlocker : un seul motif, dans l\'ordre format > joueurs > têtes de série',
      () {
    test('open déjà généré ou terminé : message dédié', () {
      for (final status in [OpenStatus.running, OpenStatus.finished]) {
        expect(generationBlocker(_open(status: status), _entries([1, 2, 3])),
            'Le tableau est déjà généré.');
      }
    });

    test('format pas encore disponible (open hérité de la v1)', () {
      final msg = generationBlocker(
          _open(format: OpenFormat.singleElim), _entries([1, 2, 3]));
      expect(msg,
          'Le format « Élimination simple » n\'est pas encore disponible : modifiez le format de l\'open (menu ⋮ › Modifier).');
      expect(
          generationBlocker(_open(format: OpenFormat.groupsKnockout), _entries([1, 2, 3])),
          contains('« Poules + phase finale »'));
    });

    test('le format passe avant le nombre de joueurs', () {
      final msg = generationBlocker(_open(format: OpenFormat.singleElim), _entries([]));
      expect(msg, contains('pas encore disponible'));
    });

    test('moins de 3 joueurs', () {
      expect(generationBlocker(_open(), _entries([])),
          'Il faut au moins 3 joueurs : 0 inscrit pour l\'instant.');
      expect(generationBlocker(_open(), _entries([1])),
          'Il faut au moins 3 joueurs : 1 inscrit pour l\'instant.');
      expect(generationBlocker(_open(), _entries([1, 2])),
          'Il faut au moins 3 joueurs : 2 inscrits pour l\'instant.');
    });

    test('le nombre de joueurs passe avant les têtes de série', () {
      expect(generationBlocker(_open(), _entries([null, null])),
          contains('Il faut au moins 3 joueurs'));
    });

    test('3 joueurs ou plus, aucune tête de série', () {
      expect(generationBlocker(_open(), _entries([null, null, null])),
          'Définissez les têtes de série : glissez les joueurs pour les classer, ou faites le tirage au sort.');
    });

    test('têtes de série partielles : singulier et pluriel', () {
      expect(generationBlocker(_open(), _entries([1, 2, null])),
          '1 joueur n\'a pas de tête de série : classez-le ou refaites le tirage.');
      expect(generationBlocker(_open(), _entries([1, null, null, null])),
          '3 joueurs n\'ont pas de tête de série : classez-les ou refaites le tirage.');
    });

    test('têtes de série toutes présentes mais incohérentes', () {
      expect(generationBlocker(_open(), _entries([1, 2, 4])),
          contains('incohérentes'));
    });

    test('tout est prêt : aucun motif', () {
      expect(generationBlocker(_open(), _entries([1, 2, 3])), isNull);
      expect(generationBlocker(_open(), _entries([3, 1, 2, 4])), isNull);
    });
  });
}
