import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../data/local_repository.dart';
import '../design.dart';
import 'core_screens.dart';
import 'support_screens.dart';

class ControlsScreen extends StatefulWidget {
  const ControlsScreen({super.key, required this.repository, this.embedded = false});
  final LocalRepository repository; final bool embedded;
  @override State<ControlsScreen> createState() => _ControlsScreenState();
}
class _ControlsScreenState extends State<ControlsScreen> {
  late Future<List<PrenatalControl>> controls;
  DateTime? nextDate;
  @override void initState() { super.initState(); refresh(); loadDate(); }
  void refresh() { controls = widget.repository.getControls(); }
  Future<void> loadDate() async { final r = widget.repository; if (r is SettingsRepository) { final s = await (r as SettingsRepository).getSetting('next_control'); if (mounted && s != null) setState(() => nextDate = DateTime.tryParse(s)); } }
  Future<void> chooseDate() async { final now = DateTime.now(); final d = await showDatePicker(context: context, initialDate: nextDate != null && nextDate!.isAfter(now) ? nextDate! : now, firstDate: DateTime(now.year, now.month, now.day), lastDate: DateTime(now.year + 2)); if (d == null || !mounted) return; final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0)); if (time == null || !mounted) return; final value = DateTime(d.year, d.month, d.day, time.hour, time.minute); final r = widget.repository; if (r is SettingsRepository) await (r as SettingsRepository).saveSetting('next_control', value.toIso8601String()); if (mounted) setState(() => nextDate = value); }
  Future<void> add() async { final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => ControlFormScreen(repository: widget.repository))); if (saved == true && mounted) setState(refresh); }
  @override Widget build(BuildContext context) { final body = FutureBuilder<List<PrenatalControl>>(future: controls, builder: (context, snapshot) {
    if (snapshot.hasError) return const Center(child: Text('No se pudieron cargar los controles.'));
    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final list = snapshot.data!;
    return ListView(padding: const EdgeInsets.all(16), children: [const SectionTitle('Mis controles'), const SizedBox(height: 16),
      RoundedCard(color: rose, onTap: chooseDate, child: Row(children: [art('1f426'), const SizedBox(width: 12), Expanded(child: Text(nextDate == null ? 'Próximo control:\nToca para agregar una fecha' : 'Próximo control:\n${dateLabel(nextDate!)} · ${TimeOfDay.fromDateTime(nextDate!).format(context)}', style: const TextStyle(fontWeight: FontWeight.w800))), const Icon(Icons.edit_outlined, color: wine)])),
      const SizedBox(height: 16), const Text('Historial de controles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 8),
      if (list.isEmpty) const RoundedCard(child: Text('Aún no has registrado controles.')) else ...list.map((c) => Padding(padding: const EdgeInsets.only(bottom: 8), child: RoundedCard(child: Row(children: [art('3154b', size: 24), const SizedBox(width: 12), Expanded(child: Text('${dateLabel(c.date)}\n${c.weight} kg · ${c.systolic}/${c.diastolic} mmHg · ${c.hemoglobin} g/dL'))])))),
      const SizedBox(height: 8), PrimaryButton('Registrar control', onPressed: add, icon: const Icon(Icons.add)), const SizedBox(height: 8),
      PrimaryButton('Carné prenatal digital', secondary: true, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrenatalCardScreen(controls: list)))),
      const SizedBox(height: 8), const Text('La fecha de la cita se guarda en este teléfono. Confírmala con tu establecimiento.', style: TextStyle(fontSize: 13))]); });
    return widget.embedded ? body : Scaffold(appBar: const BrandBar(), body: SafeArea(child: body)); }
}

