import 'package:flutter/material.dart';
import '../data/local_repository.dart';
import '../design.dart';
import 'support_screens.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key, required this.repository}); final LocalRepository repository;
  @override Widget build(BuildContext context) => Scaffold(appBar: const BrandBar(), body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [const SectionTitle('Educación'), const SizedBox(height: 20),
    topic(context, '52037', 'Alimentación', const NutritionScreen()),
    topic(context, '268be', 'Hierro y vacunas', const CareTopicScreen(title: 'Hierro y vacunas', sections: [
      ('Hierro', 'Toma los suplementos indicados por tu profesional de salud. Si tienes molestias o dudas, consúltale antes de cambiar la dosis.'),
      ('Vacunas', 'Consulta en tu establecimiento cuáles son las vacunas indicadas durante tu embarazo y lleva tu carné a cada control.') ])),
    topic(context, '50914', 'Cuidados', const CareTopicScreen(title: 'Cuidados', sections: [
      ('Descanso', 'Descansa y conversa con tu profesional de salud sobre las actividades adecuadas para ti.'),
      ('Controles prenatales', 'Acude a tus controles y lleva tus resultados y tu carné prenatal.'),
      ('Alimentación', 'Procura una alimentación variada y sigue las indicaciones de tu establecimiento de salud.') ])),
    topic(context, 'c4ca9', 'Señales de alarma', DangerSignsScreen(repository: repository)),
  ])));
  Widget topic(BuildContext context, String icon, String text, Widget page) => Padding(padding: const EdgeInsets.only(bottom: 16), child: RoundedCard(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)), child: SizedBox(height: 92, child: Row(children: [CircleAvatar(radius: 34, backgroundColor: cream, child: art(icon, size: 36)), const SizedBox(width: 16), Expanded(child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), const Icon(Icons.chevron_right, color: wine)]))));
}

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: const BrandBar(), body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [const SectionTitle('Alimentación'), const SizedBox(height: 16),
    group(context, 'Alimentos constructores', 'Ayudan a formar y mantener los tejidos del cuerpo.', [('4d1fe','Sangrecita'),('252bc','Carne'),('0d770','Huevo'),('1cf04','Habas'),('c8195','Lentejas'),('99f90','Frejoles')]),
    group(context, 'Alimentos reguladores', 'Incluye frutas y verduras variadas en tus comidas.', [('71111','Zanahoria'),('a65b2','Espinaca'),('4c1d0','Tomate'),('cfe01','Naranja'),('56a5e','Papaya'),('d7c80','Zapallo')]),
    group(context, 'Alimentos energéticos', 'Complementan tus comidas y aportan energía.', [('1feee','Papa'),('438fe','Maíz'),('3a5c0','Camote')]),
    PrimaryButton('Arma tu menú →', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuScreen()))), const SizedBox(height: 12),
    const Text('Fuente: contenidos de alimentación para gestantes del MINSA. Consulta recomendaciones personales con tu profesional de salud.', style: TextStyle(fontSize: 12))])));
  Widget group(BuildContext context, String title, String description, List<(String,String)> foods) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [RoundedCard(color: rose, padding: const EdgeInsets.all(10), child: Row(children: [const Icon(Icons.volume_up_outlined, color: wine), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), ListenButton('$title. $description')])), const SizedBox(height: 8), Text(description), const SizedBox(height: 8), GridView.count(crossAxisCount: 3, childAspectRatio: .92, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 8, mainAxisSpacing: 8, children: foods.map((f) => RoundedCard(color: rose, onTap: () => Voice.speak(context, f.$2), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(radius: 34, backgroundColor: cream, child: art(f.$1, size: 44)), const SizedBox(height: 8), Text(f.$2, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800))]))).toList()), const SizedBox(height: 16)]);
}

class MenuScreen extends StatefulWidget { const MenuScreen({super.key}); @override State<MenuScreen> createState() => _MenuScreenState(); }
class _MenuScreenState extends State<MenuScreen> {
  final selected = <String, String>{};
  final groups = const {'Constructores':['Sangrecita','Carne','Huevo','Habas','Lentejas','Frejoles'], 'Reguladores':['Zanahoria','Espinaca','Tomate','Naranja','Papaya','Zapallo'], 'Energéticos':['Papa','Maíz','Camote']};
  @override Widget build(BuildContext context) => Scaffold(appBar: const BrandBar(), body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [const SectionTitle('Arma tu menú'), const SizedBox(height: 12), const Text('Elige un alimento de cada grupo para armar tu plato.'), const SizedBox(height: 16), for (final entry in groups.entries) ...[RoundedCard(color: rose, child: Text(entry.key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), const SizedBox(height: 8), Wrap(spacing: 8, children: entry.value.map((v) => ChoiceChip(label: Text(v), selected: selected[entry.key] == v, onSelected: (_) => setState(() => selected[entry.key] = v))).toList()), const SizedBox(height: 12)], RoundedCard(child: Text(selected.isEmpty ? 'Tu plato aún está vacío.' : 'Tu plato: ${selected.values.join(', ')}')), const SizedBox(height: 16), const Text('Esta actividad es educativa y no sustituye una indicación nutricional personalizada.')])));
}

class CareTopicScreen extends StatelessWidget {
  const CareTopicScreen({super.key, required this.title, required this.sections}); final String title; final List<(String,String)> sections;
  @override Widget build(BuildContext context) => Scaffold(appBar: BrandBar(readText: title), body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [SectionTitle(title), const SizedBox(height: 16), for (final s in sections) Padding(padding: const EdgeInsets.only(bottom: 12), child: RoundedCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(s.$1, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))), ListenButton('${s.$1}. ${s.$2}')]), Text(s.$2, style: const TextStyle(fontSize: 16))]))), const Text('Información general. Sigue las indicaciones de tu profesional de salud.', style: TextStyle(fontSize: 13))])));
}

class DangerSignsScreen extends StatelessWidget {
  const DangerSignsScreen({super.key, required this.repository}); final LocalRepository repository;
  @override Widget build(BuildContext context) { const signs = ['Sangrado vaginal','Dolor de cabeza intenso o persistente','Visión borrosa','Hinchazón repentina de cara o manos','Fiebre','Pérdida de líquido por la vagina','Convulsiones o desmayo','Disminución de los movimientos del bebé']; return Scaffold(appBar: const BrandBar(), body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [const SectionTitle('Señales de alarma'), const SizedBox(height: 12), const RoundedCard(color: Color(0xFFFFE7E6), child: Text('Si presentas alguna señal de peligro, acude inmediatamente al establecimiento de salud acompañada.', style: TextStyle(fontWeight: FontWeight.w800))), const SizedBox(height: 12), for (final s in signs) Padding(padding: const EdgeInsets.only(bottom: 8), child: RoundedCard(child: Row(children: [const Icon(Icons.warning_amber_rounded, color: wine), const SizedBox(width: 12), Expanded(child: Text(s, style: const TextStyle(fontWeight: FontWeight.w700))), ListenButton(s)]))), PrimaryButton('Pedir ayuda', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SupportScreen(repository: repository)))), const SizedBox(height: 8), const Text('Fuente: MINSA, Rotafolio para el cuidado de la gestante.', style: TextStyle(fontSize: 12))]))); }
}
