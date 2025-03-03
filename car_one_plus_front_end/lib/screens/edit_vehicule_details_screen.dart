import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/vehicle_provider.dart';
import 'edit_vehicule_screen.dart';


class EditVehicleDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle; // Données du véhicule à modifier

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
  //late TextEditingController _availableController;

  int? _vehicleId;
  bool? _availableController;
  String? _selectedFuelType;
  String? _selectedVehicleType;
  String? _selectedTransmission;
  List<String> _vehicleImages = [];

  // Nouvelle liste pour stocker les nouvelles images sélectionnées par l'utilisateur
  List<XFile> _newImages = [];

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


  void _updateVehicle() async {
      final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);

      int vehicleId = _vehicleId!;
      String title = _nameController.text;
      String description = _descriptionController.text;
      double pricePerDay = double.parse(_priceController.text);
      String localisation = _localisationController.text;
      String puissance = _puissanceController.text;
      String vitesse = _vitesseController.text;
      int nbreSieges = int.parse(_nbreSiegesController.text);
      String typeDeCarburant = _selectedFuelType!;
      String typeDeVehicule = _selectedVehicleType!;
      String transmission = _selectedTransmission!;
      bool available = _availableController!;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      final response = await vehicleProvider.updateVehicle(
        vehicleId,
        title,
        description,
        pricePerDay,
        localisation,
        puissance,
        typeDeCarburant,
        typeDeVehicule,
        vitesse,
        transmission,
        nbreSieges,
        available
      );

      Navigator.pop(context);

      if (response.containsKey("error")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${response['error']}"), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Véhicule Modifié avec succès"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
  }

  void _saveNewImages() async {
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
    int vehicleId =_vehicleId!;
    if (_newImages.isEmpty) return;

    for (XFile image in _newImages) {
      File file = File(image.path);
      print("file avant:${file}");

      // ✅ Appel du Provider pour uploader l'image
      final response = await vehicleProvider.addVehiclePhotos(vehicleId, file);

      print("file apres:${file}");
      if (response.containsKey("error")) {
        // 🚨 Afficher une erreur si l'upload échoue
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
              "Erreur lors de l'ajout de l'image: ${response['error']}"),
              backgroundColor: Colors.red),
        );
        break; // Sortir de la boucle si une erreur survient
      }else{
        // ✅ Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Photos ajoutées avec succès !"), backgroundColor: Colors.green),
        );
      }
    }

  }

  void _deleteVehicle() async{
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
    int vehicleId =_vehicleId!;


    final response = await vehicleProvider.deleteVehicle(vehicleId);

    if (response.containsKey("error")) {
      // 🚨 Afficher une erreur si l'upload échoue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            "Erreur lors de la suppression: ${response['error']}"),
            backgroundColor: Colors.red),
      );
    }else{
      // ✅ Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Suppression Reussié !"), backgroundColor: Colors.green),
      );
    }

    Navigator.pop(context); // Ferme le dialog

    Navigator.pop(context); // Ferme EditVehicleDetailsScreen et retourne à EditVehicleScreen



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Modifier le véhicule',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // 🚨 Ajout de l'icône de suppression dans l'AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDeleteVehicle, // Fonction pour afficher le dialogue de confirmation
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameController, 'Nom du véhicule', 'Entrez le nom'),
              const SizedBox(height: 16),

              _buildTextField(_descriptionController, 'Description', 'Ajoutez une description', maxLines: 3),
              const SizedBox(height: 16),

              _buildNumberField(_priceController, 'Prix par jour', 'Entrez le prix'),
              const SizedBox(height: 16),

              _buildNumberField(_nbreSiegesController, 'nombre de sièges', 'Entrez le nombre de siège'),
              const SizedBox(height: 16),

              _buildTextField(_puissanceController, 'Puissance', 'Entrez la puissance'),
              const SizedBox(height: 16),

              _buildTextField(_vitesseController, 'Vitesse', 'Entrez la vitesse max'),
              const SizedBox(height: 16),

              _buildTextField(_localisationController, 'Localisation', 'Entrez la localisation'),
              const SizedBox(height: 16),

              _buildDropdownField('Type de carburant', _selectedFuelType, ['Essence', 'Diesel', 'Électrique', 'Hybride'], (value) {
                setState(() {
                  _selectedFuelType = value;
                });
              }),
              const SizedBox(height: 16),

              _buildDropdownField('Type de véhicule', _selectedVehicleType, ['SUV', 'Berline', 'Compacte', '4X4', 'Sport'], (value) {
                setState(() {
                  _selectedVehicleType = value;
                });
              }),
              const SizedBox(height: 16),

              _buildDropdownField('Transmission', _selectedTransmission, ['Automatique', 'Manuelle'], (value) {
                setState(() {
                  _selectedTransmission = value;
                });
              }),
              const SizedBox(height: 16),
              _buildDropdownFieldBool("Disponibilité", _availableController, (bool? newValue) {
                  setState(() {
                    _availableController = newValue;
                  });
                },
              ),

              Text('Images actuelles', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildImageGallery(),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickNewImages, // Fonction pour ajouter une nouvelle image
                icon: Icon(Icons.add_a_photo, color: Colors.white),
                label: Text('Ajouter une image', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),

              const SizedBox(height: 16),

              // ✅ Affichage des nouvelles images sélectionnées
              _buildNewImagesPreview(),

              const SizedBox(height: 16),

              // ✅ Bouton pour envoyer les nouvelles images au backend
              ElevatedButton(
                onPressed: _saveNewImages,
                child: Text('Enregistrer les photos'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Sauvegarder les modifications', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label, String hint) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDropdownField(String label, String? selectedValue, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownFieldBool(String label, bool? selectedValue, Function(bool?) onChanged) {
    return DropdownButtonFormField<bool>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: [
        DropdownMenuItem(value: true, child: Text("Oui")),  // True -> "Oui"
        DropdownMenuItem(value: false, child: Text("Non")), // False -> "Non"
      ],
      onChanged: onChanged,
    );
  }


  Widget _buildImageGallery() {
    return _vehicleImages.isEmpty
        ? Text("Aucune image disponible")
        : Wrap(
      spacing: 8,
      children: _vehicleImages.map((image) {
        return Stack(
          alignment: Alignment.topRight,
          children: [
            Image.network(image, height: 100, width: 100, fit: BoxFit.cover),
            IconButton(
              icon: Icon(Icons.cancel, color: Colors.red),
              onPressed: () => _removeImage(image),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ✅ Fonction pour afficher un dialogue de confirmation avant suppression
  void _confirmDeleteVehicle() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmer la suppression"),
          content: Text("Voulez-vous vraiment supprimer ce véhicule ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: _deleteVehicle,
              child: Text("Supprimer", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ✅ Fonction pour choisir des images avec ImagePicker
  Future<void> _pickNewImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedImages = await picker.pickMultiImage(); // Sélection multiple

    if (pickedImages != null) {
      setState(() {
        _newImages.addAll(pickedImages);
      });
    }
  }

  // ✅ Fonction pour afficher les nouvelles images sélectionnées
  Widget _buildNewImagesPreview() {
    return Wrap(
      spacing: 8,
      children: _newImages.map((image) {
        return Stack(
          alignment: Alignment.topRight,
          children: [
            Image.file(File(image.path), height: 100, width: 100, fit: BoxFit.cover),
            IconButton(
              icon: Icon(Icons.cancel, color: Colors.red),
              onPressed: () => setState(() {
                _newImages.remove(image);
              }),
            ),
          ],
        );
      }).toList(),
    );
  }




  void _removeImage(String imageUrl) {
    setState(() {
      _vehicleImages.remove(imageUrl);
    });
  }

/* void _saveChanges() {
    // Logique pour sauvegarder les modifications
    print("Modifications enregistrées !");
  }*/
}
