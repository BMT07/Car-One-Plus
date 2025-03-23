import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart'; // Ajout de l'import pour Provider
import '../providers/vehicle_provider.dart'; // Ajustez le chemin d'importation selon votre structure
import 'car_reservation_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle;

  const CarDetailsScreen({Key? key, required this.vehicle}) : super(key: key);

  @override
  _CarDetailsScreenState createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    // S'assurer que les véhicules sont chargés
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehicleProvider>(context, listen: false).updateVehicles();
      Provider.of<VehicleProvider>(context, listen: false).loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Préparer les images pour le carrousel
    List<String> imageUrls = [];
    if (widget.vehicle["images"] is List && (widget.vehicle["images"] as List).isNotEmpty) {
      imageUrls = List<String>.from(widget.vehicle["images"]);
    } else {
      // Image par défaut si pas d'images disponibles
      imageUrls = ["assets/images/ferrari.png"];
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.red),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ajouté aux favoris')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Partager ce véhicule')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrousel d'images modifié sans controller
            Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 250,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    autoPlay: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                  items: imageUrls.map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: url.startsWith('http')
                              ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset("assets/images/ferrari.png", fit: BoxFit.cover);
                            },
                          )
                              : Image.asset(url, fit: BoxFit.cover),
                        );
                      },
                    );
                  }).toList(),
                ),
                // Boutons de navigation modifiés pour utiliser PageView plutôt que controller
                Positioned(
                  left: 10,
                  top: 125,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withOpacity(0.7),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                      onPressed: () {
                        // Simplement changer l'index et laisser le widget se reconstruire
                        if (_currentImageIndex > 0) {
                          setState(() {
                            _currentImageIndex--;
                          });
                        }
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 125,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withOpacity(0.7),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                      onPressed: () {
                        // Simplement changer l'index et laisser le widget se reconstruire
                        if (_currentImageIndex < imageUrls.length - 1) {
                          setState(() {
                            _currentImageIndex++;
                          });
                        }
                      },
                    ),
                  ),
                ),
                // Indicateurs de position
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imageUrls.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == entry.key
                              ? Colors.red
                              : Colors.white.withOpacity(0.7),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            // Contenu principal
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom de la voiture et prix
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.vehicle["title"] ?? 'Nom indisponible',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.vehicle["price_per_day"] ?? 'Prix indisponible'} €/jour',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Localisation avec icône
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.vehicle["localisation"] ?? 'Localisation indisponible',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // Section Caractéristiques avec carte
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Caractéristiques',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildFeatureIcon(Icons.directions_car, 'Type', widget.vehicle["type_de_vehicule"] ?? '-'),
                              _buildFeatureIcon(Icons.settings, 'Transmission', widget.vehicle["transmission"] ?? '-'),
                              _buildFeatureIcon(Icons.speed, 'Vitesse', widget.vehicle["vitesse"] ?? '-'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildFeatureIcon(Icons.local_gas_station, 'Carburant', widget.vehicle["type_de_carburant"] ?? '-'),
                              _buildFeatureIcon(Icons.power, 'Puissance', widget.vehicle["puissance"] ?? '-'),
                              _buildFeatureIcon(Icons.event_seat, 'Sièges', '${widget.vehicle["nbreSieges"] ?? '-'}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // À propos de la voiture
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'À propos de la voiture',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.vehicle["description"] ?? 'Description non disponible',
                            maxLines: _isDescriptionExpanded ? null : 3,
                            overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isDescriptionExpanded = !_isDescriptionExpanded;
                              });
                            },
                            child: Text(
                              _isDescriptionExpanded ? 'Voir moins' : 'Voir plus',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section Véhicules similaires avec Consumer
                  Consumer<VehicleProvider>(
                    builder: (context, vehicleProvider, child) {
                      // Filtrer les véhicules similaires
                      final similarVehicles = _getSimilarVehicles(vehicleProvider);

                      if (similarVehicles.isEmpty) {
                        return const SizedBox.shrink(); // Ne rien afficher s'il n'y a pas de véhicules similaires
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Véhicules similaires',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: similarVehicles.length,
                              itemBuilder: (context, index) {
                                final car = similarVehicles[index];
                                return _buildSimilarCarCard(context, car);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Action pour discuter avec le vendeur
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ouverture de la conversation...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.chat, color: Colors.red),
                label: const Text(
                  'Discuter',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Action pour louer la voiture
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarReservationScreen(vehicle: widget.vehicle),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.directions_car, color: Colors.white),
                label: const Text(
                  'Louer maintenant',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.red),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarCarCard(BuildContext context, Map<String, dynamic> car) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailsScreen(vehicle: car),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: car["images"] != null && car["images"].isNotEmpty
                  ? Image.network(
                car["images"][0],
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset("assets/images/ferrari.png", height: 100, width: double.infinity, fit: BoxFit.cover);
                },
              )
                  : Image.asset("assets/images/ferrari.png", height: 100, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car["title"] ?? 'Voiture',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.euro, size: 14, color: Colors.red),
                      Text(
                        '${car["price_per_day"] ?? '-'}/jour',
                        style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nouvelle méthode pour récupérer les véhicules similaires
  List<Map<String, dynamic>> _getSimilarVehicles(VehicleProvider vehicleProvider) {
    // Récupérer le type du véhicule actuel
    String currentType = widget.vehicle["type_de_vehicule"] ?? "";

    // Si le type est vide ou la liste des véhicules est vide, retourner une liste vide
    if (currentType.isEmpty || vehicleProvider.vehicles.isEmpty) {
      return [];
    }

    // Filtrer les véhicules par type et exclure le véhicule actuel
    List<dynamic> filteredVehicles = vehicleProvider.vehicles
        .where((vehicle) =>
    // Vérifier que le véhicule a le même type
    vehicle["type_de_vehicule"] == currentType &&
        // Exclure le véhicule actuel
        vehicle["id"] != widget.vehicle["id"])
        .toList();

    // Limiter à 5 véhicules similaires maximum
    if (filteredVehicles.length > 5) {
      filteredVehicles = filteredVehicles.sublist(0, 5);
    }

    return List<Map<String, dynamic>>.from(filteredVehicles);
  }
}