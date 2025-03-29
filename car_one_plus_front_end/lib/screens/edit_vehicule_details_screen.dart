import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';

class EditVehicleDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle;

  const EditVehicleDetailsScreen({Key? key, required this.vehicle}) : super(key: key);

  @override
  _EditVehicleDetailsScreenState createState() => _EditVehicleDetailsScreenState();
}

class _EditVehicleDetailsScreenState extends State<EditVehicleDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _puissanceController;
  late TextEditingController _localisationController;
  late TextEditingController _vitesseController;
  late TextEditingController _nbreSiegesController;

  int? _vehicleId;
  bool? _availableController;
  String? _selectedFuelType;
  String? _selectedVehicleType;
  String? _selectedTransmission;
  List<String> _vehicleImages = [];
  List<XFile> _newImages = [];
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _vehicleId = widget.vehicle["id"];
    _nameController = TextEditingController(text: widget.vehicle['title']);
    _descriptionController = TextEditingController(text: widget.vehicle['description']);
    _priceController = TextEditingController(text: widget.vehicle['price_per_day'].toString());
    _nbreSiegesController = TextEditingController(text: widget.vehicle['nbreSieges'].toString());
    _puissanceController = TextEditingController(text: widget.vehicle['puissance']);
    _vitesseController = TextEditingController(text: widget.vehicle['vitesse']);
    _localisationController = TextEditingController(text: widget.vehicle['localisation']);
    _selectedFuelType = widget.vehicle['type_de_carburant'];
    _selectedVehicleType = widget.vehicle['type_de_vehicule'];
    _selectedTransmission = widget.vehicle['transmission'];
    _availableController = widget.vehicle['available'];
    _vehicleImages = List<String>.from(widget.vehicle['images'] ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _puissanceController.dispose();
    _localisationController.dispose();
    _vitesseController.dispose();
    _nbreSiegesController.dispose();
    super.dispose();
  }

  void _updateVehicle() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez corriger les erreurs du formulaire"), backgroundColor: Colors.amber),
      );
      return;
    }

    setState(() => _isLoading = true);
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);

    try {
      final response = await vehicleProvider.updateVehicle(
          _vehicleId!,
          _nameController.text,
          _descriptionController.text,
          double.parse(_priceController.text),
          _localisationController.text,
          _puissanceController.text,
          _selectedFuelType!,
          _selectedVehicleType!,
          _vitesseController.text,
          _selectedTransmission!,
          int.parse(_nbreSiegesController.text),
          _availableController!
      );

      setState(() => _isLoading = false);

      if (response.containsKey("error")) {
        _showSnackBar("Erreur : ${response['error']}", Colors.red);
      } else {
        _showSnackBar("Véhicule modifié avec succès", Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Une erreur est survenue: $e", Colors.red);
    }
  }

  void _saveNewImages() async {
    if (_newImages.isEmpty) {
      _showSnackBar("Aucune nouvelle image à enregistrer", Colors.amber);
      return;
    }

    setState(() => _isLoading = true);
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
    int successCount = 0;

    try {
      for (XFile image in _newImages) {
        File file = File(image.path);
        final response = await vehicleProvider.addVehiclePhotos(_vehicleId!, file);

        if (response.containsKey("error")) {
          _showSnackBar("Erreur lors de l'ajout de l'image: ${response['error']}", Colors.red);
          break;
        } else {
          successCount++;
        }
      }

      if (successCount > 0) {
        _showSnackBar("$successCount ${successCount == 1 ? 'photo ajoutée' : 'photos ajoutées'} avec succès !", Colors.green);
        setState(() {
          _newImages.clear();
        });
      }
    } catch (e) {
      _showSnackBar("Une erreur est survenue: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _deleteVehicle() async {
    setState(() => _isLoading = true);
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);

    try {
      final response = await vehicleProvider.deleteVehicle(_vehicleId!);
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

  void _confirmDeleteVehicle() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: const Text("Voulez-vous vraiment supprimer ce véhicule ? Cette action est irréversible."),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton.icon(
              onPressed: _deleteVehicle,
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              label: const Text("Supprimer", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickNewImages() async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile>? pickedImages = await picker.pickMultiImage();
      if (pickedImages != null && pickedImages.isNotEmpty) {
        setState(() {
          _newImages.addAll(pickedImages);
        });
      }
    } catch (e) {
      _showSnackBar("Erreur lors de la sélection des images: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Modifier le véhicule',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDeleteVehicle,
            tooltip: 'Supprimer le véhicule',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section principale du formulaire
                  _buildSectionTitle('Informations principales'),
                  _buildTextField(
                    _nameController,
                    'Nom du véhicule',
                    'Entrez le nom',
                    validator: (value) => value!.isEmpty ? 'Le nom est requis' : null,
                    prefixIcon: const Icon(Icons.directions_car),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    _descriptionController,
                    'Description',
                    'Ajoutez une description',
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'La description est requise' : null,
                    prefixIcon: const Icon(Icons.description),
                  ),
                  const SizedBox(height: 16),

                  // Section prix et caractéristiques
                  _buildSectionTitle('Prix et caractéristiques'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          _priceController,
                          'Prix par jour (€)',
                          'Entrez le prix',
                          validator: (value) {
                            if (value!.isEmpty) return 'Le prix est requis';
                            if (double.tryParse(value) == null) return 'Prix invalide';
                            return null;
                          },
                          prefixIcon: const Icon(Icons.euro),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildNumberField(
                          _nbreSiegesController,
                          'Nombre de sièges',
                          'Entrez le nombre',
                          validator: (value) {
                            if (value!.isEmpty) return 'Requis';
                            if (int.tryParse(value) == null) return 'Invalide';
                            return null;
                          },
                          prefixIcon: const Icon(Icons.event_seat),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section performances
                  _buildSectionTitle('Performances'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _puissanceController,
                          'Puissance',
                          'Ex: 110 ch',
                          validator: (value) => value!.isEmpty ? 'Requis' : null,
                          prefixIcon: const Icon(Icons.speed),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          _vitesseController,
                          'Vitesse max',
                          'Ex: 180 km/h',
                          validator: (value) => value!.isEmpty ? 'Requis' : null,
                          prefixIcon: const Icon(Icons.shutter_speed),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section localisation
                  _buildSectionTitle('Localisation'),
                  _buildTextField(
                    _localisationController,
                    'Localisation',
                    'Ville, Adresse...',
                    validator: (value) => value!.isEmpty ? 'La localisation est requise' : null,
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  const SizedBox(height: 16),

                  // Section spécifications
                  _buildSectionTitle('Spécifications'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          'Type de carburant',
                          _selectedFuelType,
                          ['Essence', 'Diesel', 'Électrique', 'Hybride'],
                              (value) {
                            setState(() {
                              _selectedFuelType = value;
                            });
                          },
                          icon: const Icon(Icons.local_gas_station),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          'Type de véhicule',
                          _selectedVehicleType,
                          ['SUV', 'Berline', 'Compacte', '4X4', 'Sport'],
                              (value) {
                            setState(() {
                              _selectedVehicleType = value;
                            });
                          },
                          icon: const Icon(Icons.category),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          'Transmission',
                          _selectedTransmission,
                          ['Automatique', 'Manuelle'],
                              (value) {
                            setState(() {
                              _selectedTransmission = value;
                            });
                          },
                          icon: const Icon(Icons.settings),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section disponibilité - CORRIGÉE pour éviter le débordement
                  _buildSectionTitle('Disponibilité'),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.blue),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Ce véhicule est-il disponible à la location ?',
                                  style: TextStyle(fontSize: 14),
                                  //overflow: TextOverflow.ellipsis, // Ajoute l'ellipsis si nécessaire
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribue l'espace équitablement
                            children: [
                              const Text('Non', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              Expanded(
                                child: Switch(
                                  value: _availableController ?? false,
                                  onChanged: (value) {
                                    setState(() {
                                      _availableController = value;
                                    });
                                  },
                                  activeColor: Colors.green,
                                ),
                              ),
                              const Text('Oui', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section images existantes
                  if (_vehicleImages.isNotEmpty) ...[
                    _buildSectionTitle('Images actuelles'),
                    _buildImageGallery(),
                    const SizedBox(height: 16),
                  ],

                  // Section nouvelles images
                  _buildSectionTitle('Ajouter des images'),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickNewImages,
                            icon: const Icon(Icons.add_a_photo, color: Colors.white),
                            label: const Text('Sélectionner des images', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Preview des nouvelles images
                          if (_newImages.isNotEmpty) ...[
                            _buildNewImagesPreview(),
                            const SizedBox(height: 16),

                            ElevatedButton.icon(
                              onPressed: _saveNewImages,
                              icon: const Icon(Icons.cloud_upload, color: Colors.white),
                              label: const Text('Enregistrer les photos', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bouton de sauvegarde
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _updateVehicle,
                      icon: const Icon(Icons.save, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      label: const Text(
                          'Sauvegarder les modifications',
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      String hint,
      {int maxLines = 1,
        String? Function(String?)? validator,
        Widget? prefixIcon}
      ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildNumberField(
      TextEditingController controller,
      String label,
      String hint,
      {String? Function(String?)? validator,
        Widget? prefixIcon}
      ) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField(
      String label,
      String? selectedValue,
      List<String> items,
      Function(String?) onChanged,
      {Widget? icon}
      ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        prefixIcon: icon,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items.map((type) => DropdownMenuItem(
          value: type,
          child: Text(
              type,
              overflow: TextOverflow.ellipsis, // Ajoute l'ellipsis pour le texte qui dépasse
          )
      )).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Ce champ est requis' : null,
      isExpanded: true, // Permet au dropdown de s'étendre pour utiliser tout l'espace disponible
      icon: const Icon(Icons.arrow_drop_down, size: 24), // Réduit légèrement la taille de l'icône
    );
  }

  Widget _buildImageGallery() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _vehicleImages.length,
        itemBuilder: (context, index) {
          final image = _vehicleImages[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(right: 12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    image,
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 120,
                        width: 120,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: 120,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _removeImage(image),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewImagesPreview() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _newImages.length,
        itemBuilder: (context, index) {
          final image = _newImages[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(right: 12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(image.path),
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() {
                        _newImages.remove(image);
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _removeImage(String imageUrl) {
    setState(() {
      _vehicleImages.remove(imageUrl);
    });
  }
}