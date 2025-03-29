import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'car_details_screen.dart';
import 'notifications_screen.dart';
import 'search_screen.dart';
import '../providers/user_provider.dart';
import '../providers/vehicle_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Chargement des données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUserData();
      Provider.of<VehicleProvider>(context, listen: false).updateVehicles();
      Provider.of<VehicleProvider>(context, listen: false).loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final vehicleProvider = Provider.of<VehicleProvider>(context);
    final orientation = MediaQuery.of(context).orientation;
    final screenSize = MediaQuery.of(context).size;

    // Adaptation du nombre de colonnes en fonction de l'orientation et de la taille
    int crossAxisCount = 2;
    double childAspectRatio = 0.75;

    // Adaptation aux tablettes et grands écrans
    if (screenSize.width > 600) {
      crossAxisCount = orientation == Orientation.portrait ? 3 : 4;
      childAspectRatio = 0.8;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade50,
        elevation: 0,
        toolbarHeight: kToolbarHeight + 10,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Bonjour,',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black
                )
            ),
            Text(
              '${userProvider.userPrenom} ${userProvider.userNom} 👋',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          Hero(
            tag: 'notification_button',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationsScreen())
                ),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications, color: Colors.black),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await vehicleProvider.updateVehicles();
            await vehicleProvider.loadVehicles();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      // Barre de recherche améliorée
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SearchScreen())
                        ),
                        child: Container(
                          height: 50,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 12),
                              Icon(Icons.search, color: Colors.grey.shade700),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Rechercher ici',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SectionHeader(title: 'La liste des voitures disponibles'),
                      SizedBox(height: 10),
                    ],
                  ),
                ),

                // Grid responsive des véhicules
                vehicleProvider.vehicles.isEmpty
                    ? SliverFillRemaining(
                  child: Center(
                    child: vehicleProvider.isLoading
                        ? CircularProgressIndicator(color: Colors.pinkAccent)
                        : Text("Aucun véhicule disponible"),
                  ),
                )
                    : SliverPadding(
                  padding: EdgeInsets.only(bottom: 20),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: childAspectRatio,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final vehicle = vehicleProvider.vehicles[index];
                        return VehicleCard(vehicle: vehicle);
                      },
                      childCount: vehicleProvider.vehicles.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
    );
  }
}

class VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  const VehicleCard({Key? key, required this.vehicle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Gestion sécurisée des images
    String? imageUrl;
    if (vehicle["images"] is List && (vehicle["images"] as List).isNotEmpty) {
      imageUrl = vehicle["images"][0];
    }

    return Hero(
      tag: 'vehicle_${vehicle['id'] ?? UniqueKey().toString()}',
      child: Material(
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarDetailsScreen(vehicle: vehicle),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image avec traitement des erreurs
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        imageUrl != null
                            ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                                "assets/images/ferrari.png",
                                fit: BoxFit.cover
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: Colors.pinkAccent,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        )
                            : Image.asset(
                            "assets/images/ferrari.png",
                            fit: BoxFit.cover
                        ),
                        // Badge de prix animé
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${vehicle['price_per_day'] ?? "N/A"} €/j',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Informations sur le véhicule
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle['title'] ?? "Titre inconnu",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${vehicle['type_de_vehicule'] ?? "Type inconnu"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey.shade600
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              vehicle['localisation'] ?? "Localisation inconnue",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}