import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final nameController = TextEditingController();
  final speciesController = TextEditingController();
  final ageController = TextEditingController();
  final notesController = TextEditingController();

  bool isSaving = false;

  Future<void> savePet() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      isSaving = true;
    });

    final petData = {
      'name': nameController.text.trim(),
      'species': speciesController.text.trim(),
      'age': int.tryParse(ageController.text.trim()) ?? 0,
      'notes': notesController.text.trim(),
      'createdAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('owners')
        .doc(user.uid)
        .collection('pets')
        .add(petData);

    setState(() {
      isSaving = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Pet"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Pet Name'),
            ),
            TextField(
              controller: speciesController,
              decoration: const InputDecoration(labelText: 'Species (Dog, Cat, etc.)'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age (years)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes / Vaccination info'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSaving ? null : savePet,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Pet"),
            ),
          ],
        ),
      ),
    );
  }
}
