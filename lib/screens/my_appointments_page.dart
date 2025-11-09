import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../notification_service.dart';

class MyAppointmentsPage extends StatelessWidget {
  const MyAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("You need to log in to view your appointments.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('ownerId', isEqualTo: user.uid)
            .orderBy('appointmentDate')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No appointments found."));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final petName = data['petName'] ?? 'Unknown Pet';
              final doctorName = data['doctorName'] ?? 'Unknown Doctor';
              final appointmentType = data['type'] ?? 'Unknown Type';
              final Timestamp ts = data['appointmentDate'] as Timestamp;
              final date = ts.toDate();
              final formattedDate =
                  DateFormat('dd MMM yyyy, hh:mm a').format(date);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today,
                      color: AppColors.primaryBlue),
                  title: Text("$petName - $doctorName"),
                  subtitle: Text("$appointmentType • $formattedDate"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'reschedule') {
                        _rescheduleAppointment(context, doc.id, date);
                      } else if (value == 'delete') {
                        _deleteAppointment(context, doc.id);
                      } else if (value == 'reminder') {
                        _setReminder(context, petName, doctorName, date);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'reschedule',
                        child: Text('Reschedule'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                      PopupMenuItem(
                        value: 'reminder',
                        child: Text('Set Reminder'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // 🔹 Delete appointment
  void _deleteAppointment(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Appointment"),
        content: const Text("Are you sure you want to delete this appointment?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(id)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment deleted')),
      );
    }
  }

  // 🔹 Reschedule appointment
  void _rescheduleAppointment(
      BuildContext context, String id, DateTime oldDateTime) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: oldDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );

    if (newDate != null) {
      TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(oldDateTime),
      );

      if (newTime != null) {
        final newDateTime = DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
          newTime.hour,
          newTime.minute,
        );

        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(id)
            .update({
          'appointmentDate': Timestamp.fromDate(newDateTime),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment rescheduled')),
        );
      }
    }
  }

  // 🔹 Set reminder notification
  void _setReminder(
      BuildContext context, String petName, String doctorName, DateTime appointmentTime) async {
    final reminderTime = appointmentTime.subtract(const Duration(minutes: 30));

    if (reminderTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment is too soon for a reminder!')),
      );
      return;
    }

    // <-- CORRECT CALL: use the static method defined in notification_service.dart
    await NotificationService.scheduleReminderNotification(
      title: "Upcoming Appointment 🐶",
      body: "$petName has an appointment with $doctorName at ${DateFormat('hh:mm a').format(appointmentTime)}",
      scheduledTime: reminderTime,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder set 30 minutes before appointment')),
    );
  }
}
