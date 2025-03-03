import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptTerms = false;
  String? _message;

  // Valeurs pour la liste déroulante des rôles
  String _selectedRole = 'locateur';
  final List<String> _roles = ['proprietaire', 'locateur'];

  void _register() async {
    if (!_acceptTerms) {
      setState(() {
        _message = "Vous devez accepter les conditions générales.";
      });
      return;
    }

    final prenom = _prenomController.text.trim();
    final nom = _nomController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final role = _selectedRole;

    if (prenom.isEmpty || nom.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _message = "Tous les champs sont obligatoires.";
      });
      return;
    }

    // Envoie des données avec le rôle
    final result = await _apiService.register(email, password, prenom, nom, phone, role);

    setState(() {
      if (result["error"] != null) {
        _message = result["error"];
      } else {
        _message = "Inscription réussie ! Redirection vers la connexion...";
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushNamed(context, '/login');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 50),
              Text(
                "S'inscrire",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "Inscrivez-vous et commencez votre voyage vers le niveau suivant",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),

              // Champ Prénom
              TextField(
                controller: _prenomController,
                decoration: InputDecoration(labelText: 'Prénom', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),

              // Champ Nom
              TextField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),

              // Champ Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Adresse email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),

              // Champ Téléphone
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Numéro de téléphone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),

              // Champ Mot de passe
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Liste déroulante pour le rôle
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role[0].toUpperCase() + role.substring(1)), // Capitalise la première lettre
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Sélectionnez un Type de Compte',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Case à cocher pour les conditions générales
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "Je suis d'accord avec ",
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Conditions générales",
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Bouton d'inscription
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("S'inscrire", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              // Affichage des messages d'erreur ou de succès
              if (_message != null) ...[
                SizedBox(height: 10),
                Text(
                  _message!,
                  style: TextStyle(color: _message!.contains("réussie") ? Colors.green : Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],

              SizedBox(height: 16),

              // Navigation pour utilisateur invité
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/main');
                  },
                  child: Text('Utilisateur invité', style: TextStyle(color: Colors.black)),
                ),
              ),
              SizedBox(height: 16),

              // Lien pour se connecter si déjà inscrit
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Vous avez déjà un compte? ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Se connecter",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/login');
                          },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
