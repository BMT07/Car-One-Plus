import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import 'add_vehicule_screen.dart';
import 'edit_vehicule_details_screen.dart';
import 'package:shimmer/shimmer.dart';

class EditVehicleScreen extends StatefulWidget {
  @override
  EditVehicleScreenState createState() => EditVehicleScreenState();
}

class EditVehicleScreenState extends State<EditVehicleScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await Provider.of<VehicleProvider>(context, listen: false).getOwnerVehicles();
      await Provider.of<VehicleProvider>(context, listen: false).loadOwnerVehicles();

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de charger les véhicules. Veuillez réessayer.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Réessayer',
            textColor: Colors.white,
            onPressed: _loadVehicles,
          ),
        ),
      );
    }
  }

  void _deleteVehicle(vehicleId) async {
    setState(() => _isLoading = true);
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);

    try {
      final response = await vehicleProvider.deleteVehicle(vehicleId);
      setState(() => _isLoading = false);
      Navigator.pop(context); // Ferme le dialog

      if (response.containsKey("error")) {
        _showSnackBar("Erreur lors de la suppression: ${response['error']}", Colors.red);
      } else {
        _showSnackBar("Véhicule supprimé avec succès !", Colors.green);
        Navigator.pop(context); // Retourne à l'écran précédent
      }
    } catch (e) {
      setState(() => _isLoading = false);
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

  void _filterVehicles(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _navigateToAddVehicle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddVehicleScreen()),
    );

    if (result == true) {
      _loadVehicles();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Véhicule ajouté avec succès!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _navigateToEditVehicle(Map<String, dynamic> vehicle) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditVehicleDetailsScreen(
          vehicle: vehicle,
        ),
      ),
    );

    if (result == true) {
      _loadVehicles();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Véhicule mis à jour avec succès!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleProvider>(context);

    // Filtrer les véhicules en fonction de la recherche
    final List<Map<String, dynamic>> filteredVehicles = _searchQuery.isEmpty
        ? List<Map<String, dynamic>>.from(vehicleProvider.vehiclesOfOwner)
        : vehicleProvider.vehiclesOfOwner
        .where((vehicle) =>
    vehicle["title"].toString().toLowerCase().contains(_searchQuery) ||
        vehicle["description"].toString().toLowerCase().contains(_searchQuery))
        .map((vehicle) => vehicle as Map<String, dynamic>)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gérer les véhicules',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black54),
            onPressed: _loadVehicles,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddVehicle,
        backgroundColor: Colors.red,
        elevation: 4,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadVehicles,
        color: Colors.red,
        child: Column(
          children: [
            // Zone de recherche
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un véhicule...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _filterVehicles('');
                      FocusScope.of(context).unfocus();
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                onChanged: _filterVehicles,
              ),
            ),

            // Compteur de véhicules
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    _isLoading
                        ? 'Chargement...'
                        : '${filteredVehicles.length} véhicule${filteredVehicles.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Spacer(),
                  if (!_isLoading && filteredVehicles.isNotEmpty)
                    Row(
                      children: [
                        Text('Trier par', style: TextStyle(color: Colors.grey[700])),
                        SizedBox(width: 4),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.sort, color: Colors.black54),
                          onSelected: (value) {
                            // Logique de tri à implémenter selon vos besoins
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'name_asc',
                              child: Text('Nom (A-Z)'),
                            ),
                            PopupMenuItem(
                              value: 'name_desc',
                              child: Text('Nom (Z-A)'),
                            ),
                            PopupMenuItem(
                              value: 'date_new',
                              child: Text('Plus récent'),
                            ),
                            PopupMenuItem(
                              value: 'date_old',
                              child: Text('Plus ancien'),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Liste de véhicules
            Expanded(
              child: _buildVehicleList(filteredVehicles),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList(List<Map<String, dynamic>> vehicles) {
    if (_isLoading) {
      return _buildLoadingShimmer();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (vehicles.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _buildVehicleCard(vehicle);
      },
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    List<dynamic> images = vehicle["images"] is List ? vehicle["images"] : [];
    String? imageUrl = images.isNotEmpty ? images[0] : null;

    return Dismissible(
      key: Key(vehicle["id"].toString()),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Supprimer ce véhicule?'),
            content: Text('Cette action est irréversible.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _deleteVehicle(vehicle["id"]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Véhicule supprimé'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Annuler',
              textColor: Colors.white,
              onPressed: () {
                // Logique pour annuler la suppression
                _loadVehicles();
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _navigateToEditVehicle(vehicle),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du véhicule avec hauteur fixe
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
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
                            fit: BoxFit.cover,
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          );
                        },
                      )
                          : Image.asset(
                        "assets/images/ferrari.png",
                        fit: BoxFit.cover,
                      ),
                      // Overlay dégradé pour améliorer la lisibilité
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Titre sur l'image
                      Positioned(
                        bottom: 8,
                        left: 12,
                        right: 12,
                        child: Text(
                          vehicle["title"]!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Badge d'édition
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Modifier',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Contenu texte
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Infos supplémentaires (à adapter selon vos données)
                    Row(
                      children: [
                        _buildInfoChip(Icons.calendar_today, 'Année: ${vehicle["created_at"] != null ? DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(vehicle["created_at"]).year.toString() : "N/A"}'),
                        SizedBox(width: 8),
                        _buildInfoChip(Icons.local_gas_station, '${vehicle["type_de_carburant"] ?? "N/A"}'),
                        SizedBox(width: 8),
                        _buildInfoChip(Icons.speed, '${vehicle["vitesse"] ?? "N/A"} km'),
                      ],
                    ),
                    SizedBox(height: 12),
                    // Description
                    Text(
                      vehicle["description"]!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 16),
                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          icon: Icon(Icons.edit_outlined, size: 18),
                          label: Text('Modifier'),
                          onPressed: () => _navigateToEditVehicle(vehicle),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: Icon(Icons.visibility, size: 18),
                          label: Text('Voir les détails'),
                          onPressed: () => _navigateToEditVehicle(vehicle),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: MediaQuery.of(context).size.width * 0.6,
                        color: Colors.white,
                      ),
                      SizedBox(height: 12),
                      Container(
                        height: 10,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 36,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            height: 36,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Aucun véhicule trouvé'
                : 'Aucun résultat pour "$_searchQuery"',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Ajoutez votre premier véhicule en cliquant sur le bouton +'
                : 'Essayez avec d\'autres termes de recherche',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          if (_searchQuery.isNotEmpty)
            ElevatedButton.icon(
              icon: Icon(Icons.clear),
              label: Text('Effacer la recherche'),
              onPressed: () {
                _searchController.clear();
                _filterVehicles('');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          if (_searchQuery.isEmpty)
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Ajouter un véhicule'),
              onPressed: _navigateToAddVehicle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          SizedBox(height: 16),
          Text(
            'Oups! Une erreur est survenue',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Impossible de charger vos véhicules',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.refresh),
            label: Text('Réessayer'),
            onPressed: _loadVehicles,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}