import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:table_calendar/table_calendar.dart';
import '../main.dart';
import '../models/calendar_event.dart';

/// Calendar with Jalali (Shamsi) deadlines.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(_eventsProvider).value ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('تقویم شمسی و مهلت‌ها')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEventDialog(context),
        child: const Icon(Icons.event),
      ),
      body: TableCalendar(
        calendarFormat: CalendarFormat.month,
        firstDay: DateTime(1300, 1, 1),
        lastDay: DateTime(1500, 1, 1),
        focusedDay: DateTime.now(),
        daysOfWeekLabels: const ['ش','ی','د','س','چ','پ','ج'],
        monthNames: const ['فروردین','اردیبهشت','خرداد','تیر','مرداد','شهریور','مهر','آبان','آذر','دی','بهمن','اسفند'],
        eventLoader: (day) => events.where((e) => isSameDay(e.date, day)).toList(),
        onPageChanged: (_) {},
      ),
    );
  }

  void _addEventDialog(BuildContext context) {
    final title = TextEditingController();
    DateTime date = DateTime.now();
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (_, setState) => AlertDialog(
      title: const Text('رویداد / مهلت جدید'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان (مثلاً مهلت اعتراض)')),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) setState(() => date = picked);
          },
          child: Text('تاریخ: ${_jalali(date)}'),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو')),
        FilledButton(onPressed: () async {
          if (title.text.trim().isNotEmpty) {
            final e = CalendarEvent()..title = title.text.trim()..date = date..kind = 'deadline';
            await isar.writeTxn(() => isar.calendarEvents.put(e));
          }
          if (context.mounted) Navigator.pop(context);
        }, child: const Text('ثبت')),
      ],
    )));
  }

  static String _jalali(DateTime d) {
    final j = d.toJalali();
    return '${j.year}/${j.month.toString().padLeft(2,'0')}/${j.day.toString().padLeft(2,'0')}';
  }
}

final _eventsProvider = StreamProvider<List<CalendarEvent>>(
  (ref) => isar.calendarEvents.watch(fireImmediately: true),
);
