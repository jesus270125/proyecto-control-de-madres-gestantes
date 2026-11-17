import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/local_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GestantesApp(repository: EncryptedLocalRepository()));
}

const wine = Color(0xFF791B38);
const rose = Color(0xFFF5E6EB);

class GestantesApp extends StatelessWidget {
  const GestantesApp({super.key, required this.repository});
  final LocalRepository repository;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Control de madres gestantes',
    locale: const Locale('es'),
    supportedLocales: const [Locale('es')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: wine,
        surface: const Color(0xFFFFF9F7),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFF9F7),
    ),
    home: HomePage(repository: repository),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.repository});
  final LocalRepository repository;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Profile?> profile;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    profile = widget.repository.getProfile();
  }

  Future<void> _openProfile(Profile? current) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProfilePage(repository: widget.repository, initial: current),
      ),
    );
    if (changed == true && mounted) setState(_refresh);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: wine,
      foregroundColor: Colors.white,
      title: const Text(
        'RIMAYKULLAYKI',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    body: SafeArea(
      child: FutureBuilder<Profile?>(
        future: profile,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No se pudo abrir el almacenamiento local. No se han borrado los datos.',
                ),
              ),
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final person = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                person == null ? 'Bienvenida' : 'Hola, ${person.name}',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(color: wine, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Card(
                color: rose,
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'Versión de prueba: usa solo datos ficticios. La información se guarda únicamente en este dispositivo.',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _openProfile(person),
                icon: const Icon(Icons.person_outline),
                label: Text(
                  person == null ? 'Registrar mis datos' : 'Editar mis datos',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: person == null
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ControlsPage(repository: widget.repository),
                        ),
                      ),
                icon: const Icon(Icons.calendar_month),
                label: const Text('Mis controles'),
              ),
              if (person == null)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Primero registra tus datos para acceder a los controles.',
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                'Educación, red de apoyo y alertas estarán disponibles en una próxima etapa.',
              ),
            ],
          );
        },
      ),
    ),
  );
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.repository, this.initial});
  final LocalRepository repository;
  final Profile? initial;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController community;
  late String registrant;
  bool saving = false;
  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.initial?.name);
    community = TextEditingController(text: widget.initial?.community);
    registrant = widget.initial?.registrant ?? 'Yo';
  }

  @override
  void dispose() {
    name.dispose();
    community.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate() || saving) return;
    setState(() => saving = true);
    try {
      await widget.repository.saveProfile(
        Profile(
          name: name.text.trim(),
          community: community.text.trim(),
          registrant: registrant,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo guardar. Inténtalo de nuevo.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mis datos')),
    body: SafeArea(
      child: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('¿Quién hace el registro?'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: registrant,
              decoration: const InputDecoration(
                labelText: 'Persona que registra',
              ),
              items: const [
                'Yo',
                'Un familiar',
                'Agente comunitario',
              ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (value) {
                if (value != null) setState(() => registrant = value);
              },
            ),
            TextFormField(
              controller: name,
              textCapitalization: TextCapitalization.words,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Ingresa un nombre'
                  : null,
            ),
            TextFormField(
              controller: community,
              textCapitalization: TextCapitalization.words,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Comunidad'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Ingresa una comunidad'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: saving ? null : save,
              child: Text(saving ? 'Guardando…' : 'Guardar'),
            ),
          ],
        ),
      ),
    ),
  );
}

class ControlsPage extends StatefulWidget {
  const ControlsPage({super.key, required this.repository});
  final LocalRepository repository;
  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  late Future<List<PrenatalControl>> controls;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    controls = widget.repository.getControls();
  }

  Future<void> _add() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ControlForm(repository: widget.repository),
      ),
    );
    if (saved == true && mounted) setState(_refresh);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mis controles')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _add,
      icon: const Icon(Icons.add),
      label: const Text('Registrar control'),
    ),
    body: FutureBuilder<List<PrenatalControl>>(
      future: controls,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('No se pudieron cargar los controles.'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('Aún no hay controles registrados.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final c = snapshot.data![index];
            return Card(
              child: ListTile(
                title: Text('${c.date.day}/${c.date.month}/${c.date.year}'),
                subtitle: Text(
                  'Peso: ${c.weight} kg · Presión: ${c.systolic}/${c.diastolic} mmHg\nHemoglobina: ${c.hemoglobin} g/dL',
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

class ControlForm extends StatefulWidget {
  const ControlForm({super.key, required this.repository});
  final LocalRepository repository;
  @override
  State<ControlForm> createState() => _ControlFormState();
}

class _ControlFormState extends State<ControlForm> {
  final form = GlobalKey<FormState>();
  final weight = TextEditingController(),
      systolic = TextEditingController(),
      diastolic = TextEditingController(),
      hemoglobin = TextEditingController();
  DateTime date = DateTime.now();
  bool saving = false;
  @override
  void dispose() {
    weight.dispose();
    systolic.dispose();
    diastolic.dispose();
    hemoglobin.dispose();
    super.dispose();
  }

  double? number(String? s) =>
      double.tryParse((s ?? '').trim().replaceAll(',', '.'));
  String? positive(String? value) {
    final n = number(value);
    return n == null || !n.isFinite || n <= 0
        ? 'Ingresa un número mayor que cero'
        : null;
  }

  String? integer(String? value) {
    final n = int.tryParse((value ?? '').trim());
    return n == null || n <= 0
        ? 'Ingresa un número entero mayor que cero'
        : null;
  }

  Future<void> save() async {
    if (!form.currentState!.validate() || saving) return;
    setState(() => saving = true);
    try {
      await widget.repository.addControl(
        PrenatalControl(
          date: DateTime(date.year, date.month, date.day),
          weight: number(weight.text)!,
          systolic: int.parse(systolic.text.trim()),
          diastolic: int.parse(diastolic.text.trim()),
          hemoglobin: number(hemoglobin.text)!,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar el control.')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Registrar control')),
    body: SafeArea(
      child: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Copia los valores de tu control. La aplicación no interpreta los resultados.',
            ),
            TextButton.icon(
              onPressed: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (selected != null) setState(() => date = selected);
              },
              icon: const Icon(Icons.calendar_today),
              label: Text('Fecha: ${date.day}/${date.month}/${date.year}'),
            ),
            TextFormField(
              controller: weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
              validator: positive,
            ),
            TextFormField(
              controller: systolic,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Presión sistólica (mmHg)',
              ),
              validator: integer,
            ),
            TextFormField(
              controller: diastolic,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Presión diastólica (mmHg)',
              ),
              validator: integer,
            ),
            TextFormField(
              controller: hemoglobin,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Hemoglobina (g/dL)',
              ),
              validator: positive,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: saving ? null : save,
              child: Text(saving ? 'Guardando…' : 'Guardar control'),
            ),
          ],
        ),
      ),
    ),
  );
}
