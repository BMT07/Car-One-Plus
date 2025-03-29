import 'package:flutter/material.dart';
import 'dart:async';
import '../services/vehicle_search_service.dart';
import '../models/vehicle.dart';
import 'car_details_screen.dart';
import 'main_screen.dart';
// Importez votre service de recherche et votre modèle de véhicule
// import 'package:votre_app/services/vehicle_search_service.dart';
// import 'package:votre_app/models/vehicle.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final VehicleSearchService _searchService = VehicleSearchService();

  // Filtres
  String? _localisation;
  RangeValues _priceRange = const RangeValues(0, 1000); // Ajustez selon vos besoins
  String? _typeDeVehicule;

  bool _isLoading = false;
  List<dynamic> _vehicles = [];
  int _totalVehicles = 0;
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  String? _errorMessage;

  // Contrôleur pour la pagination
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _loadVehicles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _localisation = _searchController.text;
        _currentPage = 0;
        _vehicles = [];
      });
      _loadVehicles();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreVehicles();
    }
  }

  Future<void> _loadVehicles() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _searchService.searchVehicles(
        localisation: _localisation,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        offset: _currentPage * _itemsPerPage,
        typeDeVehicle: _typeDeVehicule,
        limit: _itemsPerPage,
      );

      setState(() {
        _vehicles = result['vehicles'];
        _totalVehicles = result['total'];
        _errorMessage = result['error'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreVehicles() async {
    if (_isLoading || _vehicles.length >= _totalVehicles) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final result = await _searchService.searchVehicles(
        localisation: _localisation,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        offset: nextPage * _itemsPerPage,
        limit: _itemsPerPage,
      );

      final newVehicles = result['vehicles'];

      if (newVehicles.isNotEmpty) {
        setState(() {
          _vehicles.addAll(newVehicles);
          _currentPage = nextPage;
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _getVehicleTypes() {
    // Vous pouvez charger cette liste depuis votre API ou la définir statiquement
    return [
      'Tous',
      'Berline',
      'SUV',
      'Cabriolet',
      'Compacte',
      'Citadine',
      'Utilitaire',
      'Sport',
      '4X4',
      'Autre'
    ];
  }

  void _showFilterDialog() {
    String? selectedType = _typeDeVehicule;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filtres",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Fourchette de prix
                  const Text(
                    "Fourchette de prix (€/jour)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 100,
                    labels: RangeLabels(
                      _priceRange.start.round().toString(),
                      _priceRange.end.round().toString(),
                    ),
                    onChanged: (values) {
                      setModalState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  Text(
                    "${_priceRange.start.round()} € - ${_priceRange.end.round()} €",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  // Type de véhicule
                  const Text(
                    "Type de véhicule",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true,
                      underline: Container(),
                      hint: const Text("Sélectionnez un type"),
                      items: _getVehicleTypes().map((String type) {
                        return DropdownMenuItem<String>(
                          value: type == 'Tous' ? null : type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setModalState(() {
                          selectedType = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Boutons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            setModalState(() {
                              _priceRange = const RangeValues(0, 1000);
                              selectedType = null;
                            });
                          },
                          child: const Text("Réinitialiser"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _typeDeVehicule = selectedType;
                              _currentPage = 0;
                              _vehicles = [];
                            });
                            _loadVehicles();
                          },
                          child: const Text(
                            "Appliquer",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(initialIndex: 0),
              ),
            );
          },
        ),
        title: const Text(
          "Recherche",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Rechercher par localisation",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                      : null,
                ),
              ),
            ),
          ),

          // Filtres actifs
          if (_typeDeVehicule != null || _priceRange.start > 0 || _priceRange.end < 1000)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_typeDeVehicule != null)
                    Chip(
                      label: Text(_typeDeVehicule!),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _typeDeVehicule = null;
                          _currentPage = 0;
                          _vehicles = [];
                        });
                        _loadVehicles();
                      },
                    ),
                  if (_priceRange.start > 0 || _priceRange.end < 1000)
                    Chip(
                      label: Text("${_priceRange.start.round()} € - ${_priceRange.end.round()} €"),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _priceRange = const RangeValues(0, 1000);
                          _currentPage = 0;
                          _vehicles = [];
                        });
                        _loadVehicles();
                      },
                    ),
                ],
              ),
            ),

          // Contenu principal
          Expanded(
            child: _isLoading && _vehicles.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _vehicles.isEmpty
                ? _buildEmptyResult()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.red.withOpacity(0.8),
          ),
          const SizedBox(height: 16),
          const Text(
            "Aucun résultat trouvé",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _errorMessage ?? "Essayez d'utiliser des termes de recherche plus simples ou ajustez vos filtres.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          itemCount: _vehicles.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _vehicles.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final vehicle = _vehicles[index];
            final List<String> images = (vehicle['images'] as List?)?.map((img) => img.toString()).toList() ?? [];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image du véhicule
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: images.isNotEmpty
                          ? Image.network(
                        images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.directions_car, size: 50),
                            ),
                          );
                        },
                      )
                          : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.directions_car, size: 50),
                        ),
                      ),
                    ),
                  ),

                  // Informations du véhicule
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                vehicle['title'] ?? 'Véhicule sans titre',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${vehicle['price_per_day']} € / jour',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Localisation
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                vehicle['localisation'] ?? 'Localisation inconnue',
                                style: TextStyle(color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Caractéristiques
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.local_gas_station, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  vehicle['type_de_carburant'] ?? 'N/A',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.settings, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  vehicle['transmission'] ?? 'N/A',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.airline_seat_recline_normal, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '${vehicle['nbreSieges'] ?? 0} sièges',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bouton pour voir plus
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // Naviguer vers la page de détail du véhicule
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => CarDetailsScreen(vehicle: vehicle),
                             ),
                           );
                        },
                        child: const Text(
                          "Voir détails",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (_isLoading && _vehicles.isNotEmpty)
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}