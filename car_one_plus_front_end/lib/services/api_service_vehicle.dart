import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class ApiServiceVehicle {
  final String baseUrl = "http://192.168.54.149:5000";
  ApiService apiService = ApiService();

  // 🔹 Récupérer la liste des véhicules
  Future<List<dynamic>> getVehicles() async {
    final url = Uri.parse("$baseUrl/vehicles/list");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData["vehicles"] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // 🔹 Récupérer la liste des véhicules disponibles
  Future<List<dynamic>> getVehiclesAvailable() async {
    final url = Uri.parse("$baseUrl/vehicles/available_vehicles");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return  jsonData["vehicles"] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // 🔹 Récupérer un véhicule par son ID
  Future<Map<String, dynamic>?> getVehicleById(int vehicleId) async {
    final url = Uri.parse("$baseUrl/vehicles/$vehicleId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // 🔹 Ajouter un véhicule
  Future<Map<String, dynamic>> addVehicle(
      String title,
      String description,
      double pricePerDay,
      String localisation,
      String puissance,
      String typeDeCarburant,
      String typeDeVehicule,
      String vitesse,
      String transmission,
      int nbreSieges) async {
    final url = Uri.parse("$baseUrl/vehicles/add");
    final token = await apiService.getToken();

    if (token == null) {
      return {"error": "Token manquant. Veuillez vous reconnecter."};
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "title": title,
          "description": description,
          "price_per_day": pricePerDay,
          "localisation": localisation,
          "puissance": puissance,
          "type_de_carburant": typeDeCarburant,
          "type_de_vehicule": typeDeVehicule,
          "vitesse": vitesse,
          "transmission": transmission,
          "nbreSieges": nbreSieges
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {"error": jsonDecode(response.body)["message"]};
      }
    } catch (e) {
      return {"error": "Erreur: $e"};
    }
  }

  // 🔹 Modifier un véhicule
  Future<Map<String, dynamic>> updateVehicle(
      int vehicleId,
      String title,
      String description,
      double pricePerDay,
      String localisation,
      String puissance,
      String typeDeCarburant,
      String typeDeVehicule,
      String vitesse,
      String transmission,
      int nbreSieges,
      bool available,) async {
    final url = Uri.parse("$baseUrl/vehicles/update/$vehicleId");
    final token = await apiService.getToken();

    if (token == null) {
      return {"error": "Token manquant. Veuillez vous reconnecter."};
    }

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "title": title,
          "description": description,
          "price_per_day": pricePerDay,
          "localisation": localisation,
          "puissance": puissance,
          "type_de_carburant": typeDeCarburant,
          "type_de_vehicule": typeDeVehicule,
          "vitesse": vitesse,
          "transmission": transmission,
          "nbreSieges": nbreSieges,
          "available": available
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": jsonDecode(response.body)["message"]};
      }
    } catch (e) {
      return {"error": "Erreur: $e"};
    }
  }

  // 🔹 Supprimer un véhicule
  Future<Map<String, dynamic>> deleteVehicle(int vehicleId) async {
    final url = Uri.parse("$baseUrl/vehicles/delete/$vehicleId");
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

  // 🔹 Téléverser une image pour un véhicule
  Future<Map<String, dynamic>> uploadVehicleImage(int vehicleId, File imageFile) async {
    final url = Uri.parse("$baseUrl/vehicles/upload_image");
    final token = await apiService.getToken();

    if (token == null) {
      return {"error": "Token manquant. Veuillez vous reconnecter."};
    }

    var request = http.MultipartRequest("POST", url)
      ..headers["Authorization"] = "Bearer $token"
      ..fields["vehicle_id"] = vehicleId.toString()
      ..files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decodedData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return decodedData; // { "message": "Image uploadée avec succès", "file_path": "URL" }
      } else {
        return {"error": decodedData["message"] ?? "Erreur lors de l'upload"};
      }
    } catch (e) {
      return {"error": "Échec de l'upload: $e"};
    }
  }

  // 📌 Gestion des tokens
  /*Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }*/
}
