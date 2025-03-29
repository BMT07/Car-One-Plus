import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reservation_provider.dart';
import 'reservation_owner_details_screen.dart';

class ReservationOwnerScreen extends StatefulWidget {
  const ReservationOwnerScreen({Key? key}) : super(key: key);

  @override
  State<ReservationOwnerScreen> createState() => _ReservationOwnerScreenState();
}

class _ReservationOwnerScreenState extends State<ReservationOwnerScreen> {
  late ReservationProvider _provider;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<ReservationProvider>(context, listen: false);
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await _provider.getReservationsforOwner();
      await _provider.loadOwnerReservations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _loadReservations,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des réservations...'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadReservations,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Statistiques en haut
                      if (provider.pendingReservationsOwner.isNotEmpty ||
                          provider.confirmedReservationsOwner.isNotEmpty)
                        _buildStatisticsCard(provider),

                      const SizedBox(height: 20),

                      // Section des réservations en attente
                      if (provider.pendingReservationsOwner.isNotEmpty) ...[
                        _buildSectionHeader(
                          "Réservations en attente",
                          Colors.orange,
                          Icons.access_time,
                        ),
                        const SizedBox(height: 10),
                        ...provider.pendingReservationsOwner.map((reservation) =>
                            _buildReservationCard(context, reservation, true)
                        ).toList(),
                        const SizedBox(height: 20),
                      ],

                      // Section des réservations confirmées
                      if (provider.confirmedReservationsOwner.isNotEmpty) ...[
                        _buildSectionHeader(
                          "Réservations confirmées",
                          Colors.green,
                          Icons.check_circle,
                        ),
                        const SizedBox(height: 10),
                        ...provider.confirmedReservationsOwner.map((reservation) =>
                            _buildReservationCard(context, reservation, false)
                        ).toList(),
                      ],

                      // Message si aucune réservation
                      if (provider.pendingReservationsOwner.isEmpty &&
                          provider.confirmedReservationsOwner.isEmpty)
                        _buildEmptyState(),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCard(ReservationProvider provider) {
    final int pendingCount = provider.pendingReservationsOwner.length;
    final int confirmedCount = provider.confirmedReservationsOwner.length;
    final int totalCount = pendingCount + confirmedCount;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Aperçu de vos réservations",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("Total", totalCount, Icons.calendar_month, Colors.blue),
                _buildStatItem("En attente", pendingCount, Icons.access_time, Colors.orange),
                _buildStatItem("Confirmées", confirmedCount, Icons.check_circle, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildReservationCard(BuildContext context, Map<String, dynamic> reservation, bool isPending) {
    // Pour éviter les problèmes d'overflow dans les textes longs
    final TextOverflow overflow = TextOverflow.ellipsis;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPending ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReservationOwnerDetailsScreen(reservation: reservation),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône à gauche
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPending ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isPending ? Icons.access_time : Icons.check_circle,
                      color: isPending ? Colors.orange : Colors.green,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Infos sur la réservation
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "Réservation #${reservation['id']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: overflow,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPending ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isPending ? "En Attente" : "Confirmée",
                                style: TextStyle(
                                  color: isPending ? Colors.orange : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Détails adaptables à la taille de l'écran
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Layout adaptatif
                            if (constraints.maxWidth > 300) {
                              // Layout pour écrans larges
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(Icons.directions_car, "Véhicule ID: ${reservation['vehicle_id']}", overflow),
                                  _buildInfoRow(Icons.calendar_today, "Début: ${reservation['start_date']}", overflow),
                                  _buildInfoRow(Icons.event, "Fin: ${reservation['end_date']}", overflow),
                                ],
                              );
                            } else {
                              // Layout compact pour petits écrans
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(Icons.directions_car, "ID: ${reservation['vehicle_id']}", overflow),
                                  _buildInfoRow(Icons.date_range, "${reservation['start_date']} → ${reservation['end_date']}", overflow),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Actions en bas de carte
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Détails'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservationOwnerDetailsScreen(reservation: reservation),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, TextOverflow overflow) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              overflow: overflow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "Aucune réservation pour le moment",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Vos réservations apparaîtront ici",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadReservations,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}