import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'modify_profile_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart'; // Assure-toi que c'est bien importé

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService apiService = ApiService();
  /*bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? userProfile;
  String? profileImageUrl;*/

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).loadUserData();
  }

  // 🚀 CHARGER LES DONNÉES UTILISATEUR
  /*Future<void> _loadUserProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await apiService.getProfile();
    // ✅ Charger l'image de profil depuis SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = false;
      if (response.containsKey("error")) {
        setState(() {
          isLoading = false;
          errorMessage = response["error"];
        });
      } else {
        userProfile = response;

        profileImageUrl = prefs.getString('user_photo') ?? response["photo_url"];
      }
    });
  }*/

  // 📤 UPLOAD D'UNE NOUVELLE PHOTO
  /*Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return; // Annulé

    File imageFile = File(pickedFile.path);

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await apiService.uploadPhoto(imageFile);

    if (response.containsKey("error")) {
      setState(() {
        isLoading = false;
        errorMessage = response["error"];
      });
    } else {
      final newProfileImageUrl = response["file_path"]; // ✅ Nouvelle URL d'image

      // ✅ Sauvegarde dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_photo', newProfileImageUrl);

      setState(() {
        isLoading = false;
        profileImageUrl = newProfileImageUrl;
      });

      Navigator.pop(context, true); // ✅ Signaler la mise à jour
    }
  }*/

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final userProvider = Provider.of<UserProvider>(context); // ⬅️ listen: true par défaut

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Mon profil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              if (!userProvider.isLoading) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModifyProfileScreen(
                    /*userProfile: {
                    "prenom": userProvider.userPrenom,
                    "nom": userProvider.userNom,
                    "email": userProvider.userEmail,
                    "role": userProvider.userRole,
                    "telephone": userProvider.userTelephone,
                  }*/)),
                ).then((value) {
                  if (value == true) {
                    userProvider.updateUserData(); // ✅ Mettre à jour après modification
                  }
                });
              }else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Chargement du profil..."))
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 📸 PHOTO DE PROFIL AVEC UPLOAD
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: userProvider.userPhoto.startsWith("http")
                          ? NetworkImage(userProvider.userPhoto) // ✅ Chargement correct de l'image
                          : AssetImage(userProvider.userPhoto) as ImageProvider,
                    ),
                    /*Positioned(
                      bottom: 0,
                      right: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          onPressed: _uploadPhoto,
                        ),
                      ),
                    ),*/
                  ],
                ),
              ),

              const SizedBox(height: 30),

              if (userProvider.isLoading) Center(child: CircularProgressIndicator()),

              /*if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),*/

              // ✅ AFFICHAGE DES INFORMATIONS UTILISATEUR
              if (!userProvider.isLoading) ...[
                ProfileInfoCard(
                  icon: Icons.person,
                  label: 'Nom & Prénom',
                    value: "${userProvider.userNom} ${userProvider.userPrenom}",
                ),
                ProfileInfoCard(
                  icon: Icons.email,
                  label: 'Adresse email',
                  value: userProvider.userEmail,
                ),
                ProfileInfoCard(
                  icon: Icons.phone,
                  label: 'Numéro de téléphone',
                  value: userProvider.userTelephone,
                ),
                ProfileInfoCard(
                  icon: Icons.star,
                  label: 'Rôle',
                  value: userProvider.userRole.toUpperCase(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// 📌 Carte d'information utilisateur
class ProfileInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ProfileInfoCard({Key? key, required this.label, required this.value, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(value, style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
