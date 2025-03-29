import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;
  String? _message;

  final List<String> _roles = ['proprietaire', 'locateur'];
  String _selectedRole = 'locateur';

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      _showErrorSnackBar("Vous devez accepter les conditions générales.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prenom = _prenomController.text.trim();
      final nom = _nomController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();
      final role = _selectedRole;

      final result = await _apiService.register(email, password, prenom, nom, phone, role);

      if (result["error"] != null) {
        _showErrorSnackBar(result["error"]);
      } else {
        _showSuccessSnackBar("Inscription réussie ! Redirection vers la connexion...");
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar("Une erreur s'est produite. Veuillez réessayer.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir l'orientation et les dimensions de l'écran
    final orientation = MediaQuery.of(context).orientation;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = orientation == Orientation.landscape;

    // Définir une largeur maximale pour le formulaire
    final formWidth = isTablet
        ? screenSize.width * 0.6
        : screenSize.width;

    // Adapter le padding en fonction de la taille de l'écran
    final horizontalPadding = isTablet ? 64.0 : 24.0;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 16.0;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: formWidth,
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 16.0, horizontalPadding, bottomPadding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 32),
                          _buildFormFields(context, isTablet, isLandscape),
                          const SizedBox(height: 16),
                          _buildTermsCheckbox(),
                          const SizedBox(height: 24),
                          _buildRegisterButton(),
                          const SizedBox(height: 16),
                          _buildGuestAndLoginSection(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Logo ou icône (optionnel)
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_add,
            size: 32,
            color: Colors.red[700],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "S'inscrire",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Inscrivez-vous et commencez votre voyage vers le niveau suivant",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormFields(BuildContext context, bool isTablet, bool isLandscape) {
    // Adapter la disposition en fonction de l'orientation et de la taille
    if (isLandscape && isTablet) {
      // Pour les tablettes en mode paysage, afficher 2 colonnes
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildNomPrenom(isTablet),
                const SizedBox(height: 16),
                _buildEmailField(),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildPhoneField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildRoleDropdown(),
              ],
            ),
          ),
        ],
      );
    } else {
      // Pour les téléphones ou tablettes en mode portrait
      return Column(
        children: [
          _buildNomPrenom(isTablet),
          const SizedBox(height: 16),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPhoneField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildRoleDropdown(),
        ],
      );
    }
  }

  Widget _buildNomPrenom(bool isTablet) {
    // Adapter la disposition des champs nom et prénom
    return isTablet
        ? Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _prenomController,
            label: 'Prénom',
            icon: Icons.person_outline,
            validator: (value) => value!.isEmpty ? 'Prénom requis' : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            controller: _nomController,
            label: 'Nom',
            icon: Icons.person,
            validator: (value) => value!.isEmpty ? 'Nom requis' : null,
          ),
        ),
      ],
    )
        : Column(
      children: [
        _buildTextField(
          controller: _prenomController,
          label: 'Prénom',
          icon: Icons.person_outline,
          validator: (value) => value!.isEmpty ? 'Prénom requis' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nomController,
          label: 'Nom',
          icon: Icons.person,
          validator: (value) => value!.isEmpty ? 'Nom requis' : null,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      controller: _emailController,
      label: 'Adresse email',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) return 'Email requis';
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        return !emailRegex.hasMatch(value) ? 'Email invalide' : null;
      },
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      controller: _phoneController,
      label: 'Numéro de téléphone',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value!.isEmpty) return 'Numéro de téléphone requis';
        final phoneRegex = RegExp(r'^[0-9]{10}$');
        return !phoneRegex.hasMatch(value) ? 'Numéro invalide' : null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    IconData? icon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade700, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildPasswordField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'Mot de passe',
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade700, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) return 'Mot de passe requis';
          if (value.length < 8) return 'Minimum 8 caractères';
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        decoration: InputDecoration(
          labelText: 'Type de Compte',
          prefixIcon: const Icon(Icons.account_circle_outlined, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: _roles.map((role) {
          return DropdownMenuItem(
            value: role,
            child: Text(
              role == 'proprietaire' ? 'Propriétaire' : 'Locataire',
              style: const TextStyle(color: Colors.black87),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedRole = value!;
          });
        },
        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        isExpanded: true,
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: CheckboxListTile(
        title: RichText(
          text: TextSpan(
            text: "J'accepte les ",
            style: const TextStyle(color: Colors.black87),
            children: [
              TextSpan(
                text: "Conditions Générales",
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Afficher les conditions générales
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Conditions Générales"),
                        content: const SingleChildScrollView(
                          child: Text(
                            "Ceci est un exemple de conditions générales. Veuillez lire attentivement avant d'accepter.",
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Fermer"),
                          ),
                        ],
                      ),
                    );
                  },
              ),
            ],
          ),
        ),
        value: _acceptTerms,
        onChanged: (value) {
          setState(() {
            _acceptTerms = value!;
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Colors.red.shade700,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )
            : const Text(
          "S'inscrire",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildGuestAndLoginSection() {
    return Column(
      children: [
        TextButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/main'),
          icon: const Icon(Icons.login_outlined, size: 18),
          label: Text(
            'Continuer en tant qu\'invité',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            text: "Vous avez déjà un compte ? ",
            style: const TextStyle(color: Colors.black87),
            children: [
              TextSpan(
                text: "Se connecter",
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Navigator.pushNamed(context, '/login'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}