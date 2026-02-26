import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // เพิ่ม import นี้
import 'event_form_page.dart';
import 'state/event_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventStore>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<EventStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('Event Planner')),
      body: Column(
        children: [
          // Filter Section
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ActionChip(
                  label: const Text('วันนี้'),
                  onPressed: () => store.setDateFilter(DateTime.now()),
                  avatar: store.filterDate != null ? const Icon(Icons.check) : null,
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('ทั้งหมด'),
                  onPressed: () => store.setDateFilter(null),
                  avatar: store.filterDate == null ? const Icon(Icons.check) : null,
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: store.filterStatus, // ตอนนี้ใช้ได้แล้ว เพราะเพิ่ม getter ใน store แล้ว
                  items: ['All', 'pending', 'completed']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => store.setStatusFilter(v!),
                ),
              ],
            ),
          ),
          
          // List Section
          Expanded(
            child: store.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: store.events.length,
                    itemBuilder: (context, index) {
                      final event = store.events[index];
                      // หาหมวดหมู่เพื่อเอาสีและไอคอน
                      final cat = store.categories.firstWhere(
                        (c) => c.id == event.categoryId,
                        orElse: () => store.categories.isNotEmpty 
                            ? store.categories.first 
                            : null as dynamic // Fallback
                      );
                      
                      Color color = Colors.blue;
                      if (cat != null) {
                         color = Color(int.parse(cat.colorHex, radix: 16));
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color,
                            child: Icon(_getIcon(cat?.iconKey ?? 'event'), color: Colors.white),
                          ),
                          title: Text(event.title, 
                            style: TextStyle(
                              decoration: event.status == 'completed' 
                                  ? TextDecoration.lineThrough : null
                            )
                          ),
                          subtitle: Text(
                            '${DateFormat('dd/MM').format(event.eventDate)} | ${event.startTime}-${event.endTime}\nสถานะ: ${event.status}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => store.deleteEvent(event.id!),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EventFormPage(event: event)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const EventFormPage())
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIcon(String key) {
    switch (key) {
      case 'work': return Icons.work;
      case 'person': return Icons.person;
      case 'warning': return Icons.warning;
      default: return Icons.event;
    }
  }
}