import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:control_gestantes/data/local_repository.dart';
import 'package:control_gestantes/main.dart';
import 'package:control_gestantes/screens/prenatal_screens.dart';

class FakeRepository implements LocalRepository {
  Profile? profile;
  final controls = <PrenatalControl>[];
  @override
  Future<Profile?> getProfile() async => profile;
  @override
  Future<void> saveProfile(Profile value) async {
    profile = value;
  }

  @override
  Future<List<PrenatalControl>> getControls() async => List.of(controls);
  @override
  Future<void> addControl(PrenatalControl control) async {
    controls.add(control);
  }
}

void main() {
  testWidgets('una señal comunicada lleva a una recomendación de atención', (tester) async {
    final repo = FakeRepository();
    await tester.pumpWidget(MaterialApp(home: AlertScreen(repository: repo)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sí'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
    }
    await tester.scrollUntilVisible(find.textContaining('Acude ahora'), 200);
    expect(find.textContaining('Acude ahora'), findsOneWidget);
  });
  testWidgets(
    'perfil y control se guardan y muestran mediante el repositorio',
    (tester) async {
      final repo = FakeRepository();
      await tester.pumpWidget(GestantesApp(repository: repo));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Empezar →'));
      await tester.tap(find.text('Empezar →'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Persona de prueba',
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Edad'), '24');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Comunidad'),
        'Abancay',
      );
      await tester.ensureVisible(find.text('Guardar'));
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Hola, Persona'), findsOneWidget);
      await tester.ensureVisible(find.text('Mis controles'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mis controles')); 
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Registrar control'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Registrar control'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Peso (kg)'),
        '60,5',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Sistólica'),
        '110',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Diastólica'),
        '70',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Hemoglobina (g/dL)'),
        '12,5',
      );
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Guardar'),
        200,
        scrollable: find.descendant(of: find.byType(ControlFormScreen), matching: find.byType(Scrollable)).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(repo.controls.single.weight, 60.5);
      expect(find.textContaining('110/70'), findsOneWidget);
    },
  );
}
