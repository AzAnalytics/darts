// lib/ui/ui_helpers.dart
// Petits utilitaires d'affichage partagés par les écrans.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/open.dart';
import '../domain/open_state_exception.dart';

// Ces libellés vivent dans le domaine (les règles d'un open en ont besoin) ;
// réexportés ici pour que les écrans n'aient qu'un import.
export '../domain/open.dart' show entryCountLabel, formatLabel, isFormatAvailable;

/// Libellé français du statut d'un open (voir OpenStatus).
String statusLabel(String status) {
  switch (status) {
    case OpenStatus.setup:
      return 'Inscriptions';
    case OpenStatus.running:
      return 'En cours';
    case OpenStatus.finished:
      return 'Terminé';
    default:
      return status;
  }
}

/// Date courte en français : « sam. 3 oct. 2026 ».
/// Nécessite les données de date françaises (initializeDateFormatting('fr'),
/// fait dans main() ; les délégués de localisation le font aussi dans l'app).
String formatDate(DateTime date) => DateFormat('EEE d MMM y', 'fr').format(date);

/// Exécute une action du repository et affiche l'erreur éventuelle.
///
///  - succès : renvoie le résultat de l'action ;
///  - OpenStateException : son message (déjà en français) s'affiche tel quel
///    dans un SnackBar, et la fonction renvoie null ;
///  - autre erreur : message générique, détail dans la console, renvoie null.
///
/// ATTENTION — hypothèse : `null` signifie « échec ». C'est correct tant
/// qu'aucune action ne renvoie légitimement null : aujourd'hui elles renvoient
/// un id (createOpen) ou `void`, que l'on enveloppe pour obtenir un non-null
/// (voir OpenFormScreen). Une future action à retour NULLABLE ne doit pas être
/// passée telle quelle ici : un null de succès serait lu comme un échec
/// silencieux. L'envelopper (ex. `() async => (await action(),)`) ou ajouter
/// une variante qui distingue succès et échec.
Future<T?> runAction<T>(BuildContext context, Future<T> Function() action) async {
  // Capturé avant l'await : reste utilisable même si l'écran a été fermé.
  final messenger = ScaffoldMessenger.of(context);
  try {
    return await action();
  } on OpenStateException catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(e.message)));
    return null;
  } catch (e, stack) {
    debugPrint('Erreur inattendue : $e\n$stack');
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
          const SnackBar(content: Text('Une erreur est survenue. Réessayez.')));
    return null;
  }
}
