import 'package:flutter/material.dart';

void main() => runApp(const GestantesApp());

const wine = Color(0xFF791B38);
const rose = Color(0xFFF5E6EB);

class GestantesApp extends StatelessWidget {
  const GestantesApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Control de madres gestantes',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: wine, surface: const Color(0xFFFFF9F7)),
          scaffoldBackgroundColor: const Color(0xFFFFF9F7),
        ),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    const titles = ['Inicio', 'Mis controles', 'Señales de alerta', 'Configuración'];
    return Scaffold(
      appBar: AppBar(backgroundColor: wine, foregroundColor: Colors.white,
        title: const Text('RIMAYKULLAYKI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      body: SafeArea(child: selected == 0 ? _home() : _placeholder(titles[selected])),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (value) => setState(() => selected = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Controles'),
          NavigationDestination(icon: Icon(Icons.warning_amber_outlined), label: 'Alertas'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
        ],
      ),
    );
  }

  Widget _home() => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Bienvenida', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: wine, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),
    const Card(child: Padding(padding: EdgeInsets.all(20), child: Text(
      'Estamos preparando tu espacio de acompañamiento prenatal.', style: TextStyle(fontSize: 18)))),
    const SizedBox(height: 12),
    const Text('Versión inicial de desarrollo. Aún no guarda datos ni ofrece evaluación clínica.'),
    const SizedBox(height: 24),
    Wrap(spacing: 12, runSpacing: 12, children: [
      _action('Mis controles', Icons.calendar_month, () => setState(() => selected = 1)),
      _action('Educación', Icons.menu_book, () => _showPending('Educación')),
      _action('Señales de alerta', Icons.warning_amber, () => setState(() => selected = 2)),
      _action('Pedir ayuda', Icons.volunteer_activism, () => _showPending('Red de apoyo')),
    ]),
  ]);

  Widget _action(String title, IconData icon, VoidCallback onTap) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 44) / 2,
    child: Card(color: rose, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Icon(icon, color: wine, size: 32), const SizedBox(height: 8),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(color: wine, fontWeight: FontWeight.bold)),
      ])))));

  Widget _placeholder(String title) => ListView(padding: const EdgeInsets.all(16), children: [
    Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: wine, fontWeight: FontWeight.bold)),
    const SizedBox(height: 20),
    const Text('Esta función está en construcción. No ingreses datos personales en esta versión.'),
  ]);

  void _showPending(String title) => showDialog<void>(context: context, builder: (context) => AlertDialog(
    title: Text(title), content: const Text('Esta función está en construcción.'),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido'))]));
}
