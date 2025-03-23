import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_screen.dart';
import 'edit_vehicule_screen.dart';
import 'settings_screen.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../providers/user_provider.dart';
import 'reservation_owner_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
 /* String userPrenom = "";
  String userNom = "";
  String userEmail = "";
  String userRole = "";
  String userPhoto = "assets/images/logo.png"; // ✅ Photo par défaut*/
  final ApiService _apiService = ApiService();
  //UserProvider userProvider = UserProvider();
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).loadUserData();
  }

  /*Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userPrenom = prefs.getString('user_prenom') ?? "Utilisateur";
      userNom = prefs.getString('user_nom') ?? "";
      userEmail = prefs.getString('user_email') ?? "Email inconnu";
      userRole = prefs.getString('user_role') ?? "locateur";
      userPhoto = prefs.getString('user_photo') ?? "assets/images/logo.png"; // ✅ Chargement de la photo
    });
  }*/

  void _logout(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await _apiService.logout(); // Déconnexion côté API
    await userProvider.clearUserData(); // Nettoyer les données du provider

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Êtes-vous sûr de vouloir vous déconnecter ?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Annuler', style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _logout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Se déconnecter', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context); // ⬅️ listen: true par défaut
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: userProvider.userPhoto.startsWith("http")
                          ? NetworkImage(userProvider.userPhoto) // ✅ Charge l'image depuis le serveur
                          : AssetImage(userProvider.userPhoto) as ImageProvider, // ✅ Image par défaut si absente
                    ),
                    SizedBox(height: 8),

                    Text(
                      '${userProvider.userPrenom} ${userProvider.userNom}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userProvider.userEmail,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  _buildOption(
                    context,
                    icon: Icons.person,
                    label: 'Mon profil',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfileScreen()),
                    ).then((value) {
                      if (value == true) {
                        userProvider.loadUserData(); // ✅ Rafraîchir après modification
                      }
                    }),
                  ),
                  _buildOption(
                    context,
                    icon: Icons.privacy_tip,
                    label: 'Politique de confidentialité',
                    onTap: () => print('Politique de confidentialité'),
                  ),
                  _buildOption(
                    context,
                    icon: Icons.info,
                    label: 'À propos de nous',
                    onTap: () => print('À propos de nous'),
                  ),
                  if (userProvider.userRole != "locateur") // ✅ Afficher uniquement si l'utilisateur N'EST PAS locateur
                    _buildOption(
                      context,
                      icon: Icons.car_rental,
                      label: 'Gestion des véhicules',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditVehicleScreen()),
                      ),
                    ),
                  _buildOption(
                    context,
                    icon: Icons.book_online,
                    label: 'Gestion des Réservations',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReservationOwnerScreen()),
                    ),
                  ),
                  _buildOption(
                    context,
                    icon: Icons.settings,
                    label: 'Paramètres',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    ),
                  ),
                  _buildOption(
                    context,
                    icon: Icons.logout,
                    label: 'Se déconnecter',
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Icon(icon, color: Colors.black),
            title: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
