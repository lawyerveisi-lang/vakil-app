import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../models/client.dart';
import '../models/case.dart';

final clientsProvider = StreamProvider<List<Client>>(
  (ref) => isar.clients.watch(fireImmediately: true),
);

final casesProvider = StreamProvider<List<Case>>(
  (ref) => isar.cases.watch(fireImmediately: true),
);

class CasesScreen extends ConsumerWidget {
  const CasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientsProvider).value ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('موکل‌ها و پرونده‌ها')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addClientDialog(context),
        child: const Icon(Icons.person_add),
      ),
      body: clients.isEmpty
          ? const Center(child: Text('هنوز موکلی ثبت نشده است'))
          : ListView.builder(
              itemCount: clients.length,
              itemBuilder: (_, i) {
                final c = clients[i];
                return ExpansionTile(
                  title: Text(c.fullName),
                  subtitle: Text(c.phone ?? ''),
                  children: [
                    FutureBuilder<List<Case>>(
                      future: isar.cases.filter().clientIdEqualTo(c.id).findAll(),
                      builder: (_, snap) {
                        final cases = snap.data ?? [];
                        return Column(children: [
                          ...cases.map((cs) => ListTile(
                                title: Text(cs.title),
                                subtitle: Text(cs.caseNumber ?? ''),
                              )),
                          TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('پرونده جدید'),
                            onPressed: () => _addCaseDialog(context, c.id),
                          ),
                        ]);
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }

  void _addClientDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('موکل جدید'),
      content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'نام کامل')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو')),
        FilledButton(onPressed: () async {
          if (ctrl.text.trim().isNotEmpty) {
            final c = Client()..fullName = ctrl.text.trim();
            await isar.writeTxn(() => isar.clients.put(c));
          }
          if (context.mounted) Navigator.pop(context);
        }, child: const Text('ثبت')),
      ],
    ));
  }

  void _addCaseDialog(BuildContext context, int clientId) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('پرونده جدید'),
      content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'عنوان پرونده')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو')),
        FilledButton(onPressed: () async {
          if (ctrl.text.trim().isNotEmpty) {
            final cs = Case()..clientId = clientId..title = ctrl.text.trim();
            await isar.writeTxn(() => isar.cases.put(cs));
          }
          if (context.mounted) Navigator.pop(context);
        }, child: const Text('ثبت')),
      ],
    ));
  }
}
