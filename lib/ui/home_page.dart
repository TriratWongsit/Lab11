import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'note_form_page.dart';
import 'state/note_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลครั้งแรกเมื่อหน้าจอสร้างเสร็จ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteStore>().loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ดึง state มาใช้งาน
    final store = context.watch<NoteStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes (SQLite)'),
        actions: [
          IconButton(
            tooltip: 'ล้างทั้งหมด',
            onPressed: store.loading
                ? null
                : () async {
                    // แจ้งเตือนยืนยันก่อนลบ
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('ยืนยัน'),
                        content: const Text('ต้องการลบโน้ตทั้งหมดใช่ไหม?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('ยกเลิก'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('ลบ'),
                          ),
                        ],
                      ),
                    );

                    if (ok == true && context.mounted) {
                      await context.read<NoteStore>().clearAll();
                    }
                  },
            icon: const Icon(Icons.delete_forever),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: store.loading
            ? null
            : () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NoteFormPage()),
                );
              },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // แสดงแถบแจ้งเตือนถ้ามี Error
            if (store.error != null)
              MaterialBanner(
                content: Text(store.error!),
                actions: [
                  TextButton(
                    onPressed: () => context.read<NoteStore>().loadNotes(),
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            
            // ส่วนแสดงรายการ (List)
            Expanded(
              child: store.loading
                  ? const Center(child: CircularProgressIndicator())
                  : store.notes.isEmpty
                      ? const Center(child: Text('ยังไม่มีโน้ต'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: store.notes.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final n = store.notes[i];
                            
                            // จัดรูปแบบวันที่ (วัน/เดือน/ปี เวลา:นาที)
                            final dateStr = 
                              '${n.createdAt.day}/${n.createdAt.month}/${n.createdAt.year} '
                              '${n.createdAt.hour}:${n.createdAt.minute.toString().padLeft(2, '0')}';

                            return Card(
                              elevation: 2,
                              child: ListTile(
                                title: Text(
                                  n.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.content,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    // ส่วนแสดงวันที่ที่เพิ่มเข้ามา
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          'บันทึกเมื่อ: $dateStr',
                                          style: TextStyle(
                                            fontSize: 12, 
                                            color: Colors.grey[600]
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => context
                                      .read<NoteStore>()
                                      .removeNote(n.id!),
                                ),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NoteFormPage(
                                        noteId: n.id,
                                        initialTitle: n.title,
                                        initialContent: n.content,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}