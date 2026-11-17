import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/local_repository.dart';
import '../design.dart';
import 'core_screens.dart';

Future<void> dial(BuildContext context, String number) async {
  final digits = number.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega primero un número de teléfono.'))); return; }
  try { if (!await launchUrl(Uri(scheme: 'tel', path: digits))) throw StateError('No disponible'); }
  catch (_) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir el teléfono.'))); }
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key, required this.repository}); final LocalRepository repository;
  @override State<SupportScreen> createState() => _SupportScreenState();
}
class _SupportScreenState extends State<SupportScreen> {
  String hospital = '', agent = '', emergency = '';
  SettingsRepository? get settings => widget.repository is SettingsRepository ? widget.repository as SettingsRepository : null;
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { final r = settings; if (r == null) return; final a = await r.getSetting('hospital_phone') ?? ''; final b = await r.getSetting('agent_phone') ?? ''; final c = await r.getSetting('emergency_phone') ?? ''; if (mounted) setState(() { hospital = a; agent = b; emergency = c; }); }
  Future<void> edit(String key, String title, String old) async { final controller = TextEditingController(text: old); final value = await showDialog<String>(context: context, builder: (context) => AlertDialog(title: Text(title), content: TextField(controller: controller, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Número de teléfono')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Guardar'))])); if (value != null) { await settings?.saveSetting(key, value); await load(); } }
  @override Widget build(BuildContext context) => Scaffold(appBar: const BrandBar(), body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [const SectionTitle('Red de apoyo'), const SizedBox(height: 16),
    contact('88e91','Mi establecimiento de salud',hospital, () => edit('hospital_phone','Teléfono del establecimiento',hospital)),
    contact('b9d93','Mi agente comunitario',agent, () => edit('agent_phone','Teléfono del agente',agent)),
    contact('38e94','Emergencia de mi localidad',emergency, () => edit('emergency_phone','Número de emergencia local',emergency)),
    const SizedBox(height: 8), const Text('Verifica los números con tu establecimiento de salud. Llamar necesita cobertura telefónica.'), const SizedBox(height: 16),
    PrimaryButton('Mi plan de parto →', secondary: true, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BirthPlanScreen(repository: widget.repository)))),
    const SizedBox(height: 8), TextButton(onPressed: () => dial(context, '113'), child: const Text('Llamar a la línea 113 de orientación en salud')),
  ])));
  Widget contact(String icon, String title, String phone, VoidCallback edit) => Padding(padding: const EdgeInsets.only(bottom: 16), child: RoundedCard(child: Column(children: [Row(children: [CircleAvatar(radius: 32, backgroundColor: rose, child: art(icon, size: 34)), const SizedBox(width: 16), Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), IconButton(onPressed: edit, icon: const Icon(Icons.edit_outlined, color: wine), tooltip: 'Editar número')]), const SizedBox(height: 12), Text(phone.isEmpty ? 'Agrega un número de confianza' : phone), const SizedBox(height: 8), PrimaryButton(phone.isEmpty ? 'Agregar número' : 'Llamar', onPressed: phone.isEmpty ? edit : () => dial(context, phone))])));
}

