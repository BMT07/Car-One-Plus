import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  // Liste simulée de notifications
  final List<Map<String, String>> notifications = [
    {
      "title": "Order status changed",
      "description": "Your order id status changed to received to delivered",
      "time": "30 seconds ago",
    },
    {
      "title": "Grocery delivery service",
      "description": "A basket overflowing with fresh fruits and vegetables",
      "time": "30 mins ago",
    },
    {
      "title": "Personal meal planning",
      "description": "A colorful plate of food with a variety of ingredients",
      "time": "2 hours ago",
    },
    {
      "title": "Reminders to eat",
      "description": "Lunchtime! Don't forget to fuel up for a productive afternoon.",
      "time": "18 hours ago",
    },
    {
      "title": "Exclusive offer",
      "description": "Enjoy 25% on your next order. Use code HAPPYMONDAY",
      "time": "2 hours ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icône de notification
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.red.withOpacity(0.1),
                      child: Icon(Icons.notifications, color: Colors.red),
                    ),
                    SizedBox(width: 16),
                    // Texte de notification
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification["title"]!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            notification["description"]!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            notification["time"]!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
