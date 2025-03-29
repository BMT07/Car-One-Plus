import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';

class AddVehicleScreen extends StatefulWidget {
  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _isLoading = false;

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

  void _addVehicle() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);

        String title = _titleController.text;
        String description = _descriptionController.text;
        double pricePerDay = double.parse(_priceController.text);
        String localisation = _localisationController.text;
        String puissance = _puissanceController.text;
        String vitesse = _vitesseController.text.isNotEmpty ? _vitesseController.text : '0';
        int nbreSieges = _nbreSiegesController.text.isNotEmpty
            ? int.parse(_nbreSiegesController.text)
            : 0;
        String typeDeCarburant = _selectedCarburant ?? '';
        String typeDeVehicule = _selectedTypeVehicule ?? '';
        String transmission = _selectedTransmission ?? '';

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

        setState(() {
          _isLoading = false;
        });

        if (response.containsKey("error")) {
          _showErrorSnackbar("Erreur : ${response['error']}");
        } else {
          _showSuccessSnackbar("Véhicule ajouté avec succès");
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackbar("Une erreur est survenue: $e");
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _localisationController.dispose();
    _puissanceController.dispose();
    _vitesseController.dispose();
    _nbreSiegesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
        body: SafeArea(
          child: Stack(
            children: [
              Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 6,
                radius: Radius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: BouncingScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section d'en-tête
                          Text(
                            'Informations principales',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                          Divider(height: 24, thickness: 1),

                          _buildAnimatedTextField(_titleController, 'Nom du véhicule *', 'Exemple : Toyota Corolla', Icons.directions_car),
                          const SizedBox(height: 16),

                          _buildAnimatedTextField(
                              _descriptionController,
                              'Description *',
                              'Exemple : Automatique, Diesel, 5 places',
                              Icons.description,
                              maxLines: 3
                          ),
                          const SizedBox(height: 16),

                          _buildAnimatedTextField(
                              _priceController,
                              'Prix par jour (€) *',
                              'Exemple : 50',
                              Icons.euro,
                              keyboardType: TextInputType.number
                          ),
                          const SizedBox(height: 16),

                          _buildAnimatedTextField(
                              _localisationController,
                              'Localisation *',
                              'Exemple : Bamako, Mali',
                              Icons.location_on
                          ),
                          const SizedBox(height: 24),

                          // Section des spécifications techniques
                          Text(
                            'Spécifications techniques',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                          Divider(height: 24, thickness: 1),

                          _buildAnimatedTextField(
                              _puissanceController,
                              'Puissance (CV) *',
                              'Exemple : 120 CV',
                              Icons.speed,
                              keyboardType: TextInputType.number
                          ),
                          const SizedBox(height: 16),

                          _buildAnimatedTextField(
                              _nbreSiegesController,
                              'Nombre de sièges *',
                              'Exemple : 5',
                              Icons.airline_seat_recline_normal,
                              keyboardType: TextInputType.number
                          ),
                          const SizedBox(height: 16),

                          _buildAnimatedDropdownField(
                              'Type de carburant *',
                              _selectedCarburant,
                              _carburants,
                                  (value) {
                                setState(() => _selectedCarburant = value);
                              },
                              Icons.local_gas_station
                          ),
                          const SizedBox(height: 16),

                          _buildAnimatedDropdownField(
                              'Type de véhicule *',
                              _selectedTypeVehicule,
                              _typesVehicule,
                                  (value) {
                                setState(() => _selectedTypeVehicule = value);
                              },
                              Icons.category
                          ),
                          const SizedBox(height: 16),

                          _buildAnimatedDropdownField(
                              'Transmission',
                              _selectedTransmission,
                              _transmissions,
                                  (value) {
                                setState(() => _selectedTransmission = value);
                              },
                              Icons.settings,
                              required: false
                          ),
                          const SizedBox(height: 16),

                          _buildAnimatedTextField(
                              _vitesseController,
                              'Vitesse maximale (km/h)',
                              'Exemple : 220',
                              Icons.speed_outlined,
                              required: false,
                              keyboardType: TextInputType.number
                          ),
                          const SizedBox(height: 32),

                          // Bouton d'ajout
                          SizedBox(
                            width: double.infinity,
                            child: _buildSubmitButton(),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _addVehicle,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[700],
          disabledBackgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
        ),
        child: Text(
          'Ajouter le véhicule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField(
      TextEditingController controller,
      String label,
      String hint,
      IconData icon, {
        int maxLines = 1,
        bool required = true,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.red[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red[700]!, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Ce champ est obligatoire';
          }
          if (keyboardType == TextInputType.number && value!.isNotEmpty) {
            if (double.tryParse(value) == null) {
              return 'Veuillez entrer un nombre valide';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAnimatedDropdownField(
      String label,
      String? selectedValue,
      List<String> items,
      Function(String?) onChanged,
      IconData icon, {
        bool required = true
      }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: DropdownButtonFormField<String>(
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
          prefixIcon: Icon(icon, color: Colors.red[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red[700]!, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) => (value == null && required) ? 'Ce champ est obligatoire' : null,
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Colors.red[700]),
        isExpanded: true,
      ),
    );
  }
}