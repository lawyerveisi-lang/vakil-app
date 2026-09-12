import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'cases_screen.dart';
import 'calendar_screen.dart';
import 'scanner_screen.dart';
import 'audio_screen.dart';
import 'legal_search_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _todayJalali() {
    final d = DateTime.now();
    final j = d.toJalali();
    return '${j.formatter.wn} ${j.day} ${j.formatter.mn} ${j.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دادبان — دستیار وکیل'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('امروز', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_todayJalali(), style: const TextStyle(fontSize: 16)),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            _Tile(icon: Icons.folder, title: 'موکل‌ها و پرونده‌ها', onTap: () => _go(context, const CasesScreen())),
            _Tile(icon: Icons.calendar_month, title: 'تقویم و مهلت‌های شمسی', onTap: () => _go(context, const CalendarScreen())),
            _Tile(icon: Icons.document_scanner, title: 'اسکنر و OCR', onTap: () => _go(context, const ScannerScreen())),
            _Tile(icon: Icons.mic, title: 'ضبط صوت با پیاده‌سازی زنده', onTap: () => _go(context, const AudioScreen())),
            _Tile(icon: Icons.gavel, title: 'جستجوی قوانین', onTap: () => _go(context, const LegalSearchScreen())),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext c, Widget s) => Navigator.push(c, MaterialPageRoute(builder: (_) => s));
}

class _Tile extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback onTap;
  const _Tile({required this.icon, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(leading: Icon(icon), title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: onTap),
  );
}
