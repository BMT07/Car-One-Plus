import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'modify_profile_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Ajouter un léger délai pour montrer l'animation
    Future.delayed(Duration.zero, () {
      Provider.of<UserProvider>(context, listen: false).loadUserData();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Calcul des valeurs responsives
    final paddingValue = size.width * 0.05;  // 5% de la largeur de l'écran

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.red.shade900 : Colors.red.shade600,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mon profil',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.edit, color: isDarkMode ? Colors.white : Colors.black),
              ),
              onPressed: () {
                if (!userProvider.isLoading) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ModifyProfileScreen()),
                  ).then((value) {
                    if (value == true) {
                      userProvider.updateUserData();
                    }
                  });
                } else {
                  _showSnackBar("Chargement du profil...");
                }
              },
            ),
          ),
        ],
      ),
      body: userProvider.isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec photo de profil - Auto-hauteur au lieu de fixed height
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode
                      ? [Colors.red.shade800, Colors.red.shade900]
                      : [Colors.red.shade400, Colors.red.shade600],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    // Photo de profil avec taille responsive
                    Hero(
                      tag: 'profileImage',
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: size.width < 360 ? 40 : (size.width < 600 ? 50 : 55),
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _getProfileImage(userProvider.userPhoto),
                          onBackgroundImageError: (exception, stackTrace) {
                            // Gestion silencieuse des erreurs d'image
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    // Nom de l'utilisateur avec contrainte de largeur
                    Container(
                      constraints: BoxConstraints(maxWidth: size.width * 0.8),
                      child: Text(
                        "${userProvider.userPrenom} ${userProvider.userNom}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Conteneur de rôle avec largeur limitée
                    Container(
                      constraints: BoxConstraints(maxWidth: size.width * 0.7),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        userProvider.userRole.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Informations utilisateur avec padding responsive
            Padding(
              padding: EdgeInsets.all(paddingValue),
              child: Column(
                children: [
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
                  SizedBox(height: paddingValue),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(paddingValue),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: paddingValue * 0.75),
                        _actionButton(
                          icon: Icons.edit_document,
                          label: 'Modifier mon profil',
                          onTap: () {
                            if (!userProvider.isLoading) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ModifyProfileScreen()),
                              ).then((value) {
                                if (value == true) {
                                  userProvider.updateUserData();
                                }
                              });
                            } else {
                              _showSnackBar("Chargement du profil...");
                            }
                          },
                        ),
                        Divider(),
                        _actionButton(
                          icon: Icons.sync,
                          label: 'Actualiser mes informations',
                          onTap: () {
                            userProvider.loadUserData();
                            _showSnackBar("Actualisation du profil...");
                          },
                        ),
                        Divider(),
                        _actionButton(
                          icon: Icons.format_paint,
                          label: 'Changer le thème',
                          onTap: () {
                            // Ici vous pourriez ajouter un gestionnaire de thème
                            _showSnackBar("Fonctionnalité à implémenter");
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour gérer correctement l'image de profil
  ImageProvider _getProfileImage(String photoUrl) {
    if (photoUrl.isEmpty) {
      return AssetImage('assets/images/default_profile.png');
    } else if (photoUrl.startsWith("http")) {
      try {
        return NetworkImage(photoUrl);
      } catch (e) {
        return AssetImage('assets/images/default_profile.png');
      }
    } else {
      return AssetImage(photoUrl);
    }
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.red, size: 20),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// 📌 Carte d'information utilisateur améliorée
class ProfileInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ProfileInfoCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final cardPadding = size.width < 360 ? 12.0 : 20.0;

    return Padding(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(size.width < 360 ? 8 : 12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Colors.red, size: size.width < 360 ? 20 : 24),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      label,
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: size.width < 360 ? 12 : 14,
                          fontWeight: FontWeight.bold
                      )
                  ),
                  SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: size.width < 360 ? 14 : 16,
                        fontWeight: FontWeight.w500
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}