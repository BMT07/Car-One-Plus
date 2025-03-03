import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'reservation_screen.dart';
import 'address_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Index de la page active

  // Liste des pages
  final List<Widget> _pages = [
    HomeScreen(),         // Page d'accueil
    ReservationScreen(),  // Page des réservations
    AddressScreen(),      // Page des adresses
    ProfileScreen(),      // Page de profil (vous devez la créer si elle n'existe pas)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // Affiche la page correspondant à l'index
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Index actif
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Change l'index actif
          });
        },
        selectedItemColor: Colors.blue, // Couleur de l'élément actif
        unselectedItemColor: Colors.grey, // Couleur des éléments inactifs
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Réservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Adresses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
