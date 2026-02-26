import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // เพิ่ม import นี้
import '../data/models/event_model.dart';
import 'state/event_store.dart';

class EventFormPage extends StatefulWidget {
  final EventModel? event;
  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtl;
  late TextEditingController _descCtl;
  
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  int? _selectedCategoryId;
  String _status = 'pending';
  int _priority = 1; 

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleCtl = TextEditingController(text: e?.title ?? '');
    _descCtl = TextEditingController(text: e?.description ?? '');
    _selectedDate = e?.eventDate ?? DateTime.now();
    
    _startTime = e != null ? _strToTime(e.startTime) : TimeOfDay.now();
    _endTime = e != null ? _strToTime(e.endTime) : TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
    
    _selectedCategoryId = e?.categoryId;
    _status = e?.status ?? 'pending';
    _priority = e?.priority ?? 2;
  }

  TimeOfDay _strToTime(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
  
  String _formatTime(TimeOfDay t) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat('HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<EventStore>();
    
    if (_selectedCategoryId == null && store.categories.isNotEmpty) {
      _selectedCategoryId = store.categories.first.id;
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.event == null ? 'เพิ่มกิจกรรม' : 'แก้ไขกิจกรรม')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtl,
              decoration: const InputDecoration(labelText: 'ชื่อกิจกรรม *'),
              validator: (v) => v!.isEmpty ? 'ระบุชื่อกิจกรรม' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descCtl,
              decoration: const InputDecoration(labelText: 'รายละเอียด'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            
            // Category Dropdown
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(labelText: 'หมวดหมู่'),
              items: store.categories.map((c) => DropdownMenuItem(
                value: c.id,
                child: Text(c.name),
              )).toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
              validator: (v) => v == null ? 'กรุณาเลือกหมวดหมู่' : null,
            ),

            const SizedBox(height: 10),
            // Date Picker
            ListTile(
              title: Text('วันที่: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context, 
                  initialDate: _selectedDate, 
                  firstDate: DateTime(2000), 
                  lastDate: DateTime(2100)
                );
                if (d != null) setState(() => _selectedDate = d);
              },
            ),
            
            // Time Pickers
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('เริ่ม'),
                    subtitle: Text(_startTime.format(context)),
                    onTap: () async {
                      final t = await showTimePicker(context: context, initialTime: _startTime);
                      if (t != null) setState(() => _startTime = t);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('สิ้นสุด'),
                    subtitle: Text(_endTime.format(context)),
                    onTap: () async {
                      final t = await showTimePicker(context: context, initialTime: _endTime);
                      if (t != null) setState(() => _endTime = t);
                    },
                  ),
                ),
              ],
            ),

            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'สถานะ'),
              items: ['pending','in_progress','completed','cancelled']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final double startVal = _startTime.hour + _startTime.minute/60.0;
                  final double endVal = _endTime.hour + _endTime.minute/60.0;
                  
                  if (endVal <= startVal) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('เวลาสิ้นสุดต้องมากกว่าเวลาเริ่ม!'), backgroundColor: Colors.red),
                    );
                    return;
                  }

                  final event = EventModel(
                    id: widget.event?.id,
                    title: _titleCtl.text,
                    description: _descCtl.text,
                    categoryId: _selectedCategoryId!,
                    eventDate: _selectedDate,
                    startTime: _formatTime(_startTime),
                    endTime: _formatTime(_endTime),
                    status: _status,
                    priority: _priority,
                  );

                  if (widget.event == null) {
                    context.read<EventStore>().addEvent(event);
                  } else {
                    context.read<EventStore>().updateEvent(event);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('บันทึก'),
            )
          ],
        ),
      ),
    );
  }
}