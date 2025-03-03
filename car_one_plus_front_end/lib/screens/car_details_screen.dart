import 'package:flutter/material.dart';
import 'car_reservation_screen.dart';

class CarDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const CarDetailsScreen({Key? key, required this.vehicle}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String? imageUrl;
    if (vehicle["images"] is List && (vehicle["images"] as List).isNotEmpty) {
      imageUrl = vehicle["images"][0];
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de la voiture
            Center(
              child: imageUrl != null
                  ? Image.network(
                imageUrl,
                width: MediaQuery.of(context).size.width * 0.9, // 90% de la largeur de l'écran
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset("assets/images/ferrari.png", fit: BoxFit.cover);
                },
              )
                  : Image.asset(
                  "assets/images/ferrari.png",
                  width: MediaQuery.of(context).size.width * 0.9, // 90% de la largeur de l'écran
                  height: 200,
                  fit: BoxFit.cover
              ),
            ),
            const SizedBox(height: 16),

            // Nom de la voiture et prix
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    vehicle["title"] ?? 'Nom indisponible', // Nom dynamique
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Empêche le dépassement
                  ),
                ),
                Text(
                  '${vehicle["price_per_day"] ?? 'Prix indisponible'} €/jour', // Prix dynamique
                    style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red,
                    ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              vehicle["localisation"], // Remplacez par une valeur dynamique si nécessaire
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Section Caractéristiques
            Text(
              'Caractéristiques',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRow(label: 'Type de vehicule', value:vehicle["type_de_vehicule"]),
                      InfoRow(label: 'Transmission', value: vehicle["transmission"]),
                      InfoRow(label: 'Puissance', value: vehicle["puissance"]),
                    ],
                  ),
                ),
                Flexible(
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRow(label: 'Type de Carburant', value:vehicle["type_de_carburant"]),
                      InfoRow(label: 'Vitesse de', value: vehicle["vitesse"]),
                      InfoRow(label: 'nombre de sièges', value: '${vehicle["nbreSieges"]}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // À propos de la voiture
            Text(
              'À propos de la voiture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              vehicle["description"],
              maxLines: 5,
              overflow: TextOverflow.ellipsis, // Empêche le dépassement
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Action pour discuter avec le vendeur
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Discuter avec le vendeur',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Action pour louer la voiture
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarReservationScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Louer maintenant',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label : ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis, // Empêche le dépassement
            ),
          ),
        ],
      ),
    );
  }
}
