import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/reservation_provider.dart';
import 'stripe_payment_screen.dart';
import 'review_screen.dart';

class ReservationDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> reservation;

  const ReservationDetailsScreen({Key? key, required this.reservation}) : super(key: key);

  @override
  _ReservationDetailsScreenState createState() => _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  late Map<String, dynamic> vehicle;
  bool isLoading = true;
  final DateFormat formatter = DateFormat('dd MMM yyyy');

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
      isLoading = true;
    });

    try {
      final response = await vehicleProvider.getVehicleById(vehicleId);
      if (mounted) {
        setState(() {
          if (response != null && response.containsKey("vehicle")) {
            vehicle = response["vehicle"];
          }
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération du véhicule: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _deleteReservation() async {
    setState(() => isLoading = true);
    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);

    try {
      final response = await reservationProvider.deleteReservationByOwner(widget.reservation["id"]);
      setState(() => isLoading = false);
      Navigator.pop(context); // Ferme le dialog

      if (response.containsKey("error")) {
        _showSnackBar("Erreur lors de la suppression: ${response['error']}", Colors.red);
      } else {
        _showSnackBar("Véhicule supprimé avec succès !", Colors.green);
        Navigator.pop(context); // Retourne à l'écran précédent
      }
    } catch (e) {
      setState(() => isLoading = false);
      Navigator.pop(context); // Ferme le dialog
      _showSnackBar("Une erreur est survenue: $e", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(8),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final reservation = widget.reservation;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de la réservation"),
        centerTitle: true,
        elevation: 0, // Supprime l'ombre pour un look moderne
        actions: [
          // Bouton de commentaires dans l'AppBar
          IconButton(
            icon: const Icon(Icons.comment),
            tooltip: "Voir les commentaires",
            onPressed: () {
              if (!isLoading && vehicle.containsKey("id")) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VehicleReviewsScreen(
                      vehicleId: vehicle["id"],
                      vehicleName: vehicle["title"] ?? "Véhicule",
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Impossible d'accéder aux commentaires pour le moment"),
                    backgroundColor: Colors.red[100],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Chargement des détails...", style: TextStyle(color: Colors.grey))
            ],
          ))
          : RefreshIndicator(
        onRefresh: _fetchVehicleDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenSize.height - AppBar().preferredSize.height - 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête avec statut
                  _buildStatusHeader(reservation),

                  const SizedBox(height: 16),

                  // Informations sur la réservation
                  _buildReservationDetails(reservation, vehicle),

                  const SizedBox(height: 20),

                  // Détails du véhicule
                  _buildVehicleDetails(vehicle, isSmallScreen),

                  const SizedBox(height: 20),

                  _buildContactInfo(),

                  const SizedBox(height: 30),

                  // Boutons d'action
                  _buildActionButtons(isSmallScreen),
                ],
              ),
            ),
          ),
        ),
      ),
      // Bouton flottant pour accéder aux commentaires (alternative pour plus de visibilité)
      /*floatingActionButton: !isLoading && vehicle.containsKey("id") ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleReviewsScreen(
                vehicleId: vehicle["id"],
                vehicleName: vehicle["title"] ?? "Véhicule",
              ),
            ),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.comment),
        tooltip: "Voir les avis",
      ) : null,*/
    );
  }

  Widget _buildStatusHeader(Map<String, dynamic> reservation) {
    final status = reservation["status"] ?? "INCONNU";
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(status),
            color: _getStatusColor(status),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Statut",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(status),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "Réservation #${reservation["id"]}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetails(Map<String, dynamic> reservation, Map<String, dynamic> vehicle) {
    final startDate = DateTime.parse(reservation["start_date"]);
    final endDate = DateTime.parse(reservation["end_date"]);
    final duration = endDate.difference(startDate).inDays;
    final pricePerDay = vehicle["price_per_day"] ?? 0;
    final totalAmount = duration * (pricePerDay is double ? pricePerDay : 0);
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Détails de la réservation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              "Date de début",
              formatter.format(DateTime.parse(reservation["start_date"])),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              "Date de fin",
              formatter.format(DateTime.parse(reservation["end_date"])),
            ),
            // Ajout d'autres informations si disponibles
            if (vehicle.containsKey("price_per_day"))
              Column(
                children: [
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.euro,
                    "Prix total",
                    "${totalAmount}€",
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.red),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleDetails(Map<String, dynamic> vehicle, bool isSmallScreen) {
    final hasImages = vehicle.containsKey("images") &&
        vehicle["images"] != null &&
        vehicle["images"].isNotEmpty;

    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias, // Pour s'assurer que l'image respecte le borderRadius
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du véhicule
          Stack(
            children: [
              hasImages
                  ? Hero(
                tag: "vehicle_${vehicle["id"]}",
                child: Image.network(
                  vehicle["images"][0],
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 220,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              )
                  : Container(
                height: 220,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.directions_car, size: 64, color: Colors.grey),
                ),
              ),

              // Badge prix par jour
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${vehicle["price_per_day"] ?? 'N/A'}€/jour",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Bouton de commentaires sur l'image
              Positioned(
                bottom: 16,
                right: 16,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      if (vehicle.containsKey("id")) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VehicleReviewsScreen(
                              vehicleId: vehicle["id"],
                              vehicleName: vehicle["title"] ?? "Véhicule",
                            ),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.comment, color: Colors.red, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            "Avis",
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Informations du véhicule
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        vehicle["title"] ?? "Titre non disponible",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Bouton de commentaires à côté du titre
                    IconButton(
                      icon: const Icon(Icons.comment, color: Colors.red),
                      tooltip: "Voir les avis",
                      onPressed: () {
                        if (vehicle.containsKey("id")) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VehicleReviewsScreen(
                                vehicleId: vehicle["id"],
                                vehicleName: vehicle["title"] ?? "Véhicule",
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description en texte expandable
                Text(
                  vehicle["description"] ?? "Description non disponible",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(vehicle["title"] ?? "Description"),
                        content: SingleChildScrollView(
                          child: Text(vehicle["description"] ?? "Description non disponible"),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Fermer"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text("Voir plus"),
                ),

                const Divider(),
                const SizedBox(height: 12),

                // Caractéristiques du véhicule
                _buildVehicleSpecs(vehicle, isSmallScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text("Propriétaire du véhicule"),
              subtitle: Text("Contactez le propriétaire pour plus d'informations"),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildContactButton(Icons.phone, "Appeler", () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Appel en cours...")),
                  );
                }),
                _buildContactButton(Icons.message, "Message", () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ouverture de la messagerie...")),
                  );
                }),
                _buildContactButton(Icons.email, "Email", () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ouverture de l'email...")),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(IconData icon, String label, VoidCallback onPressed) {
    return TextButton.icon(
      icon: Icon(icon, size: 16, color: Colors.red,),
      label: Text(label),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildVehicleSpecs(Map<String, dynamic> vehicle, bool isSmallScreen) {
    // Définir les spécifications à afficher
    final specs = [
      {"icon": Icons.location_on, "label": "Localisation", "value": vehicle["localisation"]},
      {"icon": Icons.local_gas_station, "label": "Carburant", "value": vehicle["type_de_carburant"]},
      // Ajoutez d'autres specs si disponibles
      if (vehicle.containsKey("nbreSieges"))
        {"icon": Icons.people, "label": "Places", "value": vehicle["nbreSieges"].toString()},
      if (vehicle.containsKey("transmission"))
        {"icon": Icons.settings, "label": "Transmission", "value": vehicle["transmission"]},
    ];

    // Créer un layout adaptatif selon la taille d'écran
    return isSmallScreen
        ? Column(
      children: specs
          .where((spec) => spec["value"] != null)
          .map((spec) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          children: [
            Icon(spec["icon"] as IconData, size: 20, color: Colors.red),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spec["label"] as String,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  spec["value"] as String? ?? "N/A",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ))
          .toList(),
    )
        : Wrap(
      spacing: 16,
      runSpacing: 16,
      children: specs
          .where((spec) => spec["value"] != null)
          .map((spec) => SizedBox(
        width: 150,
        child: Row(
          children: [
            Icon(spec["icon"] as IconData, size: 20, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spec["label"] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    spec["value"] as String? ?? "N/A",
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ))
          .toList(),
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    final reservation = widget.reservation;

    // N'afficher les boutons que pour certains statuts
    if (reservation["status"] != "EN ATTENTE") {
      return _buildBottomBar(); // Aucun bouton si ce n'est pas en attente
    }

    return isSmallScreen
        ? Column(
      children: [
        _buildPaymentButton(),
        const SizedBox(height: 12),
        _buildCancelButton(),
      ],
    )
        : Row(
      children: [
        Expanded(child: _buildCancelButton()),
        const SizedBox(width: 16),
        Expanded(child: _buildPaymentButton()),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Contact avec le propriétaire...")),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text("Contacter le propriétaire", style: TextStyle(color: Colors.black),),
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    final startDate = DateTime.parse(widget.reservation["start_date"]);
    final endDate = DateTime.parse(widget.reservation["end_date"]);
    final duration = endDate.difference(startDate).inDays+1;
    final pricePerDay = vehicle["price_per_day"] ?? 0;
    final totalAmount = duration * (pricePerDay is double ? pricePerDay : 0.0);
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReservationDetailScreen(
              reservationId: widget.reservation["id"],
              amount: totalAmount,
              vehicleTitle: vehicle["title"] ?? "Véhicule",
              vehicleDescription: vehicle["description"] ?? "Description non disponible",
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Redirection vers le paiement..."),
            backgroundColor: Colors.red[100],
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
      ),
      icon: const Icon(Icons.payment, color: Colors.white,),
      label: const Text(
        "Passer au paiement",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton.icon(
      onPressed: () {
        _showCancelConfirmationDialog();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.cancel, color: Colors.red,),
      label: const Text(
        "Annuler la réservation",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer l'annulation"),
        content: const Text(
          "Êtes-vous sûr de vouloir annuler cette réservation ? Cette action est irréversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("NON"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReservation();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Réservation annulée avec succès"),
                  backgroundColor: Colors.red[100],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("OUI, ANNULER"),
          ),
        ],
      ),
    );
  }

  // Fonctions utilitaires
  IconData _getStatusIcon(String status) {
    switch (status) {
      case "EN ATTENTE":
        return Icons.hourglass_empty;
      case "CONFIRMER":
        return Icons.check_circle;
      case "IN_PROGRESS":
        return Icons.directions_car;
      case "COMPLETED":
        return Icons.done_all;
      case "CANCELLED":
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

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

