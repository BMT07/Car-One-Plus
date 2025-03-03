import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'car_details_screen.dart';
import 'notifications_screen.dart';
import 'search_screen.dart';
import '../providers/user_provider.dart';
import '../providers/vehicle_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userPrenom = "";
  String userNom = "";

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).loadUserData();
    Provider.of<VehicleProvider>(context, listen: false).updateVehicles();
    Provider.of<VehicleProvider>(context, listen: false).loadVehicles();
  }

  /*Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userPrenom = prefs.getString('user_prenom') ?? "Utilisateur";
      userNom = prefs.getString('user_nom') ?? "";
    });
  }*/

  //final List<String> carBrands = ['BMW', 'Tesla', 'Mercedes', 'Toyota', 'Audi', 'Ford'];
  final List<Map<String, String>> carList = [
    {"name": "Mini Cooper", "range": "249 km", "price": "\$72/heure", "image": "assets/images/ferrari.png"},
    {"name": "Tesla Model 3", "range": "340 km", "price": "\$60/heure", "image": "assets/images/ferrari.png"},
    {"name": "BMW Série 5", "range": "500 km", "price": "\$90/heure", "image": "assets/images/ferrari.png"},
    {"name": "Mercedes Classe A", "range": "450 km", "price": "\$85/heure", "image": "assets/images/ferrari.png"},
    /*{"name": "Audi A4", "range": "320 km", "price": "\$75", "image": "assets/images/ferrari.png"},
    {"name": "Ford Mustang", "range": "280 km", "price": "\$95", "image": "assets/images/ferrari.png"},
    {"name": "Porsche Cayenne", "range": "520 km", "price": "\$110", "image": "assets/images/ferrari.png"},
    {"name": "Honda Civic", "range": "300 km", "price": "\$65", "image": "assets/images/ferrari.png"},
    {"name": "Toyota Camry", "range": "350 km", "price": "\$70", "image": "assets/images/ferrari.png"},
    {"name": "Nissan Altima", "range": "330 km", "price": "\$68", "image": "assets/images/ferrari.png"},*/
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context); // ⬅️ listen: true par défaut
    final vehicleProvider = Provider.of<VehicleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade50,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bonjour,', style: TextStyle(fontSize: 16, color: Colors.black)),
            Text('${userProvider.userPrenom} ${userProvider.userNom} 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsScreen())),
            child: CircleAvatar(backgroundColor: Colors.grey.shade200, child: Icon(Icons.notifications, color: Colors.black)),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  readOnly: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen())),
                  decoration: InputDecoration(
                    hintText: 'Rechercher ici',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            //SizedBox(height: 20),
            SectionHeader(title: 'La liste des voitures disponibles'),
            SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(vertical: 10), // Ajoute un peu d'espace
                itemCount: vehicleProvider.vehicles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // ✅ 2 voitures par ligne
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.70, // ✅ Ajuste la hauteur des cartes
                ),
                itemBuilder: (context, index){
                  final vehicle = vehicleProvider.vehicles[index];
                  return VehicleCard(vehicle: vehicle);},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }
}


class VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  const VehicleCard({Key? key, required this.vehicle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Vérifier si "images" existe, est une liste et contient au moins une image
    String? imageUrl;
    if (vehicle["images"] is List && (vehicle["images"] as List).isNotEmpty) {
      imageUrl = vehicle["images"][0];
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailsScreen(vehicle: vehicle),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Vérifier si l'image existe et afficher une image par défaut sinon
            Expanded(
              child: imageUrl != null
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset("assets/images/ferrari.png", fit: BoxFit.cover);
                },
              )
                  : Image.asset("assets/images/ferrari.png", fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),

            // ✅ Utilisation des bons champs depuis `vehicle`
            Text(
              vehicle['title'] ?? "Titre inconnu",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              '${vehicle['type_de_vehicule'] ?? "Type inconnu"} • ${vehicle['price_per_day'] ?? "N/A"} €/jour',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            Text(
              "Localisation : ${vehicle['localisation'] ?? "Inconnue"}",
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
