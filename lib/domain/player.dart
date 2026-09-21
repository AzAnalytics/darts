// lib/domain/player.dart
// Noms de joueurs et autocomplétion : logique PURE (aucune base, aucun widget).
//
// Deux noms désignent le même joueur s'ils sont égaux une fois normalisés (espaces
// superflus retirés) et passés en minuscules UNICODE : « éric », « ÉRIC » et
// « Éric » sont le même joueur. Les accents, eux, ne sont PAS pliés : « eric »
// n'est pas « Éric » (limite assumée). Le filet de sécurité est l'autocomplétion,
// qui fait remonter « Éric » dès la saisie de « ér ».
//
// (SQLite ne convient pas ici : NOCASE et lower() ne plient que l'ASCII, donc
// « émile » ≠ « Émile » côté SQL. La comparaison se fait donc en Dart.)

class PlayerSummary {
  final int id;
  final String name;
  const PlayerSummary(this.id, this.name);

  @override
  String toString() => 'PlayerSummary($id, $name)';
}

/// Longueur maximale d'un nom (limite de la base).
const maxPlayerNameLength = 60;

/// Retire les espaces en début/fin et ramène les espaces multiples à un seul.
String normalizePlayerName(String raw) =>
    raw.trim().replaceAll(RegExp(r'\s+'), ' ');

/// Clé de comparaison : nom normalisé, en minuscules Unicode, accents conservés.
String nameKey(String name) => normalizePlayerName(name).toLowerCase();

bool isSameName(String a, String b) => nameKey(a) == nameKey(b);

/// Clé de TRI alphabétique français : casse et accents ignorés (« Émile » se
/// range avec les E). Uniquement pour l'ordre d'affichage : l'identité d'un
/// joueur, elle, garde les accents significatifs (voir [nameKey]).
String nameSortKey(String name) {
  const folds = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'å': 'a', 'æ': 'ae',
    'ç': 'c', 'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ì': 'i', 'í': 'i',
    'î': 'i', 'ï': 'i', 'ñ': 'n', 'ò': 'o', 'ó': 'o', 'ô': 'o', 'ö': 'o',
    'õ': 'o', 'œ': 'oe', 'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ý': 'y',
    'ÿ': 'y',
  };
  final key = nameKey(name);
  final out = StringBuffer();
  for (final rune in key.runes) {
    final ch = String.fromCharCode(rune);
    out.write(folds[ch] ?? ch);
  }
  return out.toString();
}

enum SuggestionKind {
  /// Le nom commence par la saisie (« jea » -> « Jeanne »).
  prefix,

  /// Le nom contient la saisie sans commencer par elle (« ean » -> « Jean »).
  contains,
}

class PlayerSuggestion {
  final PlayerSummary player;
  final SuggestionKind kind;
  const PlayerSuggestion(this.player, this.kind);
}

/// Ce que l'écran doit proposer pour une saisie donnée.
class PlayerLookup {
  /// Saisie normalisée (celle qui serait créée).
  final String query;

  /// Joueur portant déjà ce nom (casse ignorée), s'il y en a un.
  final PlayerSummary? existing;

  /// Vrai si TOUS les joueurs portant ce nom sont déjà inscrits à l'open.
  final bool existingIsRegistered;

  /// Autres joueurs proches (débutent par / contiennent la saisie), hors joueurs
  /// déjà inscrits, préfixes d'abord, au plus `limit`.
  final List<PlayerSuggestion> suggestions;

  const PlayerLookup({
    required this.query,
    required this.existing,
    required this.existingIsRegistered,
    required this.suggestions,
  });

  /// Le nom du joueur existant diffère de la saisie (casse) : « jean » / « Jean ».
  bool get existingDiffersFromQuery =>
      existing != null && existing!.name != query;

  /// Création proposée : jamais si le nom existe déjà (ce serait un doublon).
  bool get canCreate => query.isNotEmpty && existing == null;

  /// Action de la touche Entrée / du bouton « Ajouter » : sans ambiguïté
  /// seulement. Un joueur du même nom -> on l'ajoute ; aucune suggestion -> on
  /// crée ; des suggestions partielles seulement -> rien (choix explicite requis,
  /// pour qu'une faute de frappe ne crée pas un joueur).
  PlayerLookupAction get primaryAction {
    if (query.isEmpty || existingIsRegistered) return PlayerLookupAction.none;
    if (existing != null) return PlayerLookupAction.addExisting;
    if (suggestions.isEmpty) return PlayerLookupAction.create;
    return PlayerLookupAction.none;
  }
}

enum PlayerLookupAction { none, addExisting, create }

/// Analyse la saisie [query] parmi les joueurs [known]. [registeredIds] : joueurs
/// déjà inscrits à l'open courant (jamais suggérés une seconde fois).
PlayerLookup lookupPlayer(
  String query,
  List<PlayerSummary> known, {
  required Set<int> registeredIds,
  int limit = 6,
}) {
  final q = normalizePlayerName(query);
  if (q.isEmpty) {
    return const PlayerLookup(
      query: '',
      existing: null,
      existingIsRegistered: false,
      suggestions: [],
    );
  }
  final key = q.toLowerCase();

  // Même nom (casse ignorée). Plusieurs lignes possibles si la base contient
  // d'anciens doublons : on prend le plus ancien non inscrit.
  final sameName = [for (final p in known) if (nameKey(p.name) == key) p]
    ..sort((a, b) => a.id.compareTo(b.id));
  final free = sameName.where((p) => !registeredIds.contains(p.id)).toList();
  final existing = free.isNotEmpty
      ? free.first
      : (sameName.isNotEmpty ? sameName.first : null);
  final allRegistered = sameName.isNotEmpty && free.isEmpty;

  final prefixes = <PlayerSuggestion>[];
  final containing = <PlayerSuggestion>[];
  for (final p in known) {
    if (registeredIds.contains(p.id)) continue;
    final k = nameKey(p.name);
    if (k == key) continue; // c'est « existing », pas une suggestion
    if (k.startsWith(key)) {
      prefixes.add(PlayerSuggestion(p, SuggestionKind.prefix));
    } else if (k.contains(key)) {
      containing.add(PlayerSuggestion(p, SuggestionKind.contains));
    }
  }
  int byName(PlayerSuggestion a, PlayerSuggestion b) {
    final c = nameSortKey(a.player.name).compareTo(nameSortKey(b.player.name));
    return c != 0 ? c : a.player.id.compareTo(b.player.id);
  }

  prefixes.sort(byName);
  containing.sort(byName);
  return PlayerLookup(
    query: q,
    existing: existing,
    existingIsRegistered: allRegistered,
    suggestions: [...prefixes, ...containing].take(limit).toList(),
  );
}
