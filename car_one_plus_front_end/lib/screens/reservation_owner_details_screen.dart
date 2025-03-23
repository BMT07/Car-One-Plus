import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Pour formater les dates
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import 'stripe_payment_screen.dart';

class ReservationOwnerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> reservation;

  const ReservationOwnerDetailsScreen({Key? key, required this.reservation}) : super(key: key);

  @override
  _ReservationOwnerDetailsScreenState createState() => _ReservationOwnerDetailsScreenState();
}

class _ReservationOwnerDetailsScreenState extends State<ReservationOwnerDetailsScreen> {
  late Map<String, dynamic> vehicle; // Stocke les détails du véhicule
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVehicleDetails();
  }

  Future<void> _fetchVehicleDetails() async {
    final vehicleId = widget.reservation["vehicle_id"];
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);

    setState(() {
      vehicle = {};
    });

    try {
      final response = await vehicleProvider.getVehicleById(vehicleId);
      setState(() {
        // Extraire les données du véhicule de la structure de réponse
        if (response != null && response.containsKey("vehicle")) {
          vehicle = response["vehicle"];
        }
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération du véhicule: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservation = widget.reservation;
    final DateFormat formatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de la réservation"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Affiche un loader pendant le chargement
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 📌 Informations sur la réservation
            _buildReservationDetails(reservation, formatter),

            const SizedBox(height: 20),

            // 📌 Détails du véhicule (si chargés)
            _buildVehicleDetails(vehicle), //: _buildErrorMessage(),

            const Spacer(),

            // 📌 Bouton d'annulation ou autre action
            if (reservation["status"] == "EN ATTENTE") _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  // ✅ Widget : Affichage des détails de la réservation
  Widget _buildReservationDetails(Map<String, dynamic> reservation, DateFormat formatter) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Réservation #${reservation["id"]}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Date de début : ${formatter.format(DateTime.parse(reservation["start_date"]))}"),
            Text("Date de fin : ${formatter.format(DateTime.parse(reservation["end_date"]))}"),
            Text("Statut : ${reservation["status"]}", style: TextStyle(color: _getStatusColor(reservation["status"]))),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDetails(Map<String, dynamic> vehicle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vérifier si vehicle["images"] existe et n'est pas null avant d'accéder à isNotEmpty
          (vehicle.containsKey("images") && vehicle["images"] != null && vehicle["images"].isNotEmpty)
              ? Image.network(vehicle["images"][0], height: 200, width: double.infinity, fit: BoxFit.cover)
              : const SizedBox(height: 200, child: Center(child: Text("Pas d'image disponible"))),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle["title"] ?? "Titre non disponible",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(vehicle["description"] ?? "Description non disponible"),
                const SizedBox(height: 10),
                Text("Prix par jour : ${vehicle["price_per_day"] ?? 'N/A'}€"),
                Text("Localisation : ${vehicle["localisation"] ?? 'N/A'}"),
                Text("Type de carburant : ${vehicle["type_de_carburant"] ?? 'N/A'}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Widget : Message d'erreur si le véhicule ne se charge pas
  Widget _buildErrorMessage() {
    return const Center(
      child: Text(
        "Impossible de charger les détails du véhicule.",
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  // ✅ Widget : Bouton d'annulation (si statut = "EN ATTENTE")
  Widget _buildCancelButton() {
    return ElevatedButton(
      onPressed: () {
        // Ajoute ici la logique d'annulation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Annulation en cours...")),
        );
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text("Annuler la réservation"),
    );
  }

  // ✅ Fonction : Obtenir la couleur du statut
  Color _getStatusColor(String status) {
    switch (status) {
      case "EN ATTENTE":
        return Colors.orange;
      case "CONFIRMER":
        return Colors.green;
      case "IN_PROGRESS":
        return Colors.blue;
      case "COMPLETED":
        return Colors.grey;
      case "CANCELLED":
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
