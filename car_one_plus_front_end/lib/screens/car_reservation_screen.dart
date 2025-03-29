import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  int numberOfDays = 0;
  double totalAmount = 0.0;
  bool isLoading = false;

  final ApiService apiService = ApiService();
  late Map<String, dynamic> reservation;

  @override
  void initState() {
    super.initState();
    _calculateTotalAmount();
  }

  void _calculateTotalAmount() {
    if (startDate != null && endDate != null) {
      numberOfDays = endDate!.difference(startDate!).inDays + 1;
      double pricePerDay = widget.vehicle["price_per_day"] ?? 0.0;
      totalAmount = numberOfDays * pricePerDay;
    } else {
      numberOfDays = 0;
      totalAmount = 0.0;
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2).format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now;
    final DateTime lastDate = now.add(const Duration(days: 365));

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        _calculateTotalAmount();
      });
    }
  }

  Future<void> _reserveVehicleInPending(BuildContext context) async {
    if (startDate == null || endDate == null) {
      _showErrorSnackBar('Veuillez sélectionner une période de location.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
      final vehicleId = widget.vehicle["id"];

      final response = await reservationProvider.addReservation(
        vehicleId,
        startDate!.toIso8601String(),
        endDate!.toIso8601String(),
      );

      if (!response.containsKey("error")) {
        _showSuccessSnackBar('Réservation en attente créée avec succès !');
      } else {
        _showErrorSnackBar('Erreur : ${response["error"]}');
      }
    } catch (e) {
      _showErrorSnackBar('Une erreur est survenue: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _reserveVehicleWithConfirmation(BuildContext context) async {
    if (startDate == null || endDate == null) {
      _showErrorSnackBar('Veuillez sélectionner une période de location.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
      final vehicleId = widget.vehicle["id"];

      final response = await reservationProvider.addReservation(
        vehicleId,
        startDate!.toIso8601String(),
        endDate!.toIso8601String(),
      );

      if (!response.containsKey("error") &&
          response["reservation"] != null &&
          response["reservation"]["reservation"] != null) {
        reservation = response["reservation"]["reservation"];
        _showSuccessSnackBar('Réservation créée avec succès !');

        if (reservation.containsKey("id")) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReservationDetailScreen(
                reservationId: reservation["id"],
                amount: totalAmount,
                vehicleTitle: widget.vehicle["title"],
                vehicleDescription: widget.vehicle["description"],
              ),
            ),
          );
        }
      } else {
        _showErrorSnackBar('Erreur lors de la création de la réservation');
      }
    } catch (e) {
      _showErrorSnackBar('Une erreur est survenue: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;
    final size = MediaQuery.of(context).size;
    final pricePerDay = vehicle["price_per_day"] ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Réservation de ${vehicle["title"] ?? 'véhicule'}",
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image du véhicule
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.25,
                  child: Hero(
                    tag: 'vehicle_image_${vehicle["id"]}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: vehicle["images"] != null && vehicle["images"].isNotEmpty
                          ? Image.network(
                        vehicle["images"][0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "assets/images/ferrari.png",
                            fit: BoxFit.cover,
                          );
                        },
                      )
                          : Image.asset(
                        "assets/images/ferrari.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Détails du véhicule
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                vehicle["title"] ?? 'Nom indisponible',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _formatCurrency(pricePerDay) + '/jour',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.grey, size: 18),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '${vehicle["localisation"] ?? "Non précisé"}',
                                style: const TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sélection des dates
                const Text(
                  'Période de location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _selectDateRange(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                startDate != null && endDate != null
                                    ? 'Dates sélectionnées'
                                    : 'Sélectionner les dates',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const Icon(Icons.calendar_today, color: Colors.red),
                            ],
                          ),
                          if (startDate != null && endDate != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Début',
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(startDate!),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 40,
                                  child: const VerticalDivider(color: Colors.grey),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Fin',
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(endDate!),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Récapitulatif du prix
                if (startDate != null && endDate != null) ...[
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Récapitulatif',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Prix par jour:'),
                              Text(_formatCurrency(pricePerDay)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Nombre de jours:'),
                              Text('$numberOfDays'),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Montant total:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _formatCurrency(totalAmount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // Boutons de réservation
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => _reserveVehicleInPending(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Réserver en attente',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => _reserveVehicleWithConfirmation(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Confirmer et payer',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),

          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}