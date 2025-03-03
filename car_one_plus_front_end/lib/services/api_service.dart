import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "http://192.168.54.149:5000";

  // Connexion de l'utilisateur
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/login");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data["access_token"]);
        return {
          "message": data["message"],
          "user": data["user"],
          "access_token": data["access_token"]
        };
      } else {
        final data = jsonDecode(response.body);
        return {"error": data["message"]};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }

  // Inscription de l'utilisateur
  Future<Map<String, dynamic>> register(String email, String password, String prenom, String nom, String telephone, String role) async {
    final url = Uri.parse("$baseUrl/auth/register");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "prenom": prenom,
          "nom": nom,
          "telephone": telephone,
          "role": role
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          "message": data["message"],
          "role": data["role"]
        };
      } else {
        final data = jsonDecode(response.body);
        return {"error": data["message"]};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }

  // Récupérer le profil utilisateur
  Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse("$baseUrl/auth/profile");
    final token = await getToken();

    if (token == null) {
      return {"error": "No token found. Please login again."};
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
        final data = jsonDecode(response.body);
        return {
          "email": data["email"],
          "prenom": data["prenom"],
          "nom": data["nom"],
          "telephone": data["telephone"],
          "role": data["role"],
          "photo_url": data["photo_url"],
          "created_at": data["created_at"]
        };
      } else {
        final data = jsonDecode(response.body);
        return {"error": data["message"]};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }

  // Demander la réinitialisation du mot de passe
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    final url = Uri.parse("$baseUrl/auth/request-reset");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"message": data["message"]};
      } else {
        return {"error": data["message"]};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }

  // Vérifier le code de réinitialisation
  Future<Map<String, dynamic>> verifyResetCode(String code) async {
    final url = Uri.parse("$baseUrl/auth/verify-reset-code");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"code": code}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"message": data["message"], "user_id": data["user_id"]};
      } else {
        return {"error": data["message"]};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }

  // Réinitialiser le mot de passe
  Future<Map<String, dynamic>> resetPassword(int userId, String newPassword, String confirmPassword) async {
    final url = Uri.parse("$baseUrl/auth/reset-password");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "new_password": newPassword,
          "confirm_password": confirmPassword
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"message": data["message"]};
      } else {
        return {"error": data["message"]};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }


  // 📤 Téléverser une photo de profil
  Future<Map<String, dynamic>> uploadPhoto(File imageFile) async {
    final url = Uri.parse("$baseUrl/auth/upload-photo");
    final token = await getToken();

    if (token == null) {
      return {"error": "Token manquant. Veuillez vous reconnecter."};
    }

    var request = http.MultipartRequest("POST", url)
      ..headers["Authorization"] = "Bearer $token"
      ..files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decodedData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return decodedData; // { "message": "Photo uploaded successfully", "file_path": "URL" }
      } else {
        return {"error": decodedData["message"] ?? "Erreur lors de l'upload"};
      }
    } catch (e) {
      return {"error": "Échec de l'upload: $e"};
    }
  }

  // ✏️ Mettre à jour le profil utilisateur
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updatedData) async {
    final url = Uri.parse("$baseUrl/auth/update");
    final token = await getToken();

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
        body: jsonEncode(updatedData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data; // { "message": "Profile updated successfully" }
      } else {
        return {"error": data["message"] ?? "Erreur de mise à jour"};
      }
    } catch (e) {
      return {"error": "Une erreur est survenue: $e"};
    }
  }


  // Déconnexion de l'utilisateur
  Future<Map<String, dynamic>> logout() async {
    final url = Uri.parse("$baseUrl/auth/logout");
    final token = await getToken();

    if (token == null) {
      return {"error": "No token found. Please login again."};
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await _clearToken();
        return {"message": data["message"]};
      } else {
        return {"error": data["message"]};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }

  // Supprimer le compte utilisateur
  Future<Map<String, dynamic>> deleteAccount() async {
    final url = Uri.parse("$baseUrl/auth/delete");
    final token = await getToken();

    if (token == null) {
      return {"error": "No token found. Please login again."};
    }

    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 204) {
        await _clearToken();
        return {"message": "Account deleted successfully."};
      } else {
        final data = jsonDecode(response.body);
        return {"error": data["message"]};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }

  // Sauvegarder le token JWT localement
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Récupérer le token JWT
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Effacer le token JWT
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
