import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_pet_page.dart';
import 'pet_profile_page.dart'; // ✅ added import
import '../widgets/fancy_card.dart';
import '../theme.dart';

class PetListPage extends StatelessWidget {
  const PetListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in to see your pets")));
    }

    final petsRef = FirebaseFirestore.instance.collection('owners').doc(user.uid).collection('pets');

    return Scaffold(
      appBar: AppBar(title: const Text("My Pets 🐾"), backgroundColor: AppColors.pastelBlue),
      body: StreamBuilder<QuerySnapshot>(
        stream: petsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.pets, size: 56, color: Colors.grey),
                SizedBox(height: 8),
                Text("No pets added yet!"),
              ]),
            );
          }

          final pets = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final petDoc = pets[index];
              final pet = petDoc.data() as Map<String, dynamic>;
              final petId = petDoc.id;

              final photo = pet['photoUrl'] ??
                  'https://www.freepik.com/free-vector/pet-logo-design-paw-vector-animal-shop-business_18246195.htm#fromView=keyword&page=2&position=23&uuid=0d0af491-e6d3-445d-b717-d345f9041b96&query=Dog+paw';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: FancyCard(
                  imageUrl: photo,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pet['name'] ?? 'Unnamed', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text("${pet['species']} • ${pet['age']} years", style: const TextStyle(color: AppColors.muted)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            // ✅ Navigate to Pet Profile page
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PetProfilePage(petId: petId),
                                ),
                              );
                            },
                            icon: const Icon(Icons.favorite_border),
                            label: const Text('Profile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pastelBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            // ✅ Navigate to Edit Pet page (reuse AddPetPage for editing)
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddPetPage(editPetId: petId),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.pastelYellow,
        foregroundColor: Colors.black87,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPetPage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
