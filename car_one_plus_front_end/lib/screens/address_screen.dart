import 'package:flutter/material.dart';

class AddressScreen extends StatelessWidget {
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Votre adresse"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: "Entrez votre adresse",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final address = _addressController.text;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Adresse enregistrée : $address"),
                  ),
                );
              },
              child: const Text("Valider"),
            ),
          ],
        ),
      ),
    );
  }
}