class ControlFormScreen extends StatefulWidget {
  const ControlFormScreen({super.key, required this.repository}); final LocalRepository repository;
  @override State<ControlFormScreen> createState() => _ControlFormScreenState();
}
class _ControlFormScreenState extends State<ControlFormScreen> {
  final key = GlobalKey<FormState>(); final weight = TextEditingController(), sys = TextEditingController(), dia = TextEditingController(), hb = TextEditingController(), vaccines = TextEditingController(); DateTime date = DateTime.now(); bool saving = false;
  @override void dispose() { weight.dispose(); sys.dispose(); dia.dispose(); hb.dispose(); vaccines.dispose(); super.dispose(); }
  double? number(String? s) => double.tryParse((s ?? '').trim().replaceAll(',', '.'));
  String? validNumber(String? s) { final n = number(s); return n == null || !n.isFinite || n <= 0 ? 'Ingresa un número mayor que cero' : null; }
  String? validInt(String? s) { final n = int.tryParse((s ?? '').trim()); return n == null || n <= 0 ? 'Ingresa un número entero mayor que cero' : null; }
  Future<void> save() async { if (!key.currentState!.validate() || saving) return; setState(() => saving = true); try { await widget.repository.addControl(PrenatalControl(date: DateTime(date.year,date.month,date.day), weight: number(weight.text)!, systolic: int.parse(sys.text.trim()), diastolic: int.parse(dia.text.trim()), hemoglobin: number(hb.text)!, vaccines: vaccines.text.trim())); if (mounted) Navigator.pop(context, true); } catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo guardar el control.'))); } finally { if (mounted) setState(() => saving = false); } }
  @override Widget build(BuildContext context) => Scaffold(appBar: const BrandBar(), body: SafeArea(child: Form(key: key, child: ListView(padding: const EdgeInsets.all(16), children: [
    const SectionTitle('Registrar control'), const SizedBox(height: 16),
    RoundedCard(onTap: () async { final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime.now()); if (d != null) setState(() => date = d); }, child: Row(children: [const Icon(Icons.calendar_month, color: wine), const SizedBox(width: 12), Text('Fecha: ${dateLabel(date)}')])),
    const SizedBox(height: 12), field('ec0b9','Peso (kg)',weight,validNumber), const SizedBox(height: 12),
    Row(children: [Expanded(child: field('f8a18','Sistólica',sys,validInt)), const SizedBox(width: 8), Expanded(child: field('f8a18','Diastólica',dia,validInt))]),
    const Padding(padding: EdgeInsets.only(top: 4, left: 8), child: Text('Presión arterial (mmHg)', style: TextStyle(fontSize: 13))), const SizedBox(height: 12),
    field('eb710','Hemoglobina (g/dL)',hb,validNumber), const SizedBox(height: 12),
    TextFormField(controller: vaccines, maxLength: 200, decoration: InputDecoration(labelText: 'Vacunas (opcional)', prefixIcon: Padding(padding: const EdgeInsets.all(12), child: art('e6627', size: 26)))), const SizedBox(height: 20),
    const Text('Copia los valores de tu control. La aplicación no interpreta los resultados.'), const SizedBox(height: 16), PrimaryButton('Guardar', onPressed: saving ? null : save),
  ]))));
  Widget field(String icon, String label, TextEditingController controller, String? Function(String?) validator) => TextFormField(controller: controller, validator: validator, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: label, prefixIcon: Padding(padding: const EdgeInsets.all(12), child: art(icon, size: 26))));
}

