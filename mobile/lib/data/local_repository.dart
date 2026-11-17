import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_sqlcipher/sqflite.dart';

class Profile {
  const Profile({
    required this.name,
    required this.community,
    required this.registrant,
  });
  final String name;
  final String community;
  final String registrant;
}

class PrenatalControl {
  const PrenatalControl({
    required this.date,
    required this.weight,
    required this.systolic,
    required this.diastolic,
    required this.hemoglobin,
  });
  final DateTime date;
  final double weight;
  final int systolic;
  final int diastolic;
  final double hemoglobin;
}

abstract interface class LocalRepository {
  Future<Profile?> getProfile();
  Future<void> saveProfile(Profile profile);
  Future<List<PrenatalControl>> getControls();
  Future<void> addControl(PrenatalControl control);
}

class EncryptedLocalRepository implements LocalRepository {
  final _secureStorage = const FlutterSecureStorage();
  Future<Database>? _database;
  Future<Database> get database => _database ??= _open();

  Future<Database> _open() async {
    final filePath = path.join(await getDatabasesPath(), 'gestantes.db');
    var key = await _secureStorage.read(key: 'database_key');
    if (key == null) {
      // Nunca crear una clave nueva sobre una base existente: evitar pérdida silenciosa.
      if (await File(filePath).exists()) {
        throw StateError('La clave de la base de datos no está disponible.');
      }
      final random = Random.secure();
      key = base64UrlEncode(List.generate(32, (_) => random.nextInt(256)));
      await _secureStorage.write(key: 'database_key', value: key);
    }
    return openDatabase(
      filePath,
      password: key,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE profile (id INTEGER PRIMARY KEY, name TEXT NOT NULL, community TEXT NOT NULL, registrant TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE prenatal_control (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL, weight REAL NOT NULL, systolic INTEGER NOT NULL, diastolic INTEGER NOT NULL, hemoglobin REAL NOT NULL)',
        );
      },
    );
  }

  @override
  Future<Profile?> getProfile() async {
    final rows = await (await database).query(
      'profile',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return Profile(
      name: row['name'] as String,
      community: row['community'] as String,
      registrant: row['registrant'] as String,
    );
  }

  @override
  Future<void> saveProfile(Profile profile) async {
    await (await database).insert('profile', {
      'id': 1,
      'name': profile.name,
      'community': profile.community,
      'registrant': profile.registrant,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<PrenatalControl>> getControls() async {
    final rows = await (await database).query(
      'prenatal_control',
      orderBy: 'date DESC, id DESC',
    );
    return rows
        .map(
          (row) => PrenatalControl(
            date: DateTime.parse(row['date'] as String),
            weight: (row['weight'] as num).toDouble(),
            systolic: row['systolic'] as int,
            diastolic: row['diastolic'] as int,
            hemoglobin: (row['hemoglobin'] as num).toDouble(),
          ),
        )
        .toList();
  }

  @override
  Future<void> addControl(PrenatalControl control) async {
    await (await database).insert('prenatal_control', {
      'date': control.date.toIso8601String(),
      'weight': control.weight,
      'systolic': control.systolic,
      'diastolic': control.diastolic,
      'hemoglobin': control.hemoglobin,
    });
  }
}
