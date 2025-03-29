import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/reservation_provider.dart';
import 'stripe_payment_screen.dart';

class ReservationOwnerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> reservation;

  const ReservationOwnerDetailsScreen({Key? key, required this.reservation}) : super(key: key);

  @override
  State<ReservationOwnerDetailsScreen> createState() => _ReservationOwnerDetailsScreenState();
}

class _ReservationOwnerDetailsScreenState extends State<ReservationOwnerDetailsScreen> {
  late Map<String, dynamic> vehicle;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

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
      hasError = false;
    });

    try {
      final response = await vehicleProvider.getVehicleById(vehicleId);
      if (mounted) {
        setState(() {
          if (response != null && response.containsKey("vehicle")) {
            vehicle = response["vehicle"];
            isLoading = false;
          } else {
            hasError = true;
            errorMessage = "Données du véhicule non disponibles";
            isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = "Erreur lors du chargement des détails: $e";
          isLoading = false;
        });
      }
    }
  }

  void _deleteReservation() async {
    setState(() => isLoading = true);
    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);

    try {
      final response = await reservationProvider.deleteReservationByVehicleOwner(widget.reservation["id"]);
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
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    final bool isPending = reservation["status"] == "EN ATTENTE";
    final statusColor = _getStatusColor(reservation["status"]);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de la réservation"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchVehicleDetails,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: isLoading
          ? const _LoadingState()
          : RefreshIndicator(
        onRefresh: _fetchVehicleDetails,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Statut de la réservation
                  _buildStatusBanner(reservation["status"], statusColor),
                  const SizedBox(height: 16),

                  // Informations sur la réservation
                  _buildSectionHeader("Détails de la réservation", Icons.calendar_today),
                  _buildReservationDetails(reservation, formatter),
                  const SizedBox(height: 20),

                  // Détails du véhicule
                  _buildSectionHeader("Véhicule réservé", Icons.directions_car),
                  hasError ? _buildErrorMessage() : _buildVehicleDetails(vehicle),
                  const SizedBox(height: 30),

                  // Informations de contact
                  _buildSectionHeader("Contact", Icons.person),
                  _buildContactInfo(),
                  const SizedBox(height: 30),

                  // Section Paiement
                  _buildSectionHeader("Informations de paiement", Icons.payment),
                  _buildPaymentInfo(reservation),
                  const SizedBox(height: 50),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: !isLoading ? _buildBottomBar(isPending) : null,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(String status, Color statusColor) {
    final IconData statusIcon = status == "EN ATTENTE"
        ? Icons.access_time
        : status == "CONFIRMER"
        ? Icons.check_circle
        : status == "CANCELLED"
        ? Icons.cancel
        : Icons.info;

    final String statusText = status == "EN ATTENTE"
        ? "Réservation en attente de confirmation"
        : status == "CONFIRMER"
        ? "Réservation confirmée"
        : status == "CANCELLED"
        ? "Réservation annulée"
        : "Statut: $status";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetails(Map<String, dynamic> reservation, DateFormat formatter) {
    final startDate = DateTime.parse(reservation["start_date"]);
    final endDate = DateTime.parse(reservation["end_date"]);
    final duration = endDate.difference(startDate).inDays;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Réservation #${reservation["id"]}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text("$duration jours"),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDateRow(
              title: "Date de début",
              date: startDate,
              formatter: formatter,
              icon: Icons.flight_takeoff,
            ),
            const SizedBox(height: 12),
            _buildDateRow(
              title: "Date de fin",
              date: endDate,
              formatter: formatter,
              icon: Icons.flight_land,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow({
    required String title,
    required DateTime date,
    required DateFormat formatter,
    required IconData icon,})
    {
     return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          formatter.format(date),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleDetails(Map<String, dynamic> vehicle) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du véhicule avec indication de chargement
          _buildVehicleImage(vehicle),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle["title"] ?? "Titre non disponible",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),

                // Description avec possibilité d'expansion
                _buildExpandableDescription(vehicle["description"]),
                const SizedBox(height: 16),

                // Caractéristiques du véhicule en grille
                _buildVehicleFeatures(vehicle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleImage(Map<String, dynamic> vehicle) {
    final hasImages = vehicle.containsKey("images") &&
        vehicle["images"] != null &&
        vehicle["images"].isNotEmpty;

    return Stack(
      children: [
        // Image ou placeholder
        Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey.shade200,
          child: hasImages
              ? Hero(
            tag: 'vehicle_${vehicle["id"]}',
            child: Image.network(
              vehicle["images"][0],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image, size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        "Image non disponible",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          )
              : Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_car, size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  "Pas d'image disponible",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),

        // Badge de prix
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${vehicle["price_per_day"] ?? 'N/A'}€/jour",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableDescription(String? description) {
    final descText = description ?? "Description non disponible";

    return ExpandableText(
      text: descText,
      maxLines: 3,
      style: TextStyle(
        color: Colors.grey.shade700,
        height: 1.4,
      ),
    );
  }

  Widget _buildVehicleFeatures(Map<String, dynamic> vehicle) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFeatureItem(Icons.pin_drop, vehicle["localisation"] ?? 'N/A'),
        _buildFeatureItem(Icons.local_gas_station, vehicle["type_de_carburant"] ?? 'N/A'),
        if (vehicle.containsKey("vitesse"))
          _buildFeatureItem(Icons.speed, "${vehicle["vitesse"] ?? 'N/A'} km"),
        if (vehicle.containsKey("nbreSieges"))
          _buildFeatureItem(Icons.event_seat, "${vehicle["nbreSieges"] ?? 'N/A'} sièges"),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.red.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
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
              title: Text("Locateur du véhicule"),
              subtitle: Text("Contactez le locateur pour plus d'informations"),
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
      icon: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.red.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildPaymentInfo(Map<String, dynamic> reservation) {
    // Calculer le montant total à partir des dates et du prix journalier
    final startDate = DateTime.parse(reservation["start_date"]);
    final endDate = DateTime.parse(reservation["end_date"]);
    final duration = endDate.difference(startDate).inDays+1;
    final pricePerDay = vehicle["price_per_day"] ?? 0;
    final totalAmount = duration * (pricePerDay is double ? pricePerDay : 0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Prix journalier"),
                Text("${vehicle["price_per_day"] ?? 'N/A'}€"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Durée de location"),
                Text("$duration jours"),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Montant total",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "$totalAmount€",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (reservation["status"] == "CONFIRMER")
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Paiement effectué",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildErrorMessage() {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade400,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _fetchVehicleDetails,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text("Réessayer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isPending) {

    // Récupérer la date de fin de réservation
    final endDate = DateTime.parse(widget.reservation["end_date"]);
    // Vérifier si la date de fin est passée
    final isReservationEnded = DateTime.now().isAfter(endDate);

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
        child: isPending
            ? Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _showCancelDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Annuler la réservation"),
              ),
            ),

          ],
        ) : Row(
          children: [
            // Afficher le bouton d'annulation uniquement si la date de fin est passée
            if (isReservationEnded)
              Expanded(
                child: OutlinedButton(
                  onPressed: _showCancelDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                 child: const Text("Annuler la réservation"),
                ),
              ),
            // Ajouter un espace uniquement si le bouton d'annulation est affiché
            if (isReservationEnded)
              const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Contact avec le locateur...")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Contacter le locateur"),
              ),
            ),
          ],
        )

      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Annuler la réservation"),
        content: const Text(
          "Êtes-vous sûr de vouloir annuler cette réservation ? Cette action est irréversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Non, conserver"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReservation();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Réservation annulée avec succès")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Oui, annuler"),
          ),
        ],
      ),
    );
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

// Widget d'état de chargement
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            "Chargement des détails...",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// Widget de texte extensible
class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;

  const ExpandableText({
    Key? key,
    required this.text,
    this.maxLines = 3,
    this.style,
  }) : super(key: key);

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: widget.style,
          maxLines: _expanded ? null : widget.maxLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (widget.text.length > 100) // Ne montrer "Voir plus" que si le texte est long
          TextButton(
            onPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _expanded ? "Voir moins" : "Voir plus",
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16,
                  color: Colors.blue.shade700,
                ),
              ],
            ),
          ),
      ],
    );
  }
}