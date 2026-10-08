import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  Map<String, String> _attendanceData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  String _formatDate(DateTime date) => "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Future<void> _fetchAttendance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('academic_records').doc('attendance').get();
      if (doc.exists && doc.data() != null) setState(() => _attendanceData = Map<String, String>.from(doc.data()!));
    } catch (e) {
      debugPrint("ERR: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cycleAttendance(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String dateKey = _formatDate(date);
    String currentStatus = _attendanceData[dateKey] ?? '';
    
    String newStatus = '';
    if (currentStatus == '') newStatus = 'present';
    else if (currentStatus == 'present') newStatus = 'absent';
    else if (currentStatus == 'absent') newStatus = 'holiday';

    setState(() {
      if (newStatus == '') _attendanceData.remove(dateKey);
      else _attendanceData[dateKey] = newStatus;
    });

    try {
      if (newStatus == '') {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('academic_records').doc('attendance').update({dateKey: FieldValue.delete()});
      } else {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('academic_records').doc('attendance').set({dateKey: newStatus}, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("ERR: $e");
    }
  }

  Map<String, dynamic> _calculateStats() {
    int present = 0, absent = 0;
    _attendanceData.forEach((key, status) {
      if (status == 'present') present++;
      if (status == 'absent') absent++;
    });

    int totalConducted = present + absent; 
    double percentage = totalConducted == 0 ? 100.0 : (present / totalConducted) * 100;
    String message = "Initialize attendance logs.";
    Color statusColor = AppColors.successGreen;

    if (totalConducted > 0) {
      if (percentage >= 75.0) {
        int safeBunks = ((present - 0.75 * totalConducted) / 0.75).floor();
        message = "Safe margin: $safeBunks absent nodes allowed.";
        statusColor = AppColors.successGreen;
      } else {
        int requiredClasses = (3 * totalConducted) - (4 * present);
        message = "Critical: Attend $requiredClasses subsequent nodes.";
        statusColor = AppColors.errorRed;
      }
    }
    return {'percentage': percentage, 'message': message, 'color': statusColor};
  }

  Widget _buildCalendarDay(DateTime day, String status, {bool isToday = false}) {
    Color? bgColor;
    Color textColor = AppColors.textPrimary;
    BoxBorder? border;
    
    if (status == 'present') bgColor = AppColors.successGreen.withValues(alpha: 0.2);
    else if (status == 'absent') bgColor = AppColors.errorRed.withValues(alpha: 0.2);
    else if (status == 'holiday') bgColor = AppColors.warningOrange.withValues(alpha: 0.2);
    
    if (isToday && status == '') {
      border = Border.all(color: AppColors.primaryBlue, width: 2.0);
      textColor = AppColors.primaryBlue;
    } else if (isToday && status != '') {
      border = Border.all(color: AppColors.primaryBlue, width: 2.0);
    }

    return Container(
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: border),
      alignment: Alignment.center,
      child: Text(day.day.toString(), style: TextStyle(color: textColor, fontWeight: isToday ? FontWeight.bold : FontWeight.w600, fontFamily: 'monospace')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance Matrix', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: stats['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: stats['color'].withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(stats['color'] == AppColors.successGreen ? Icons.check_circle_outline : Icons.warning_amber_rounded, color: stats['color'], size: 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Index: ${stats['percentage'].toStringAsFixed(1)}%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: stats['color'], fontFamily: 'monospace')),
                            const SizedBox(height: 4),
                            Text(stats['message'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'monospace')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15)]),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          headerStyle: const HeaderStyle(formatButtonVisible: false, titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) => _buildCalendarDay(day, _attendanceData[_formatDate(day)] ?? ''),
                            todayBuilder: (context, day, focusedDay) => _buildCalendarDay(day, _attendanceData[_formatDate(day)] ?? '', isToday: true),
                          ),
                          onDaySelected: (selectedDay, focusedDay) {
                            _cycleAttendance(selectedDay);
                            setState(() => _focusedDay = focusedDay);
                          },
                        ),
                        const Divider(height: 30, color: AppColors.divider),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildLegendItem('P', AppColors.successGreen),
                            _buildLegendItem('A', AppColors.errorRed),
                            _buildLegendItem('H', AppColors.warningOrange),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color.withValues(alpha: 0.3), shape: BoxShape.circle, border: Border.all(color: color))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }
}