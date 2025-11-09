import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName ?? 'Pet Lover';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text(
          'PetPoint 🐾',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, $name 👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              'Welcome to PetPoint — your pet care hub.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),

            // 🟦 Quick Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/pets'),
                    icon: const Icon(Icons.pets),
                    label: const Text('My Pets'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/doctors'),
                    icon: const Icon(Icons.medical_services),
                    label: const Text('Doctors'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentYellow,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🟩 Add Pet Button
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/add-pet'),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Pet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
            ),

            const SizedBox(height: 18),

            // 🟪 Section: Upcoming Appointments
            Text(
              'Upcoming Appointments',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade900,
                  ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('appointments')
                    .where('ownerId', isEqualTo: user?.uid)
                    .orderBy('appointmentDate', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red)));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final appointments = snapshot.data?.docs ?? [];

                  if (appointments.isEmpty) {
                    return Center(
                      child: Text(
                        'No upcoming appointments — book one to see it here!',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: appointments.length,
                    separatorBuilder: (context, _) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final data =
                          appointments[index].data() as Map<String, dynamic>;
                      final doctorName = data['doctorName'] ?? 'Unknown';
                      final petName = data['petName'] ?? 'Pet';
                      final Timestamp dateTimeStamp =
                          data['appointmentDate'] ?? Timestamp.now();
                      final appointmentDate = dateTimeStamp.toDate();

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            '$petName with $doctorName',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${appointmentDate.day}-${appointmentDate.month}-${appointmentDate.year} '
                            '${appointmentDate.hour}:${appointmentDate.minute.toString().padLeft(2, '0')}',
                          ),
                          trailing: Chip(
                            label: Text(
                              (data['status'] ?? 'Pending').toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor:
                                data['status'] == 'Approved'
                                    ? Colors.green
                                    : (data['status'] == 'Rejected'
                                        ? Colors.red
                                        : Colors.orange),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // 🟨 View All Appointments Button
            Center(
              child: TextButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/my-appointments'),
                icon: const Icon(Icons.event_note),
                label: const Text('View All Appointments'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
