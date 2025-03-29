import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final int userId;
  const ChangePasswordScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Clé globale pour gérer le formulaire
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de texte
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Instance du service API
  final ApiService _apiService = ApiService();

  // États de l'interface
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Méthode de validation du mot de passe
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir un mot de passe';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    // Validation complexe du mot de passe
    if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(value)) {
      return 'Le mot de passe doit contenir des majuscules, minuscules, chiffres et symboles';
    }
    return null;
  }

  // Méthode de réinitialisation du mot de passe
  void _resetPassword() async {
    // Fermer le clavier avant de valider le formulaire
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final newPassword = _newPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (newPassword != confirmPassword) {
        _showErrorDialog('Les mots de passe ne correspondent pas');
        setState(() => _isLoading = false);
        return;
      }

      try {
        final response = await _apiService.resetPassword(
            widget.userId,
            newPassword,
            confirmPassword
        );

        setState(() => _isLoading = false);

        if (response.containsKey("error")) {
          _showErrorDialog(response["error"]);
        } else {
          _showSuccessDialog("Mot de passe réinitialisé avec succès");
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorDialog("Une erreur s'est produite. Veuillez réessayer.");
      }
    }
  }

  // Méthode pour afficher une boîte de dialogue d'erreur
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Erreur', style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  // Méthode pour afficher une boîte de dialogue de succès
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Succès', style: TextStyle(color: Colors.green)),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Retour à l'écran précédent
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Utilisation de GestureDetector pour détecter les taps en dehors des champs
    return GestureDetector(
      // Fermer le clavier quand on tape en dehors des champs
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Changer le mot de passe', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth > 600 ? 64.0 : 24.0,
                      vertical: 24.0
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nouveau mot de passe',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Créez un mot de passe fort avec au moins 8 caractères',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 32),
                        // Champ de mot de passe principal
                        _buildPasswordField(
                          controller: _newPasswordController,
                          hintText: 'Nouveau mot de passe',
                          obscureText: _obscureNewPassword,
                          onToggleVisibility: () => setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          }),
                          validator: _validatePassword,
                        ),
                        SizedBox(height: 16),
                        // Champ de confirmation de mot de passe
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirmer le mot de passe',
                          obscureText: _obscureConfirmPassword,
                          onToggleVisibility: () => setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          }),
                          validator: (value) {
                            // Validation de la correspondance des mots de passe
                            if (value != _newPasswordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 32),
                        // Bouton de soumission
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Méthode de construction du champ de mot de passe
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        // Bouton de visibilité du mot de passe
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggleVisibility,
        ),
        errorStyle: TextStyle(color: Colors.red),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      validator: validator,
    );
  }

  // Méthode de construction du bouton de soumission
  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _resetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? CupertinoActivityIndicator(color: Colors.white)
            : Text(
          'Sauvegarder',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Libération des ressources
  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}