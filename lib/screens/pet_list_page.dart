import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_pet_page.dart';

class PetListPage extends StatelessWidget {
  const PetListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to see your pets")),
      );
    }

    final petsRef = FirebaseFirestore.instance
        .collection('owners')
        .doc(user.uid)
        .collection('pets');

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pets 🐾"),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: petsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pets added yet!"));
          }

          final pets = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(pet['name'] ?? 'Unnamed'),
                  subtitle: Text("${pet['species']} • ${pet['age']} years"),
                  trailing: const Icon(Icons.pets, color: Colors.teal),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPetPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
