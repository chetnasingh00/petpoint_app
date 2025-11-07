import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PetListPage extends StatefulWidget {
  const PetListPage({super.key});

  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> {
  final _petController = TextEditingController();

  Future<void> addPet() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final petName = _petController.text.trim();
    if (petName.isEmpty) return;

    final ownerDoc = FirebaseFirestore.instance.collection('owners').doc(user.uid);

    // Ensure owner doc exists
    await ownerDoc.set({'email': user.email, 'createdAt': Timestamp.now()}, SetOptions(merge: true));

    await ownerDoc.collection('pets').add({
      'name': petName,
      'createdAt': Timestamp.now(),
    });

    _petController.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pet added successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("You must log in to view pets."));

    final petsRef = FirebaseFirestore.instance.collection('owners').doc(user.uid).collection('pets');

    return Scaffold(
      appBar: AppBar(title: const Text("My Pets"), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _petController,
              decoration: InputDecoration(
                labelText: "Pet Name",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addPet,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: petsRef.orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final pets = snapshot.data!.docs;
                  if (pets.isEmpty) return const Center(child: Text("No pets added yet."));

                  return ListView(
                    children: pets.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['name'] ?? 'Unnamed Pet'),
                      );
                    }).toList(),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
