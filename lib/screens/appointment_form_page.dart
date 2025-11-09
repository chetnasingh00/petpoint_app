import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../notification_service.dart';
import '../theme.dart';

class AppointmentFormPage extends StatefulWidget {
  final String? appointmentId;
  final String? doctorId;
  final dynamic doctorName; // changed to dynamic to handle String or List
  final Map<String, dynamic>? existingData;

  const AppointmentFormPage({
    super.key,
    this.appointmentId,
    this.doctorId,
    this.doctorName,
    this.existingData,
  });

  @override
  State<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  String? selectedPet;
  String? appointmentType = 'Clinic';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isSaving = false;

  /// Converts doctorName safely to a string
  String get doctorNameString {
    if (widget.doctorName == null) return '';
    if (widget.doctorName is String) return widget.doctorName!;
    if (widget.doctorName is List) return (widget.doctorName as List).join(", ");
    return widget.doctorName.toString();
  }

  /// Book the appointment and schedule a notification reminder
  Future<void> bookAppointment() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must be logged in to book an appointment."),
        ),
      );
      return;
    }

    if (selectedPet == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select pet, date, and time.")),
      );
      return;
    }

    final appointmentDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    setState(() => isSaving = true);

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('appointments')
          .add({
        'ownerId': user.uid,
        'doctorId': widget.doctorId,
        'doctorName': doctorNameString,
        'petName': selectedPet,
        'appointmentDate': Timestamp.fromDate(appointmentDate),
        'type': appointmentType,
        'status': 'Pending',
        'createdAt': Timestamp.now(),
      });

      await NotificationService.scheduleReminderNotification(
        title: "🐾 Appointment Reminder",
        body:
            "You have an appointment with $doctorNameString for $selectedPet at ${selectedTime!.format(context)}.",
        scheduledTime: DateTime.now().add(const Duration(seconds: 15)),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment booked successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to book appointment: $e")));
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in first.")));
    }

    final petsRef = FirebaseFirestore.instance
        .collection('owners')
        .doc(user.uid)
        .collection('pets');

    return Scaffold(
      appBar: AppBar(
        title: Text("Book with $doctorNameString"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: petsRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Error loading pets: ${snapshot.error}"),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final pets = snapshot.data!.docs;

            if (pets.isEmpty) {
              return const Center(
                child: Text("You don't have any pets added."),
              );
            }

            return ListView(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Select Pet"),
                  value: selectedPet,
                  items: pets.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final petName = data['name']?.toString() ?? 'Unnamed Pet';
                    return DropdownMenuItem<String>(
                      value: petName,
                      child: Text(petName),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedPet = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Appointment Type",
                  ),
                  value: appointmentType,
                  items: const [
                    DropdownMenuItem(
                      value: "Clinic",
                      child: Text("Clinic Visit"),
                    ),
                    DropdownMenuItem(value: "Home", child: Text("Home Visit")),
                  ],
                  onChanged: (value) => setState(() => appointmentType = value),
                ),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    selectedDate == null
                        ? "Choose Date"
                        : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      initialDate: DateTime.now(),
                    );
                    if (date != null) setState(() => selectedDate = date);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    selectedTime == null
                        ? "Choose Time"
                        : selectedTime!.format(context),
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) setState(() => selectedTime = time);
                  },
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentYellow,
                    foregroundColor: Colors.black87,
                  ),
                  onPressed: isSaving ? null : bookAppointment,
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Confirm Appointment"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
