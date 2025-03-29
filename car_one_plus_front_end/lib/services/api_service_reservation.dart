import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class ApiReservationService {
  final String baseUrl = "http://192.168.42.156:5000";
  final ApiService apiService = ApiService();

  /* 📌 Récupérer le token JWT stocké localement
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }*/

  // ✅ Créer une réservation
  Future<Map<String, dynamic>> createReservation(int vehicleId, String startDate, String endDate) async {
    final url = Uri.parse("$baseUrl/reservations/");
    final token = await apiService.getToken();

    if (token == null) {
      return {"error": "Vous devez être connecté pour effectuer une réservation."};
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "vehicle_id": vehicleId,
          "start_date": startDate,
          "end_date": endDate
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {"message": "Réservation créée avec succès", "reservation": data};
      } else {
        final data = jsonDecode(response.body);
        return {"error": data["message"]};
      }
    } catch (e) {
      return {"error": "Une erreur est survenue : $e"};
    }
  }

  // 📌 Récupérer les réservations d'un utilisateur
  Future<List<dynamic>> getUserReservations() async {
    final url = Uri.parse("$baseUrl/reservations/");
    final token = await apiService.getToken();

    if (token == null) {
      return [];
    }

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // 📌 Récupérer les réservations des véhicules appartenant à l'utilisateur
  Future<List<dynamic>> getOwnerReservations() async {
    final url = Uri.parse("$baseUrl/reservations/owner");
    final token = await apiService.getToken();

    if (token == null) {
      return [];
    }

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // ✅ Mettre à jour le statut d'une réservation
  Future<Map<String, dynamic>> updateReservationStatus(int reservationId, String newStatus) async {
    final url = Uri.parse("$baseUrl/reservations/$reservationId/status");
    final token = await apiService.getToken();

    if (token == null) {
      return {"error": "Vous devez être connecté pour modifier une réservation."};
    }

    try {
      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"status": newStatus}),
      );

      if (response.statusCode == 200) {
        return {"message": "Statut mis à jour avec succès"};
      } else {
        final data = jsonDecode(response.body);
        return {"error": data["message"]};
      }
    } catch (e) {
      return {"error": "Une erreur est survenue : $e"};
    }
  }

  // 🔹 Supprimer une reservation par le reserveur
  Future<Map<String, dynamic>> deleteReservationByOwner(int reservationId) async {
    final url = Uri.parse("$baseUrl/reservations/delete/by_reservation_owner/$reservationId");
    final token = await apiService.getToken();

    if (token == null) {
      return {"error": "Token manquant. Veuillez vous reconnecter."};
    }

    try {
      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return {"message": "Véhicule supprimé avec succès"};
      } else {
        return {"error": jsonDecode(response.body)["message"]};
      }
    } catch (e) {
      return {"error": "Erreur: $e"};
    }
  }

  // 🔹 Supprimer une Reservation par le proprio du vehicule
  Future<Map<String, dynamic>> deleteReservationByVehicleOwner(int reservationId) async {
    final url = Uri.parse("$baseUrl/reservations/delete/by_vehicle_owner/$reservationId");
    final token = await apiService.getToken();

    if (token == null) {
      return {"error": "Token manquant. Veuillez vous reconnecter."};
    }

    try {
      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return {"message": "Véhicule supprimé avec succès"};
      } else {
        return {"error": jsonDecode(response.body)["message"]};
      }
    } catch (e) {
      return {"error": "Erreur: $e"};
    }
  }

}
