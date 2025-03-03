import 'package:flutter/material.dart';

class CarReservationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Réserver une voiture',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildCarInfoCard(),
            SizedBox(height: 24),
            _buildDateTimeSelection('Sélectionnez la date et l\'heure de prise en'),
            SizedBox(height: 16),
            _buildDateTimeSelection('Sélectionnez la date et l\'heure de retour'),
            SizedBox(height: 24),
            Text(
              'Tarif de réservation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildPricingOptions(),
            Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Continuer',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildCarInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                'https://imgd.aeplcdn.com/370x208/n/cw/ec/108943/mini-cooper-right-front-three-quarter.jpeg?isig=0&q=80',
                width: 100,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mini cooper',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('249 km  •  Daily', style: TextStyle(color: Colors.grey)),
                Text('\$72/heure', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildButton('Select Date', Icons.calendar_today),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildButton('Pickup time', Icons.access_time),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(String text, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.black54),
      label: Text(text, style: TextStyle(color: Colors.black54)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildPricingOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPriceOption('Minutes', '0,5\$/min', isSelected: true),
        _buildPriceOption('Heure', '0,5\$/min'),
        _buildPriceOption('Tous les jours', '200\$/jour'),
      ],
    );
  }

  Widget _buildPriceOption(String title, String price, {bool isSelected = false}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.red.shade50 : Colors.white,
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 16)),
            SizedBox(height: 6),
            Text(price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}