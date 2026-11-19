import 'package:flutter/material.dart';
import '../data/local_repository.dart';
import '../design.dart';

class MiniCalendar extends StatefulWidget {
  const MiniCalendar({super.key, required this.next, required this.controls, required this.onSelect});
  final DateTime? next;
  final List<PrenatalControl> controls;
  final ValueChanged<DateTime> onSelect;
  @override State<MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<MiniCalendar> {
  late DateTime month;
  static const months = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
  @override void initState() { super.initState(); final d = widget.next ?? DateTime.now(); month = DateTime(d.year, d.month); }
  @override Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final leading = first.weekday % 7;
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    return RoundedCard(child: Column(children: [
      Row(children: [IconButton(onPressed: () => setState(() => month = DateTime(month.year, month.month - 1)), icon: const Icon(Icons.chevron_left), tooltip: 'Mes anterior'), Expanded(child: Text('${months[month.month - 1]} ${month.year}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), IconButton(onPressed: () => setState(() => month = DateTime(month.year, month.month + 1)), icon: const Icon(Icons.chevron_right), tooltip: 'Mes siguiente')]),
      Row(children: [for (final day in ['D','L','M','M','J','V','S']) Expanded(child: Center(child: Text(day, style: const TextStyle(fontWeight: FontWeight.w800))))]),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: leading + days, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1), itemBuilder: (context, index) {
        if (index < leading) return const SizedBox.shrink();
        final date = DateTime(month.year, month.month, index - leading + 1);
        final selected = widget.next != null && DateUtils.isSameDay(date, widget.next);
        final past = date.isBefore(DateUtils.dateOnly(DateTime.now()));
        final hasControl = widget.controls.any((c) => DateUtils.isSameDay(date, c.date));
        return InkWell(onTap: past ? null : () => widget.onSelect(date), borderRadius: BorderRadius.circular(30), child: Container(margin: const EdgeInsets.all(2), decoration: BoxDecoration(color: selected ? wine : Colors.transparent, shape: BoxShape.circle), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('${date.day}', style: TextStyle(color: selected ? Colors.white : past ? Colors.grey : ink, fontWeight: selected ? FontWeight.w800 : FontWeight.w500)), if (hasControl) Container(width: 5, height: 5, decoration: BoxDecoration(color: selected ? Colors.white : wine, shape: BoxShape.circle))])));
      }),
      const SizedBox(height: 8), const Text('Toca una fecha futura para programar tu próximo control.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
    ]));
  }
}
