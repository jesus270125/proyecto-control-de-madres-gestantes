import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';

const wine = Color(0xFF7B1E3A);
const ink = Color(0xFF5E142B);
const rose = Color(0xFFF4E4E9);
const cream = Color(0xFFF7ECCD);
const background = Color(0xFFFFF9F7);
final textScale = ValueNotifier<double>(1);

Widget art(String id, {double size = 28}) => SvgPicture.asset('assets/figma/$id.svg', width: size, height: size, fit: BoxFit.contain);

class Voice {
  static final FlutterTts _tts = FlutterTts();
  static Future<void> speak(BuildContext context, String text) async {
    try {
      await _tts.setLanguage('es-PE');
      await _tts.setSpeechRate(0.43);
      await _tts.speak(text);
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La voz en español no está disponible en este dispositivo.')));
    }
  }
}

class BrandBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandBar({super.key, this.onBack, this.readText = 'Rimaykullayki. Cuidando tu maternidad.'});
  final VoidCallback? onBack;
  final String readText;
  @override
  Size get preferredSize => const Size.fromHeight(64);
  @override
  Widget build(BuildContext context) => AppBar(
    automaticallyImplyLeading: false, backgroundColor: wine, foregroundColor: Colors.white,
    toolbarHeight: 56, centerTitle: true,
    leading: IconButton(onPressed: onBack ?? () { if (Navigator.canPop(context)) Navigator.pop(context); }, icon: const Icon(Icons.arrow_back)),
    title: const Text('RIMAYKULLAYKI', style: TextStyle(fontSize: 16, letterSpacing: .5, fontWeight: FontWeight.w800)),
    actions: [IconButton(onPressed: () => Voice.speak(context, readText), tooltip: 'Escuchar', icon: const Icon(Icons.volume_up_outlined))],
    bottom: PreferredSize(preferredSize: const Size.fromHeight(8), child: SizedBox(height: 8, child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(18, (i) => art(i % 3 == 0 ? 'febe8' : '091ba', size: 8))))));
}

class RoundedCard extends StatelessWidget {
  const RoundedCard({super.key, required this.child, this.color = Colors.white, this.padding = const EdgeInsets.all(16), this.onTap});
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(color: color, elevation: 0, margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Padding(padding: padding, child: child)));
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.text, {super.key, required this.onPressed, this.secondary = false, this.icon});
  final String text;
  final VoidCallback? onPressed;
  final bool secondary;
  final Widget? icon;
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 56,
    child: FilledButton(onPressed: onPressed, style: FilledButton.styleFrom(backgroundColor: secondary ? rose : wine,
      foregroundColor: secondary ? ink : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [if (icon != null) ...[icon!, const SizedBox(width: 10)], Flexible(child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)))])));
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink, height: 1.2));
}

class ListenButton extends StatelessWidget {
  const ListenButton(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => IconButton(onPressed: () => Voice.speak(context, text), tooltip: 'Escuchar', icon: const Icon(Icons.volume_up_outlined, color: wine));
}
