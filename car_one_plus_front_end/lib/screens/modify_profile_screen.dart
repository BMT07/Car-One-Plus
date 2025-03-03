import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';

class ModifyProfileScreen extends StatefulWidget {
  /*final Map<String, dynamic> userProfile; // ✅ Réception des données utilisateur

  ModifyProfileScreen({required this.userProfile});*/

  @override
  _ModifyProfileScreenState createState() => _ModifyProfileScreenState();
}

class _ModifyProfileScreenState extends State<ModifyProfileScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedRole = "locateur";
  String? profileImageUrl;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // ✅ Initialiser les champs avec les valeurs actuelles
    _prenomController.text = userProvider.userPrenom;
    _nomController.text = userProvider.userNom;
    _emailController.text = userProvider.userEmail;
    _phoneController.text = userProvider.userTelephone;
    _selectedRole = userProvider.userRole;
    profileImageUrl = userProvider.userPhoto;
  }

  /* 📤 Fonction pour mettre à jour la photo de profil
  Future<void> _updatePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await apiService.uploadPhoto(imageFile);

    setState(() {
      isLoading = false;
      if (response.containsKey("error")) {
        errorMessage = response["error"];
      } else {
        profileImageUrl = response["file_path"]; // ✅ Mettre à jour l'image de profil
      }
    });
  }*/
  // 📤 Fonction pour mettre à jour la photo de profil
  Future<void> _updatePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await apiService.uploadPhoto(imageFile);

    if (response.containsKey("error")) {
      setState(() {
        errorMessage = response["error"];
        isLoading = false;
      });
    } else {
      profileImageUrl = response["file_path"];

      // ✅ Mettre à jour le Provider avec la nouvelle photo
      Provider.of<UserProvider>(context, listen: false).updateUserData();

      setState(() {
        isLoading = false;
      });
    }
  }

  /* ✅ Fonction pour sauvegarder les modifications
  Future<void> _updateProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final updatedData = {
      "prenom": _prenomController.text.trim(),
      "nom": _nomController.text.trim(),
      "email": _emailController.text.trim(),
      "telephone": _phoneController.text.trim(),
      "role": _selectedRole
    };

    final response = await apiService.updateProfile(updatedData);

    setState(() {
      isLoading = false;
      if (response.containsKey("error")) {
        errorMessage = response["error"];
      } else {
        Navigator.pop(context, true); // ✅ Retourner avec succès
      }
    });
  }*/
  // ✅ Fonction pour sauvegarder les modifications
  Future<void> _updateProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final updatedData = {
      "prenom": _prenomController.text.trim(),
      "nom": _nomController.text.trim(),
      "email": _emailController.text.trim(),
      "telephone": _phoneController.text.trim(),
      "role": _selectedRole
    };

    final response = await apiService.updateProfile(updatedData);

    if (response.containsKey("error")) {
      setState(() {
        errorMessage = response["error"];
        isLoading = false;
      });
    } else {
      // ✅ Mettre à jour le Provider avec les nouvelles infos
      Provider.of<UserProvider>(context, listen: false).updateUserData();

      setState(() {
        isLoading = false;
      });

      Navigator.pop(context, true); // ✅ Retour avec succès
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Modifier le profil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userProvider.userPhoto != "assets/images/logo.png"
                        ? NetworkImage(userProvider.userPhoto)
                        : AssetImage('assets/images/logo.png') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        onPressed: _updatePhoto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // ✅ Champ Prénom
            TextField(
              controller: _prenomController,
              decoration: InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // ✅ Champ Nom
            TextField(
              controller: _nomController,
              decoration: InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // ✅ Champ Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Adresse email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // ✅ Champ Numéro de téléphone
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // ✅ Sélection du rôle avec DropdownButton
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Rôle',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: "proprietaire", child: Text("Propriétaire")),
                DropdownMenuItem(value: "locateur", child: Text("Locateur")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            SizedBox(height: 32),

            // ✅ Bouton de sauvegarde
            ElevatedButton(
              onPressed: isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Sauvegarder', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),

            // ✅ Message d'erreur
            if (errorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
