import 'package:flutter/material.dart';

class UserChoiceScreen extends StatelessWidget {
  const UserChoiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Retour à l'écran précédent
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Bouton "Créer un compte"
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Couleur de fond
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/register'); // Naviguer vers l'écran d'inscription
              },
              child: const Text(
                'Créer un compte',
                style: TextStyle(
                  color: Colors.white, // Couleur du texte
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Bouton "Continuer avec Google"
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Fond blanc
                side: const BorderSide(color: Colors.grey), // Bordure grise
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Action pour continuer avec Google
              },
              icon: Image.asset(
                'assets/images/google_logo.png', // Assurez-vous d'avoir cette image dans vos assets
                height: 24,
                width: 24,
              ),
              label: const Text(
                'Continuer avec Google',
                style: TextStyle(
                  color: Colors.black, // Texte noir
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Lien "Déjà membre ? Se connecter"
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login'); // Naviguer vers l'écran de connexion
              },
              child: const Text(
                'Déjà membre ? Se connecter',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  decoration: TextDecoration.underline, // Texte souligné
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
