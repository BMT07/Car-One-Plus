import 'package:flutter/material.dart';

class ReservationScreen extends StatelessWidget {
  // Liste simulée des réservations actuelles
  final List<Map<String, String>> currentReservations = [
    {"title": "Réservation 1", "date": "20 janvier 2025"},
    {"title": "Réservation 2", "date": "25 janvier 2025"},
  ];

  // Liste simulée des réservations passées
  final List<Map<String, String>> pastReservations = [
    {"title": "Réservation 3", "date": "10 janvier 2025"},
    {"title": "Réservation 4", "date": "5 janvier 2025"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section des réservations actuelles
              const Text(
                "Réservations Actuelles",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              currentReservations.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentReservations.length,
                itemBuilder: (context, index) {
                  return ReservationCard(
                    title: currentReservations[index]['title']!,
                    date: currentReservations[index]['date']!,
                    isPast: false,
                  );
                },
              )
                  : const Text("Aucune réservation actuelle."),
              const SizedBox(height: 20),

              // Section des réservations passées
              const Text(
                "Réservations Passées",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              pastReservations.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pastReservations.length,
                itemBuilder: (context, index) {
                  return ReservationCard(
                    title: pastReservations[index]['title']!,
                    date: pastReservations[index]['date']!,
                    isPast: true,
                  );
                },
              )
                  : const Text("Aucune réservation passée."),
            ],
          ),
        ),
      ),
    );
  }
}

class ReservationCard extends StatelessWidget {
  final String title;
  final String date;
  final bool isPast;

  const ReservationCard({
    Key? key,
    required this.title,
    required this.date,
    required this.isPast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icône à gauche
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPast ? Colors.grey[200] : Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPast ? Icons.history : Icons.calendar_today,
                color: isPast ? Colors.grey : Colors.blue,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // Informations sur la réservation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Date : $date",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Statut à droite
            Text(
              isPast ? "Passée" : "Active",
              style: TextStyle(
                color: isPast ? Colors.grey : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

