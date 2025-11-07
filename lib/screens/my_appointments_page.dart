import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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

    print("Fetching appointments for UID: ${user.uid}");

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments"),
        backgroundColor: Colors.teal,
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
          print("Found ${docs.length} appointments for UID: ${user.uid}");

          if (docs.isEmpty) return const Center(child: Text("No appointments found."));

          return ListView(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final petName = data['petName'] ?? 'Unknown Pet';
              final doctorName = data['doctorName'] ?? 'Unknown Doctor';
              final appointmentType = data['type'] ?? 'Unknown Type';

              final Timestamp ts = data['appointmentDate'] as Timestamp;
              final date = ts.toDate();
              final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.teal),
                  title: Text("$petName - $doctorName"),
                  subtitle: Text("$appointmentType • $formattedDate"),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
