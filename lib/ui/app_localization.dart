// lib/ui/app_localization.dart
// Localisation française de l'app (sélecteur de date, boutons système, formats).
// Partagé par DartsApp et par le harnais de test des écrans.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

const appLocale = Locale('fr');

const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const appSupportedLocales = [appLocale];
