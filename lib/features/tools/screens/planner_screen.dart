import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final TextEditingController _taskController = TextEditingController();
  TimeOfDay? _selectedTime;

  String _formatDate(DateTime date) => "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Future<void> _addTask() async {
    if (_taskController.text.trim().isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dateKey = _formatDate(_selectedDay);
    final timeString = _selectedTime != null ? _selectedTime!.format(context) : 'All Day';

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tasks').add({
        'title': _taskController.text.trim(),
        'date': dateKey,
        'time': timeString,
        'isCompleted': false,
        'createdAt': Timestamp.now(),
      });
      _taskController.clear();
      setState(() => _selectedTime = null); 
      if (mounted) Navigator.pop(context); 
    } catch (e) {
      debugPrint("ERR: $e");
    }
  }

  Future<void> _toggleTask(String docId, bool currentStatus) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tasks').doc(docId).update({'isCompleted': !currentStatus});
    } catch (e) {
      debugPrint("ERR: $e");
    }
  }

  Future<void> _editTaskDialog(String docId, String currentTitle, String currentTime) async {
    final TextEditingController editController = TextEditingController(text: currentTitle);
    String dialogSelectedTime = currentTime; 

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> saveEdit() async {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null || editController.text.trim().isEmpty) return;
            await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tasks').doc(docId).update({
              'title': editController.text.trim(),
              'time': dialogSelectedTime, 
            });
            if (context.mounted) Navigator.pop(context);
          }

          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Edit Task Node', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editController,
                  autofocus: true,
                  textInputAction: TextInputAction.done, 
                  onSubmitted: (_) => saveEdit(), 
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Task Objective',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.2))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 18, color: AppColors.primaryBlue),
                        const SizedBox(width: 8),
                        Text(dialogSelectedTime, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                      ],
                    ),
                    TextButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (picked != null) setDialogState(() => dialogSelectedTime = picked.format(context));
                      },
                      child: const Text('Adjust', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: saveEdit,
                child: const Text('Save Matrix', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteTask(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tasks').doc(docId).delete();
    } catch (e) {
      debugPrint("ERR: $e");
    }
  }

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 24, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Execution Node', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'monospace')),
              const SizedBox(height: 20),
              TextField(
                controller: _taskController,
                autofocus: true,
                textInputAction: TextInputAction.done, 
                onSubmitted: (_) => _addTask(), 
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g., Revise Network Topologies',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.2))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Text(
                        _selectedTime != null ? 'T-Minus: ${_selectedTime!.format(context)}' : 'Set Parameter',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: _selectedTime != null ? FontWeight.bold : FontWeight.normal, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (picked != null) {
                        setSheetState(() => _selectedTime = picked);
                        setState(() => _selectedTime = picked);
                      }
                    },
                    child: Text(_selectedTime != null ? 'Change' : 'Pick Time', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: _addTask,
                  child: const Text('INITIALIZE TASK', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 1.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final dateKey = _formatDate(_selectedDay);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Study Planner', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskBottomSheet,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: _softShadow()),
              padding: const EdgeInsets.all(16),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) => setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; }),
                onFormatChanged: (format) => setState(() => _calendarFormat = format),
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: AppColors.primaryLightTint, shape: BoxShape.circle),
                  todayTextStyle: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Scheduled Protocols', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Icon(Icons.assignment_outlined, color: AppColors.textSecondary, size: 22),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: user == null
                ? const Center(child: Text('// AUTH_REQUIRED', style: TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary)))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tasks').where('date', isEqualTo: dateKey).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('// NO TASKS DETECTED\nDeploy nodes using the + icon.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontFamily: 'monospace')));
                      }

                      final tasks = snapshot.data!.docs;
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final taskId = task.id;
                          final taskTitle = task['title'] as String;
                          final isCompleted = task['isCompleted'] as bool;
                          final taskTime = task.data().toString().contains('time') ? task['time'] as String : 'All Day';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Container(
                              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Checkbox(
                                  value: isCompleted,
                                  activeColor: AppColors.primaryBlue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (_) => _toggleTask(taskId, isCompleted),
                                ),
                                title: Text(
                                  taskTitle,
                                  style: TextStyle(
                                    color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time, size: 14, color: AppColors.primaryBlue.withValues(alpha: 0.7)),
                                      const SizedBox(width: 4),
                                      Text(taskTime, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace')),
                                    ],
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary), onPressed: () => _editTaskDialog(taskId, taskTitle, taskTime)),
                                    IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.errorRed), onPressed: () => _deleteTask(taskId)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<BoxShadow> _softShadow() => [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 4))];
}