import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class AddPetPage extends StatefulWidget {
  final String? editPetId;
  const AddPetPage({super.key, this.editPetId});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _photoUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editPetId != null) {
      _loadPetData();
    }
  }

  Future<void> _loadPetData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('owners')
        .doc(user.uid)
        .collection('pets')
        .doc(widget.editPetId)
        .get();

    final data = doc.data();
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _speciesController.text = data['species'] ?? '';
      _ageController.text = data['age']?.toString() ?? '';
      _photoUrl = data['photoUrl'];
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  if (picked != null) {
    setState(() => _loading = true);
    try {
      // Normally, you'd upload to Firebase Storage here.
      // For free-tier users, we'll just use a placeholder.
      _photoUrl = 'toypoodle.jpg';
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image selection failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }
}


  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final petsRef = FirebaseFirestore.instance
        .collection('owners')
        .doc(user.uid)
        .collection('pets');

    final data = {
      'name': _nameController.text.trim(),
      'species': _speciesController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'photoUrl': _photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.editPetId == null) {
        await petsRef.add(data);
      } else {
        await petsRef.doc(widget.editPetId).update(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editPetId == null ? 'Add Pet' : 'Edit Pet'),
        backgroundColor: AppColors.pastelBlue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                        child: _photoUrl == null
                            ? const Icon(Icons.add_a_photo, size: 40)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _speciesController,
                      decoration: const InputDecoration(
                        labelText: 'Species *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Species is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age (years) *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Age is required' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save Pet'),
                      onPressed: _savePet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pastelBlue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