class BirthPlanScreen extends StatefulWidget {
  const BirthPlanScreen({super.key, required this.repository}); final LocalRepository repository;
  @override State<BirthPlanScreen> createState() => _BirthPlanScreenState();
}
class _BirthPlanScreenState extends State<BirthPlanScreen> {
  final place = TextEditingController(), transport = TextEditingController(), companion = TextEditingController(); final checked = <String>{};
  SettingsRepository? get settings => widget.repository is SettingsRepository ? widget.repository as SettingsRepository : null;
  @override void initState() { super.initState(); load(); }
  @override void dispose() { place.dispose(); transport.dispose(); companion.dispose(); super.dispose(); }
  Future<void> load() async { final s = await settings?.getSetting('birth_plan'); if (s == null) return; try { final data = jsonDecode(s) as Map<String,dynamic>; if (!mounted) return; setState(() { place.text = data['place'] as String? ?? ''; transport.text = data['transport'] as String? ?? ''; companion.text = data['companion'] as String? ?? ''; checked.addAll((data['items'] as List<dynamic>? ?? []).cast<String>()); }); } catch (_) {} }
  Future<void> save() async { await settings?.saveSetting('birth_plan', jsonEncode({'place': place.text.trim(), 'transport': transport.text.trim(), 'companion': companion.text.trim(), 'items': checked.toList()})); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan guardado en este dispositivo.'))); }
  @override Widget build(BuildContext context) => Scaffold(appBar: const BrandBar(), body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [const SectionTitle('Plan de parto y emergencia'), const SizedBox(height: 16),
    planField('3f54b','Dónde atenderme',place), planField('0980b','Cómo trasladarme',transport), planField('7221a','Quién me acompaña',companion),
    RoundedCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Qué llevar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), for (final item in ['DNI','Carné prenatal','Ropa del bebé','Ropa para la madre']) CheckboxListTile(contentPadding: EdgeInsets.zero, title: Text(item), value: checked.contains(item), onChanged: (v) => setState(() { if (v == true) { checked.add(item); } else { checked.remove(item); } }))])), const SizedBox(height: 16), PrimaryButton('Guardar mi plan', onPressed: save), const SizedBox(height: 8), PrimaryButton('Red de apoyo', secondary: true, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SupportScreen(repository: widget.repository)))),
  ])));
  Widget planField(String icon, String title, TextEditingController c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: RoundedCard(child: Row(children: [art(icon, size: 32), const SizedBox(width: 12), Expanded(child: TextField(controller: c, maxLength: 120, decoration: InputDecoration(labelText: title, counterText: '', border: InputBorder.none, filled: false)))])));
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.repository, this.embedded = false}); final LocalRepository repository; final bool embedded;
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  double scale = 1;
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { final r = widget.repository; if (r is SettingsRepository) { final v = double.tryParse(await (r as SettingsRepository).getSetting('text_scale') ?? ''); if (v != null && v >= .9 && v <= 1.3 && mounted) setState(() { scale = v; textScale.value = v; }); } }
  @override Widget build(BuildContext context) { final body = ListView(padding: const EdgeInsets.all(16), children: [const SectionTitle('Configuración'), const SizedBox(height: 16), RoundedCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Tamaño de letra', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), Row(children: [const Text('A-'), Expanded(child: Slider(value: scale, min: .9, max: 1.3, divisions: 4, onChanged: (v) => setState(() { scale = v; textScale.value = v; }), onChangeEnd: (v) { final r = widget.repository; if (r is SettingsRepository) (r as SettingsRepository).saveSetting('text_scale', '$v'); })), const Text('A+')])])), const SizedBox(height: 16), const RoundedCard(child: ListTile(contentPadding: EdgeInsets.zero, title: Text('Modo sin conexión'), subtitle: Text('Tus datos se guardan en este dispositivo.'), trailing: Icon(Icons.offline_bolt_outlined, color: wine))), const SizedBox(height: 16), const RoundedCard(child: ListTile(contentPadding: EdgeInsets.zero, title: Text('Idioma'), subtitle: Text('Español. La versión en quechua está pendiente de validación.'))), const SizedBox(height: 16), PrimaryButton('Ayuda', secondary: true, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HelpScreen(repository: widget.repository))))]); return widget.embedded ? body : Scaffold(appBar: const BrandBar(), body: SafeArea(child: body)); }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key, required this.repository}); final LocalRepository repository;
  @override Widget build(BuildContext context) => Scaffold(appBar: const BrandBar(), body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [const SectionTitle('Ayuda'), const SizedBox(height: 16), for (final item in [('1','Cómo usar la app','Registra tus datos, agrega tus controles y configura tu red de apoyo.'),('2','Si tienes alguna duda','Acude a tu establecimiento o llama al 113 para orientación en salud.'),('3','Contactos importantes','Guarda el número de tu establecimiento y de tu agente comunitario.')]) Padding(padding: const EdgeInsets.only(bottom: 16), child: RoundedCard(child: Row(children: [CircleAvatar(backgroundColor: wine, foregroundColor: Colors.white, child: Text(item.$1)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)), Text(item.$3)])), ListenButton('${item.$2}. ${item.$3}')]))), PrimaryButton('Contactos importantes', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SupportScreen(repository: repository))))])));
}