class PrenatalCardScreen extends StatelessWidget {
  const PrenatalCardScreen({super.key, required this.controls}); final List<PrenatalControl> controls;
  Future<void> share(BuildContext context) async { try { final doc = pw.Document(); doc.addPage(pw.MultiPage(build: (_) => [pw.Header(level: 0, text: 'Carné prenatal digital'), pw.Text('Registro personal. Consultar y validar con el personal de salud.'), pw.SizedBox(height: 12), pw.TableHelper.fromTextArray(headers: ['Fecha','Peso kg','Presión mmHg','Hemoglobina g/dL'], data: controls.map((c) => [dateLabel(c.date), '${c.weight}', '${c.systolic}/${c.diastolic}', '${c.hemoglobin}']).toList())])); final dir = await getTemporaryDirectory(); final f = File('${dir.path}/carne-prenatal.pdf'); await f.writeAsBytes(await doc.save()); await SharePlus.instance.share(ShareParams(files: [XFile(f.path)], text: 'Mi carné prenatal')); } catch (_) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo preparar el archivo.'))); } }
  @override Widget build(BuildContext context) => Scaffold(appBar: const BrandBar(), body: SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SectionTitle('Carné prenatal digital'), const SizedBox(height: 16), Expanded(child: SingleChildScrollView(child: RoundedCard(padding: EdgeInsets.zero, child: Table(border: TableBorder(horizontalInside: BorderSide(color: rose)), children: [const TableRow(decoration: BoxDecoration(color: rose), children: [Cell('Fecha'),Cell('Peso\n(kg)'),Cell('Presión\n(mmHg)'),Cell('Hemoglobina\n(g/dL)')]), ...controls.map((c) => TableRow(children: [Cell(dateLabel(c.date)), Cell('${c.weight}'), Cell('${c.systolic}/${c.diastolic}'), Cell('${c.hemoglobin}')]))])))), const SizedBox(height: 16), PrimaryButton('Descargar o compartir', onPressed: controls.isEmpty ? null : () => share(context), icon: const Icon(Icons.share_outlined))]))));
}
class Cell extends StatelessWidget { const Cell(this.value, {super.key}); final String value; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(8), child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))); }

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key, required this.repository, this.embedded = false}); final LocalRepository repository; final bool embedded;
  @override State<AlertScreen> createState() => _AlertScreenState();
}
class _AlertScreenState extends State<AlertScreen> {
  int index = 0; final answers = <bool>[];
  final questions = const ['¿Tienes sangrado vaginal?', '¿Tienes dolor de cabeza intenso o persistente?', '¿Tienes hinchazón repentina de cara o manos?', '¿Tienes visión borrosa?', '¿Tienes fiebre?', '¿Has notado que tu bebé se mueve menos de lo habitual?'];
  void answer(bool value) { if (answers.length > index) { answers[index] = value; answers.removeRange(index + 1, answers.length); } else { answers.add(value); } if (index < questions.length - 1) { setState(() => index++); } else { Navigator.push(context, MaterialPageRoute(builder: (_) => AlertResultScreen(questions: questions, answers: List.of(answers), repository: widget.repository))); } }
  @override Widget build(BuildContext context) { final body = Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SectionTitle('Cuestionario de síntomas'), const SizedBox(height: 12), LinearProgressIndicator(value: (index + 1) / questions.length, color: wine, backgroundColor: rose, minHeight: 8, borderRadius: BorderRadius.circular(8)), const SizedBox(height: 8), Text('Paso ${index + 1} de ${questions.length}'), const SizedBox(height: 24), RoundedCard(color: rose, child: SizedBox(height: 180, width: double.infinity, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Align(alignment: Alignment.topRight, child: ListenButton(questions[index])), art('f0566', size: 42), const SizedBox(height: 12), Text(questions[index], textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))]))), const SizedBox(height: 16), Row(children: [Expanded(child: PrimaryButton('Sí', onPressed: () => answer(true), icon: const Icon(Icons.check))), const SizedBox(width: 12), Expanded(child: PrimaryButton('No', secondary: true, onPressed: () => answer(false), icon: const Icon(Icons.close)))]), const Spacer(), if (index > 0) PrimaryButton('← Atrás', secondary: true, onPressed: () => setState(() => index--)), const SizedBox(height: 8), const Text('Si tienes una emergencia, busca atención sin esperar a terminar el cuestionario.', style: TextStyle(fontSize: 13))])); return widget.embedded ? body : Scaffold(appBar: const BrandBar(), body: SafeArea(child: body)); }
}
class AlertResultScreen extends StatelessWidget {
  const AlertResultScreen({super.key, required this.questions, required this.answers, required this.repository}); final List<String> questions; final List<bool> answers; final LocalRepository repository;
  @override Widget build(BuildContext context) { final any = answers.any((a) => a); return Scaffold(appBar: const BrandBar(), body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [const SectionTitle('Estado de encuesta'), const SizedBox(height: 16), RoundedCard(child: Column(children: [for (var i=0;i<questions.length;i++) ListTile(contentPadding: EdgeInsets.zero, title: Text(questions[i]), trailing: Text(answers[i] ? 'Sí' : 'No', style: const TextStyle(fontWeight: FontWeight.w800)))])), const SizedBox(height: 16), RoundedCard(color: any ? const Color(0xFFFFE7E6) : rose, child: Text(any ? 'Acude ahora al establecimiento de salud o busca ayuda.' : 'Si te preocupa cómo te sientes, consulta con tu profesional de salud. Esta encuesta no descarta una complicación.', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))), const SizedBox(height: 16), PrimaryButton('Pedir ayuda', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SupportScreen(repository: repository)))), const SizedBox(height: 10), const Text('Orientación basada en señales de peligro del MINSA. No constituye un diagnóstico.')]))); }
}
