import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import 'add_vehicule_screen.dart';
import 'edit_vehicule_details_screen.dart';

class EditVehicleScreen extends StatefulWidget {
  @override
  EditVehicleScreenState createState() => EditVehicleScreenState();
}

class EditVehicleScreenState extends State<EditVehicleScreen> {

  // Liste simulée de véhicules ajoutés par l'utilisateur
  final List<Map<String, String>> vehicles = [
    {
      "name": "Toyota Corolla",
      "image": "assets/images/toyota_corolla.jpg",
      "details": "Automatique, Diesel, 5 places",
    },
    {
      "name": "Honda Civic",
      "image": "assets/images/honda_civic.jpg",
      "details": "Manuelle, Essence, 4 places",
    },
  ];


  @override
  void initState() {
    super.initState();
    Provider.of<VehicleProvider>(context, listen: false).updateVehicles();
    Provider.of<VehicleProvider>(context, listen: false).loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gerer les véhicules',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle, color: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddVehicleScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: vehicleProvider.vehicles.length,
          itemBuilder: (context, index) {
            final Map<String, dynamic> vehicle = vehicleProvider.vehicles[index];
            String? imageUrl;
            if (vehicle["images"] is List && (vehicle["images"] as List).isNotEmpty) {
              imageUrl = vehicle["images"][0];
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image du véhicule
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: SizedBox(
                        width: 100, // Fixe une largeur pour éviter le débordement
                        height: 80, // Fixe une hauteur pour éviter le débordement
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
                    ),
                    SizedBox(width: 16),
                    // Informations sur le véhicule
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle["title"]!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            vehicle["description"]!,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis, // Empêche le dépassement
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bouton d'édition
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.red),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditVehicleDetailsScreen(
                              vehicle: vehicle,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
