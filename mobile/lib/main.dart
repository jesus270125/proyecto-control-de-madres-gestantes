import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/local_repository.dart';
import 'design.dart';
import 'screens/core_screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GestantesApp(repository: EncryptedLocalRepository()));
}

class GestantesApp extends StatelessWidget {
  const GestantesApp({super.key, required this.repository});
  final LocalRepository repository;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'Rimaykullayki',
    locale: const Locale('es'), supportedLocales: const [Locale('es')],
    localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    theme: ThemeData(useMaterial3: true, fontFamily: 'Nunito', scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(seedColor: wine, surface: background),
      textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Nunito', bodyColor: ink, displayColor: ink),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: rose)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: rose)))),
    builder: (context, child) => ValueListenableBuilder<double>(valueListenable: textScale, builder: (context, scale, _) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: child!)),
    home: StartScreen(repository: repository));
}
