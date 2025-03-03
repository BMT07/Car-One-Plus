import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {

  bool isLoading = false;
  String userPrenom = "";
  String userNom = "";
  String userEmail = "";
  String userRole = "";
  String userTelephone = "";
  String userPhoto = "assets/images/logo.png"; // ✅ Photo par défaut


  final ApiService _apiService = ApiService();

  // ✅ Charger les données utilisateur depuis SharedPreferences
  Future<void> loadUserData() async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    userPrenom = prefs.getString('user_prenom') ?? "Utilisateur";
    userNom = prefs.getString('user_nom') ?? "";
    userEmail = prefs.getString('user_email') ?? "Email inconnu";
    userRole = prefs.getString('user_role') ?? "locateur";
    userTelephone = prefs.getString('user_telephone') ?? "";
    userPhoto = prefs.getString('user_photo') ?? "assets/images/logo.png";

    isLoading = false;
    notifyListeners(); // 🔄 Notifier les widgets que les données ont changé
  }

  // ✅ Mettre à jour les données après une modification
  Future<void> updateUserData() async {
    final response = await _apiService.getProfile();

    if (!response.containsKey("error")) {
      final prefs = await SharedPreferences.getInstance();

      userPrenom = response["prenom"] ?? userPrenom;
      userNom = response["nom"] ?? userNom;
      userEmail = response["email"] ?? userEmail;
      userRole = response["role"] ?? userRole;
      userTelephone = response["telephone"] ?? userTelephone;
      userPhoto = response["photo_url"] ?? userPhoto;

      await prefs.setString('user_prenom', userPrenom);
      await prefs.setString('user_nom', userNom);
      await prefs.setString('user_email', userEmail);
      await prefs.setString('user_role', userRole);
      await prefs.setString('user_photo', userPhoto);
      await prefs.setString('user_telephone', userTelephone);

      notifyListeners();
    }
  }

  // ✅ Réinitialiser les données utilisateur lors de la déconnexion
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprime toutes les données enregistrées

    // Réinitialisation des variables du provider
    userPrenom = "";
    userNom = "";
    userEmail = "";
    userRole = "";
    userTelephone = "";
    userPhoto = "assets/images/logo.png"; // Remettre la photo par défaut

    notifyListeners(); // 🔄 Notifier les widgets de la mise à jour
  }

}
