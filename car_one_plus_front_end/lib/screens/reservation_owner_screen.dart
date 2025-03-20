import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'reservation_details_screen.dart';
import '../providers/reservation_provider.dart';
import 'reservation_owner_details_screen.dart';

class ReservationOwnerScreen extends StatefulWidget {
  const ReservationOwnerScreen({Key? key}) : super(key: key);

  @override
  _ReservationOwnerScreenState createState() => _ReservationOwnerScreenState();
}

class _ReservationOwnerScreenState extends State<ReservationOwnerScreen> {
  late ReservationProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<ReservationProvider>(context, listen: false);
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    await _provider.getReservationsforOwner(); // Récupérer les dernières réservations
    await _provider.loadOwnerReservations();
    if (mounted) {
      setState(() {}); // Rafraîchir l'interface
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        centerTitle: true,
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadReservations, // Permet de rafraîchir avec un swipe vers le bas
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📌 Section des réservations en attente
                  if (provider.pendingReservationsOwner.isNotEmpty) ...[
                    const Text(
                      "Réservations en attente",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.pendingReservationsOwner.length,
                      itemBuilder: (context, index) {
                        final reservation = provider.pendingReservationsOwner[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReservationOwnerDetailsScreen(reservation: reservation),
                              ),
                            );
                          },
                          child: ReservationOwnerCard(
                            reservation:reservation,
                            isPending: true,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 📌 Section des réservations confirmées
                  if (provider.confirmedReservationsOwner.isNotEmpty) ...[
                    const Text(
                      "Réservations confirmées",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.confirmedReservationsOwner.length,
                      itemBuilder: (context, index) {
                        final reservation = provider.confirmedReservationsOwner[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReservationOwnerDetailsScreen(reservation: reservation),
                              ),
                            );
                          },
                          child: ReservationOwnerCard(
                            reservation:reservation,
                            isPending: false,
                          ),
                        );
                      },
                    ),
                  ],

                  // 📌 Aucun résultat
                  if (provider.pendingReservationsOwner.isEmpty &&
                      provider.confirmedReservationsOwner.isEmpty)
                    const Center(
                      child: Text(
                        "Aucune réservation pour le moment.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ReservationOwnerCard extends StatelessWidget {
  final Map<String, dynamic> reservation;
  final bool isPending;

  const ReservationOwnerCard({
    Key? key,
    required this.reservation,
    required this.isPending,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 📌 Icône à gauche
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPending ? Colors.orange[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPending ? Icons.access_time : Icons.check_circle,
                color: isPending ? Colors.orange : Colors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // 📌 Infos sur la réservation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Réservation ID: ${reservation['id']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Véhicule ID: ${reservation['vehicle_id']}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "Début: ${reservation['start_date']}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "Fin: ${reservation['end_date']}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // 📌 Statut à droite
            Text(
              isPending ? "En Attente" : "Confirmée",
              style: TextStyle(
                color: isPending ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


