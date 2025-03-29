import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_screen.dart';
import 'edit_vehicule_screen.dart';
import 'main_screen.dart';
import 'settings_screen.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../providers/user_provider.dart';
import 'reservation_owner_screen.dart';
import 'review_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Animation pour l'apparition des éléments
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Chargement des données utilisateur
    Provider.of<UserProvider>(context, listen: false).loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _logout(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Animation de sortie
    await _animationController.reverse();

    await _apiService.logout();
    await userProvider.clearUserData();

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Déconnexion',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Êtes-vous sûr de vouloir vous déconnecter ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Annuler', style: TextStyle(color: Colors.black87, fontSize: 16)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _logout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text('Déconnecter', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
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
    final userProvider = Provider.of<UserProvider>(context);
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return WillPopScope(
      onWillPop: () async {
        // Rediriger vers HomeScreen (onglet 0) au lieu du comportement par défaut
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(initialIndex: 0),
          ),
        );
        return false; // Empêche le retour natif
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.1),
              end: Offset.zero,
            ).animate(_animation),
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                // App Bar avec avatar et informations
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 40,
                        bottom: 30,
                        left: 20,
                        right: 20
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Hero(
                          tag: 'profileAvatar',
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditProfileScreen()),
                              ).then((value) {
                                if (value == true) {
                                  userProvider.loadUserData();
                                }
                              }),
                              customBorder: CircleBorder(),
                              child: Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Colors.red.shade400, Colors.red.shade700],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 47,
                                    backgroundImage: userProvider.userPhoto.startsWith("http")
                                        ? NetworkImage(userProvider.userPhoto)
                                        : AssetImage(userProvider.userPhoto) as ImageProvider,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '${userProvider.userPrenom} ${userProvider.userNom}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          userProvider.userEmail,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            userProvider.userRole.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Titre des options
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 10),
                    child: Text(
                      'Options du compte',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                // Liste des options
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildOption(
                      context,
                      icon: Icons.person,
                      label: 'Mon profil',
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => EditProfileScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                        ),
                      ).then((value) {
                        if (value == true) {
                          userProvider.loadUserData();
                        }
                      }),
                    ),
                    /*_buildOption(
                      context,
                      icon: Icons.privacy_tip,
                      label: 'Politique de confidentialité',
                      onTap: () => print('Politique de confidentialité'),
                    ),*/
                    _buildOption(
                      context,
                      icon: Icons.info,
                      label: 'À propos de nous',
                      onTap: () => print('À propos de nous'),
                    ),
                    if (userProvider.userRole != "locateur")
                      _buildOption(
                        context,
                        icon: Icons.car_rental,
                        label: 'Gestion des véhicules',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditVehicleScreen()),
                        ),
                      ),
                    if (userProvider.userRole != "locateur")
                      _buildOption(
                        context,
                        icon: Icons.book_online,
                        label: 'Gestion des Réservations',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReservationOwnerScreen()),
                        ),
                      ),
                    if (userProvider.userRole != "locateur")
                      _buildOption(
                        context,
                        icon: Icons.star_rate_rounded,
                        label: 'Voir mes avis',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserReviewsScreen(
                            userId: userProvider.userId,),
                          ),
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
                      icon: Icons.logout_rounded,
                      label: 'Se déconnecter',
                      onTap: () => _showLogoutDialog(context),
                      isDestructive: true,
                    ),
                    // Espace en bas pour éviter que le dernier élément soit caché
                    SizedBox(height: 30),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildOption(BuildContext context,
      {required IconData icon,
        required String label,
        required VoidCallback onTap,
        bool isDestructive = false}) {

    final color = isDestructive ? Colors.red : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.red.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDestructive
                          ? Colors.red.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isDestructive ? Colors.red : Colors.red.shade700,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: isDestructive ? Colors.red.withOpacity(0.5) : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}