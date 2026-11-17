import 'package:flutter/material.dart';
import '../data/local_repository.dart';
import '../design.dart';
import 'prenatal_screens.dart';
import 'education_screens.dart';
import 'support_screens.dart';

String dateLabel(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key, required this.repository});
  final LocalRepository repository;
  @override State<StartScreen> createState() => _StartScreenState();
}
class _StartScreenState extends State<StartScreen> {
  late Future<Profile?> _profile;
  @override void initState() { super.initState(); _profile = widget.repository.getProfile(); }
  @override Widget build(BuildContext context) => FutureBuilder<Profile?>(future: _profile, builder: (context, snapshot) {
    if (snapshot.hasError) return const Scaffold(body: Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No se pudo abrir el almacenamiento. Los datos no se han borrado.'))));
    if (snapshot.connectionState != ConnectionState.done) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return snapshot.data == null ? WelcomeScreen(repository: widget.repository) : HomeShell(repository: widget.repository, initial: snapshot.data!);
  });
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.repository});
  final LocalRepository repository;
  @override State<WelcomeScreen> createState() => _WelcomeScreenState();
}
class _WelcomeScreenState extends State<WelcomeScreen> {
  bool quechua = false;
  Future<void> start() async {
    if (quechua) {
      final proceed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Runasimi (quechua)'),
        content: const Text('La traducción y las voces en quechua están en preparación. Puedes continuar en español mientras se validan con hablantes de la comunidad.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Volver')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Continuar en español'))]));
      if (proceed != true || !mounted) return;
    }
    if (!mounted) return;
    final profile = await Navigator.push<Profile>(context, MaterialPageRoute(builder: (_) => ProfileScreen(repository: widget.repository)));
    if (profile != null && mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeShell(repository: widget.repository, initial: profile)));
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: const BrandBar(), body: SafeArea(child: LayoutBuilder(builder: (context, bounds) => SingleChildScrollView(
    padding: const EdgeInsets.all(16), child: ConstrainedBox(constraints: BoxConstraints(minHeight: bounds.maxHeight - 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 24), Center(child: ClipOval(child: Image.asset('assets/figma/1d910.png', width: 174, height: 180, fit: BoxFit.cover))),
      const SizedBox(height: 8), const Center(child: SectionTitle('Bienvenida')), const SizedBox(height: 16),
      const Text('Elige tu idioma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 8),
      PrimaryButton('Runasimi (quechua)', secondary: !quechua, onPressed: () => setState(() => quechua = true), icon: art(quechua ? 'fc97b' : 'df5ef', size: 26)),
      const SizedBox(height: 8), PrimaryButton('Español', secondary: quechua, onPressed: () => setState(() => quechua = false), icon: art(quechua ? 'df5ef' : 'fc97b', size: 26)),
      const SizedBox(height: 16), const Text('Guía rápida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 8),
      Row(children: [for (final item in [('023fd','1\nRegístrate'), ('d4cce','2\nTus controles'), ('dad00','3\nPide ayuda')]) Expanded(child: Padding(padding: const EdgeInsets.only(right: 6), child: RoundedCard(child: SizedBox(height: 120, child: Column(children: [CircleAvatar(radius: 32, backgroundColor: cream, child: art(item.$1, size: 36)), const SizedBox(height: 8), Text(item.$2, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800))]))))) ]),
      const SizedBox(height: 16), PrimaryButton('Empezar →', onPressed: start),
    ]))))));
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.repository, this.initial});
  final LocalRepository repository; final Profile? initial;
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  final form = GlobalKey<FormState>(); late final TextEditingController name, community, age; late String registrant; DateTime? period; bool saving = false;
  @override void initState() { super.initState(); name = TextEditingController(text: widget.initial?.name); community = TextEditingController(text: widget.initial?.community); age = TextEditingController(text: widget.initial?.age?.toString()); registrant = widget.initial?.registrant ?? 'Yo'; period = widget.initial?.lastPeriod; }
  @override void dispose() { name.dispose(); community.dispose(); age.dispose(); super.dispose(); }
  Future<void> save() async {
    if (!form.currentState!.validate() || saving) return;
    setState(() => saving = true);
    final p = Profile(name: name.text.trim(), community: community.text.trim(), registrant: registrant, age: int.tryParse(age.text), lastPeriod: period);
    try { await widget.repository.saveProfile(p); if (mounted) Navigator.pop(context, p); }
    catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudieron guardar los datos.'))); }
    finally { if (mounted) setState(() => saving = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: const BrandBar(), body: SafeArea(child: Form(key: form, child: ListView(padding: const EdgeInsets.all(16), children: [
    const SectionTitle('Mis datos'), const SizedBox(height: 18), const Text('¿Quién hace el registro?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 8),
    Row(children: [for (final item in [('Yo','2e957'),('Un familiar','933fa'),('Agente comunitario','8c2e8')]) Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: InkWell(onTap: () => setState(() => registrant = item.$1), child: Container(height: 96, padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: registrant == item.$1 ? rose : Colors.white, border: Border.all(color: registrant == item.$1 ? wine : const Color(0xffecd2db)), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [art(item.$2), const SizedBox(height: 4), Text(item.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))]))))) ]),
    const SizedBox(height: 16), TextFormField(controller: name, textCapitalization: TextCapitalization.words, maxLength: 100, decoration: const InputDecoration(labelText: 'Nombre', counterText: ''), validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa tu nombre' : null), const SizedBox(height: 8),
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 105, child: TextFormField(controller: age, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Edad'), validator: (v) { final n = int.tryParse(v ?? ''); return n == null || n < 1 || n > 120 ? 'Revisa la edad' : null; })), const SizedBox(width: 8), Expanded(child: TextFormField(controller: community, decoration: const InputDecoration(labelText: 'Comunidad'), validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa tu comunidad' : null))]),
    const SizedBox(height: 8), RoundedCard(onTap: () async { final now = DateTime.now(); final d = await showDatePicker(context: context, initialDate: period ?? now, firstDate: DateTime(now.year - 2), lastDate: now); if (d != null) setState(() => period = d); }, child: Row(children: [Expanded(child: Text(period == null ? 'Fecha de la última regla (opcional)' : 'Última regla: ${dateLabel(period!)}')), const Icon(Icons.calendar_month, color: wine)])),
    const SizedBox(height: 12), if (period != null) RoundedCard(color: rose, child: Text('Esta fecha es orientativa. Confirma las semanas y la fecha probable de parto con tu profesional de salud.', style: TextStyle(color: ink))),
    const SizedBox(height: 24), PrimaryButton('Guardar', onPressed: saving ? null : save),
  ]))));
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.repository, required this.initial});
  final LocalRepository repository; final Profile initial;
  @override State<HomeShell> createState() => _HomeShellState();
}
class _HomeShellState extends State<HomeShell> {
  late Profile profile; int tab = 0; int? mood;
  @override void initState() { super.initState(); profile = widget.initial; }
  void push(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  @override Widget build(BuildContext context) {
    final screens = [home(), ControlsScreen(repository: widget.repository, embedded: true), AlertScreen(repository: widget.repository, embedded: true), SettingsScreen(repository: widget.repository, embedded: true)];
    return Scaffold(appBar: const BrandBar(), body: SafeArea(child: screens[tab]), bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), indicatorColor: rose,
      destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'), NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Controles'), NavigationDestination(icon: Icon(Icons.warning_amber_outlined), label: 'Alertas'), NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Ajustes')]));
  }
  Widget home() {
    final p = profile.lastPeriod; final days = p == null ? null : DateTime.now().difference(p).inDays; final valid = days != null && days >= 0 && days <= 294;
    return ListView(padding: const EdgeInsets.all(16), children: [
      SectionTitle('Hola, ${profile.name.split(' ').first}'), const SizedBox(height: 16),
      RoundedCard(color: rose, child: Row(children: [art('922fa', size: 72), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(valid ? 'Estás en la semana ${days ~/ 7}' : 'Tu embarazo', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, height: 1.1)), const SizedBox(height: 6), Text(valid ? 'Parto probable ${dateLabel(p!.add(const Duration(days: 280)))}' : 'Completa o confirma tus fechas con tu obstetra.')]))])),
      const SizedBox(height: 16), RoundedCard(onTap: () => setState(() => tab = 1), child: const Row(children: [Icon(Icons.calendar_month, color: wine, size: 32), SizedBox(width: 14), Expanded(child: Text('Mis controles prenatales\nVer mis registros y citas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))])),
      const SizedBox(height: 16), const Text('¿Cómo estás hoy?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 8),
      Row(children: [for (final item in [(0,'19f94','Bien'),(1,'2a703','Regular'),(2,'b5e8c','Mal')]) Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: RoundedCard(color: mood == item.$1 ? rose : Colors.white, onTap: () { setState(() => mood = item.$1); if (item.$1 == 2) push(AlertScreen(repository: widget.repository)); }, child: Column(children: [art(item.$2, size: 36), Text(item.$3, style: const TextStyle(fontWeight: FontWeight.w700))]))))]),
      const SizedBox(height: 16), Row(children: [Expanded(child: homeTile('1f426','Mis controles', () => setState(() => tab = 1))), const SizedBox(width: 8), Expanded(child: homeTile('8c906','Educación', () => push(EducationScreen(repository: widget.repository))))]),
      const SizedBox(height: 8), Row(children: [Expanded(child: homeTile('a2b80','Señales de alerta', () => setState(() => tab = 2))), const SizedBox(width: 8), Expanded(child: homeTile('6d486','Pedir ayuda', () => push(SupportScreen(repository: widget.repository))))]),
      const SizedBox(height: 12), TextButton(onPressed: () async { final p = await Navigator.push<Profile>(context, MaterialPageRoute(builder: (_) => ProfileScreen(repository: widget.repository, initial: profile))); if (p != null) setState(() => profile = p); }, child: const Text('Editar mis datos')),
    ]);
  }
  Widget homeTile(String id, String title, VoidCallback onTap) => RoundedCard(color: rose, onTap: onTap, child: SizedBox(height: 68, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [art(id, size: 30), const SizedBox(height: 4), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))])));
}
