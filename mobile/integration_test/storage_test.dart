import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:control_gestantes/data/local_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('guarda y recupera datos de prueba en una base cifrada', (tester) async {
    final repository = EncryptedLocalRepository(databaseName: 'gestantes_integration_test.db', keyName: 'integration_test_key');
    await repository.saveProfile(const Profile(name: 'Persona de prueba', community: 'Abancay', registrant: 'Yo'));
    await repository.addControl(PrenatalControl(date: DateTime(2026, 1, 1), weight: 60, systolic: 110, diastolic: 70, hemoglobin: 12));
    final reopened = EncryptedLocalRepository(databaseName: 'gestantes_integration_test.db', keyName: 'integration_test_key');
    expect((await reopened.getProfile())?.name, 'Persona de prueba');
    expect((await reopened.getControls()).last.systolic, 110);
    final file = File(path.join(await getDatabasesPath(), 'gestantes_integration_test.db'));
    final header = await file.openRead(0, 16).expand((chunk) => chunk).toList();
    expect(String.fromCharCodes(header), isNot(startsWith('SQLite format 3')));
    await expectLater(() async {
      final bad = await openDatabase(file.path, password: 'clave-incorrecta', singleInstance: false);
      try { await bad.rawQuery('SELECT * FROM profile'); } finally { await bad.close(); }
    }, throwsA(isA<Exception>()));
  });
}
