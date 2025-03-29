import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_screen.dart';
import 'reservation_details_screen.dart';
import '../providers/reservation_provider.dart';
import 'package:intl/intl.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({Key? key}) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> with SingleTickerProviderStateMixin {
  late ReservationProvider _provider;
  late TabController _tabController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _provider = Provider.of<ReservationProvider>(context, listen: false);
    _loadReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await _provider.updateReservations();
      await _provider.loadReservations();
    } catch (e) {
      // Afficher un message d'erreur si nécessaire
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des réservations: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(initialIndex: 0), // Retour à Home
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _loadReservations,
            tooltip: 'Actualiser',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.access_time),
              text: 'En attente',
            ),
            Tab(
              icon: Icon(Icons.check_circle),
              text: 'Confirmées',
            ),
          ],
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
        ),
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || _isRefreshing) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadReservations,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab des réservations en attente
                _buildReservationList(
                    context,
                    provider.pendingReservations,
                    true,
                    isTablet,
                    "Aucune réservation en attente pour le moment."
                ),

                // Tab des réservations confirmées
                _buildReservationList(
                    context,
                    provider.confirmedReservations,
                    false,
                    isTablet,
                    "Aucune réservation confirmée pour le moment."
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigation vers l'écran de création de réservation
          // Implémentez cette fonctionnalité selon vos besoins
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Créer une nouvelle réservation'),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Nouvelle réservation',
      ),
    );
  }

  Widget _buildReservationList(
      BuildContext context,
      List<dynamic> reservations,
      bool isPending,
      bool isTablet,
      String emptyMessage
      ) {
    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPending ? Icons.access_time : Icons.check_circle,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Layout adaptatif pour tablettes et téléphones
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: isTablet
              ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: reservations.length,
            itemBuilder: (context, index) => _buildReservationItem(
              context,
              reservations[index] as Map<String, dynamic>,
              isPending,
            ),
          )
              : ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) => _buildReservationItem(
              context,
              reservations[index] as Map<String, dynamic>,
              isPending,
            ),
          ),
        );
      },
    );
  }

  Widget _buildReservationItem(
      BuildContext context,
      Map<String, dynamic> reservation,
      bool isPending,
      ) {
    // Formatage des dates pour une meilleure présentation
    String startDate = _formatDate(reservation['start_date'].toString());
    String endDate = _formatDate(reservation['end_date'].toString());

    Color statusColor = isPending ? Colors.orange : Colors.green;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReservationDetailsScreen(reservation: reservation),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône statut
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isPending ? Icons.access_time : Icons.check_circle,
                  color: statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Informations de réservation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Réservation #${reservation['id']}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Information sur le véhicule avec une meilleure présentation
                    Row(
                      children: [
                        const Icon(Icons.directions_car, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Véhicule ID: ${reservation['vehicle_id']}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Dates de début et fin plus lisibles
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Du $startDate au $endDate",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badge de statut
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPending ? "En Attente" : "Confirmée",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fonction utilitaire pour formater les dates
  String _formatDate(String dateStr) {
    try {
      // Si la date est déjà formatée, on la retourne telle quelle
      if (dateStr.contains('/')) return dateStr;

      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr; // En cas d'erreur, on retourne la chaîne originale
    }
  }
}