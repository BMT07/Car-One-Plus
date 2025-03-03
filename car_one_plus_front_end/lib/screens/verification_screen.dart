import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../services/api_service.dart'; // Assurez-vous d'importer ApiService
import 'change_password_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String email; // Ajout de l'email pour l'affichage

  VerificationScreen({required this.email});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  final ApiService _apiService = ApiService(); // Instance du service API
  bool _isLoading = false;

  void _verifyCode() async {
    final code = otpController.text.trim();

    if (code.isEmpty || code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez entrer un code à 6 chiffres")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await _apiService.verifyResetCode(code);

    setState(() {
      _isLoading = false;
    });

    if (response.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["error"], style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    } else {
      final userId = response["user_id"];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePasswordScreen(userId: userId),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Code vérifié avec succès !", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              "Vérification",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            Text(
              "Nous avons envoyé un code à 6 chiffres à votre adresse e-mail.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Text(
              "Code envoyé à ${widget.email}", // Affichage de l'email réel
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 20),

            // 📌 Champs OTP
            PinCodeTextField(
              appContext: context,
              length: 6,
              obscureText: false,
              animationType: AnimationType.fade,
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
                inactiveColor: Colors.grey.shade300,
                activeColor: Colors.red,
                selectedColor: Colors.red.shade700,
              ),
              cursorColor: Colors.black,
              controller: otpController,
              keyboardType: TextInputType.number,
              onChanged: (value) {},
            ),
            const SizedBox(height: 30),

            // 📌 Bouton de vérification
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                "Vérifier",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // 📌 Option de renvoi du code
            TextButton(
              onPressed: () {
                // Action pour renvoyer le code
              },
              child: Text(
                "Vous n’avez pas reçu le code ? Renvoyer",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
