import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';

class AddVehicleScreen extends StatefulWidget {
  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Champs obligatoires
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _localisationController = TextEditingController();
  final TextEditingController _puissanceController = TextEditingController();

  // Champs optionnels
  final TextEditingController _vitesseController = TextEditingController();
  final TextEditingController _nbreSiegesController = TextEditingController();

  String? _selectedCarburant;
  String? _selectedTypeVehicule;
  String? _selectedTransmission;

  final List<String> _carburants = ['Essence', 'Diesel', 'Électrique', 'Hybride'];
  final List<String> _typesVehicule = ['SUV', 'Berline', 'Compacte', '4X4', 'Sport'];
  final List<String> _transmissions = ['Automatique', 'Manuelle'];

  /*List<File> _selectedImages = []; // Stocke les images sélectionnées

  final ImagePicker _picker = ImagePicker();


  // Fonction pour sélectionner plusieurs images
  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  // Fonction pour supprimer une image sélectionnée
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }*/

  void _addVehicle() async {
    if (_formKey.currentState!.validate()) {
      final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);

      String title = _titleController.text;
      String description = _descriptionController.text;
      double pricePerDay = double.parse(_priceController.text);
      String localisation = _localisationController.text;
      String puissance = _puissanceController.text;
      String vitesse = _vitesseController.text;
      int nbreSieges = int.parse(_nbreSiegesController.text);
      String typeDeCarburant = _selectedCarburant!;
      String typeDeVehicule = _selectedTypeVehicule!;
      String transmission = _selectedTransmission!;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      final response = await vehicleProvider.addVehicle(
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
      );

      Navigator.pop(context);

      if (response.containsKey("error")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${response['error']}"), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Véhicule ajouté avec succès"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    }
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
          'Ajouter un véhicule',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_titleController, 'Nom du véhicule *', 'Exemple : Toyota Corolla'),
                const SizedBox(height: 16),

                _buildTextField(_descriptionController, 'Description *', 'Exemple : Automatique, Diesel, 5 places', maxLines: 3),
                const SizedBox(height: 16),

                _buildNumberField(_priceController, 'Prix par jour (€) *', 'Exemple : 50'),
                const SizedBox(height: 16),

                _buildTextField(_localisationController, 'Localisation *', 'Exemple : Bamako, Mali'),
                const SizedBox(height: 16),

                _buildTextField(_puissanceController, 'Puissance (CV) *', 'Exemple : 120 CV'),
                const SizedBox(height: 16),

                _buildNumberField(_nbreSiegesController, 'Nombre de siege *', 'Exemple : 7', required: false),
                const SizedBox(height: 16),

                _buildDropdownField('Type de carburant *', _selectedCarburant, _carburants, (value) {
                  setState(() => _selectedCarburant = value);
                }),
                const SizedBox(height: 16),

                _buildDropdownField('Type de véhicule *', _selectedTypeVehicule, _typesVehicule, (value) {
                  setState(() => _selectedTypeVehicule = value);
                }),
                const SizedBox(height: 16),

                // Champs optionnels (Pas de validation requise)
                _buildDropdownField('Transmission (optionnel)', _selectedTransmission, _transmissions, (value) {
                  setState(() => _selectedTransmission = value);
                }),
                const SizedBox(height: 16),

                _buildTextField(_vitesseController, 'Vitesse maximale (km/h) (optionnel)', 'Exemple : 220', required: false),
                const SizedBox(height: 32),

                /* Bouton pour sélectionner des images
                Text('Photos du véhicule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Ajouter des images'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Affichage des images sélectionnées
                _selectedImages.isNotEmpty
                    ? SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(_selectedImages[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
                    : Text('Aucune image sélectionnée', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),*/

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addVehicle,
                    /*() {
                      if (_formKey.currentState!.validate()) {
                        print('Titre: ${_titleController.text}');
                        print('Description: ${_descriptionController.text}');
                        print('Prix: ${_priceController.text}€');
                        print('Localisation: ${_localisationController.text}');
                        print('Puissance: ${_puissanceController.text} CV');
                        print('Carburant: $_selectedCarburant');
                        print('Type de véhicule: $_selectedTypeVehicule');
                        print('Transmission: $_selectedTransmission');
                        print('Vitesse: ${_vitesseController.text.isEmpty ? "Non spécifiée" : "${_vitesseController.text} km/h"}');
                        //print('Images sélectionnées: ${_selectedImages.length}');

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Véhicule ajouté avec succès')),
                        );
                      }
                    }*/
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Ajouter le véhicule',
                      style: TextStyle(fontSize: 16, color: Colors.white),
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

  // Champ de texte (obligatoire par défaut)
  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1, bool required = true}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
    );
  }

  // Champ numérique (obligatoire par défaut)
  Widget _buildNumberField(TextEditingController controller, String label, String hint, {bool required = true}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value!.isEmpty && required) return 'Champ obligatoire';
        if (value.isNotEmpty && double.tryParse(value) == null) return 'Entrez un nombre valide';
        return null;
      },
    );
  }

  // Champ de sélection (obligatoire par défaut)
  Widget _buildDropdownField(String label, String? selectedValue, List<String> items, Function(String?) onChanged, {bool required = true}) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: items
          .map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) => (value == null && required) ? 'Sélectionnez une option' : null,
    );
  }
}
