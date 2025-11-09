import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';

class PetProfilePage extends StatefulWidget {
  final String petId;

  const PetProfilePage({super.key, required this.petId});

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _ageController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isEditing = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('owners')
        .doc(user.uid)
        .collection('pets')
        .doc(widget.petId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _speciesController.text = data['species'] ?? '';
      _ageController.text = data['age']?.toString() ?? '';
      _photoUrl = data['photoUrl'];
      setState(() {});
    }
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;
    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('owners')
        .doc(user.uid)
        .collection('pets')
        .doc(widget.petId)
        .update({
      'name': _nameController.text.trim(),
      'species': _speciesController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'photoUrl': _photoUrl,
    });

    setState(() => _isEditing = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child('pet_images')
        .child(user.uid)
        .child('${widget.petId}.jpg');

    await ref.putFile(File(picked.path));
    final url = await ref.getDownloadURL();

    setState(() => _photoUrl = url);

    await FirebaseFirestore.instance
        .collection('owners')
        .doc(user.uid)
        .collection('pets')
        .doc(widget.petId)
        .update({'photoUrl': url});
  }

  Future<void> _deletePet() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('owners')
        .doc(user.uid)
        .collection('pets')
        .doc(widget.petId)
        .delete();

    Navigator.pop(context);
  }

  void _addMedicalRecord() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Medical Record'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter medical details'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('owners')
                    .doc(user.uid)
                    .collection('pets')
                    .doc(widget.petId)
                    .collection('medicalHistory')
                    .add({
                  'record': controller.text.trim(),
                  'timestamp': Timestamp.now(),
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadReport() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child('pet_reports')
        .child(user.uid)
        .child('${widget.petId}_${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(File(picked.path));
    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('owners')
        .doc(user.uid)
        .collection('pets')
        .doc(widget.petId)
        .collection('reports')
        .add({'url': url, 'timestamp': Timestamp.now()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_nameController.text}'s Profile 🐾"),
        backgroundColor: AppColors.pastelBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _deletePet,
          ),
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () => setState(() {
              if (_isEditing) _savePet();
              _isEditing = !_isEditing;
            }),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isEditing ? _pickImage : null,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _photoUrl != null
                    ? NetworkImage(_photoUrl!)
                    : const AssetImage('assets/paw.png') as ImageProvider,
                child: _isEditing
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 30),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    enabled: _isEditing,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _speciesController,
                    decoration: const InputDecoration(labelText: 'Species'),
                    enabled: _isEditing,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Age'),
                    enabled: _isEditing,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Medical History',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton.icon(
                  onPressed: _addMedicalRecord,
                  icon: const Icon(Icons.add, color: AppColors.primaryPurple),
                  label: const Text('Add Record'),
                ),
              ],
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('owners')
                  .doc(_auth.currentUser!.uid)
                  .collection('pets')
                  .doc(widget.petId)
                  .collection('medicalHistory')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final records = snapshot.data!.docs;
                if (records.isEmpty) {
                  return const Text('No records yet.');
                }
                return Column(
                  children: records
                      .map((doc) => ListTile(
                            title: Text(doc['record']),
                            subtitle: Text(doc['timestamp']
                                .toDate()
                                .toString()
                                .substring(0, 16)),
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Reports / Certificates',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton.icon(
                  onPressed: _uploadReport,
                  icon: const Icon(Icons.upload_file,
                      color: AppColors.primaryPurple),
                  label: const Text('Upload Report'),
                ),
              ],
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('owners')
                  .doc(_auth.currentUser!.uid)
                  .collection('pets')
                  .doc(widget.petId)
                  .collection('reports')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final reports = snapshot.data!.docs;
                if (reports.isEmpty) {
                  return const Text('No reports uploaded yet.');
                }
                return Column(
                  children: reports
                      .map((doc) => ListTile(
                            leading: const Icon(Icons.picture_as_pdf,
                                color: AppColors.primaryPurple),
                            title: Text("Report Uploaded"),
                            subtitle: Text(doc['timestamp']
                                .toDate()
                                .toString()
                                .substring(0, 16)),
                            onTap: () async {
                              final url = doc['url'];
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("URL: $url")),
                              );
                            },
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
