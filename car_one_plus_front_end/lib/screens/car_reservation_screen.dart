import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reservation_provider.dart';
import '../services/api_service_reservation.dart';
import '../services/api_service.dart';
import 'stripe_payment_screen.dart';

class CarReservationScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle;

  const CarReservationScreen({Key? key, required this.vehicle}) : super(key: key);

  @override
  _CarReservationScreenState createState() => _CarReservationScreenState();
}

class _CarReservationScreenState extends State<CarReservationScreen> {
  DateTime? startDate;
  DateTime? endDate;

  final ApiService apiService = ApiService();
  late Map<String, dynamic> reservation;




  // Fonction pour ouvrir le sélecteur de date
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now;
    final DateTime lastDate = now.add(Duration(days: 365)); // Location possible jusqu'à 1 an

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  // ✅ Fonction pour réserver un véhicule
  Future<void> _reserveVehicleInPending(BuildContext context) async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une période de location.')),
      );
      return;
    }

    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
    final vehicleId = widget.vehicle["id"];

    final response = await reservationProvider.addReservation(
      vehicleId,
      startDate!.toIso8601String(),
      endDate!.toIso8601String(),
    );

    if (!response.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation effectuée avec succès !')),
      );
      //Navigator.pop(context); // Fermer l'écran après succès
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${response["error"]}')),
      );
    }
  }

  // ✅ Fonction pour réserver un véhicule
  Future<void> _reserveVehicleWithConfirmation(BuildContext context) async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une période de location.')),
      );
      return;
    }

    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
    final vehicleId = widget.vehicle["id"];

    final response = await reservationProvider.addReservation(
      vehicleId,
      startDate!.toIso8601String(),
      endDate!.toIso8601String(),
    );

    print(response);

    reservation = response["reservation"]["reservation"];
    final token = await apiService.getToken();
    print(token);

    print(reservation);
    if (!response.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation effectuée avec succès !')),
      );
      if (reservation.containsKey("id")) {
        print(reservation);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReservationDetailScreen(
              reservationId: reservation["id"],
              amount: widget.vehicle["price_per_day"],
              vehicleTitle: widget.vehicle["title"],
              vehicleDescription: widget.vehicle["description"],
              //token: token,
            ),
          ),
        );
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${reservation["id"]},${widget.vehicle["price_per_day"]}')),
        );
      }
      //Navigator.pop(context); // Fermer l'écran après succès
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${response["error"]}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Réservation de ${vehicle["title"] ?? 'véhicule'}",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du véhicule
            Center(
              child: vehicle["images"] != null && vehicle["images"].isNotEmpty
                  ? Image.network(
                vehicle["images"][0],
                width: MediaQuery.of(context).size.width * 0.9,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset("assets/images/ferrari.png", fit: BoxFit.cover);
                },
              )
                  : Image.asset("assets/images/ferrari.png",
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 200,
                  fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),

            // Détails du véhicule
            Text(
              vehicle["title"] ?? 'Nom indisponible',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Prix: ${vehicle["price_per_day"] ?? 'Prix indisponible'} €/jour',
                style: TextStyle(fontWeight: FontWeight.bold)
            ),

            const SizedBox(height: 8),
            Text(
              'Localisation : ${vehicle["localisation"] ?? "Non précisé"}',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Sélection des dates
            Text(
              'Choisir la période de location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            InkWell(
              onTap: () => _selectDateRange(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      startDate != null && endDate != null
                          ? '${startDate!.day}/${startDate!.month}/${startDate!.year} - ${endDate!.day}/${endDate!.month}/${endDate!.year}'
                          : 'Sélectionner les dates',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Boutons de réservation
            Row(
              children: [
                // Bouton "Réserver en attente"
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async{
                      await _reserveVehicleInPending(context);
                      print("Bouton 'Réserver en attente' appuyé !");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Couleur pour une réservation en attente
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Réserver en attente',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Bouton "Confirmer et payer"
                Expanded(
                  child: ElevatedButton(
                    onPressed: (){
                      // Action pour "Confirmer et payer"
                      _reserveVehicleWithConfirmation(context);
                      print("Bouton 'Confirmer et payer' appuyé !");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Couleur pour une réservation confirmée
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Confirmer et payer',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),

            /* Bouton de validation
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (startDate == null || endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Veuillez sélectionner une période de location.')),
                    );
                    return;
                  }

                  // Envoyer la réservation avec les données du véhicule
                  print("Réservation confirmée pour ${vehicle["title"]} du $startDate au $endDate");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Réservation confirmée !')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Confirmer la réservation',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
