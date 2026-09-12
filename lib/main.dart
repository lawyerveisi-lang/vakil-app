import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:isar_flutter_libs/isar_flutter_libs.dart';
import 'package:path_provider/path_provider.dart';

import 'models/client.dart';
import 'models/case.dart';
import 'models/action.dart';
import 'models/calendar_event.dart';
import 'models/document.dart';
import 'models/audio_record.dart';
import 'models/legal_reference.dart';
import 'ui/dashboard_screen.dart';

late Isar isar;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [
      ClientSchema,
      CaseSchema,
      ActionSchema,
      CalendarEventSchema,
      DocumentSchema,
      AudioRecordSchema,
      LegalReferenceSchema,
    ],
    directory: dir.path,
  );
  runApp(const ProviderScope(child: DadbanApp()));
}

class DadbanApp extends StatelessWidget {
  const DadbanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دادبان',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B3D2E)),
        useMaterial3: true,
        fontFamily: 'Vazir',
      ),
      home: const DashboardScreen(),
    );
  }
}
