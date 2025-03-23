import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service_vehicle.dart';

class VehicleProvider extends ChangeNotifier {
  bool isLoading = false;
  List<dynamic> vehicles = [];
  List<dynamic> vehiclesOfOwner = [];

  final ApiServiceVehicle _apiServiceVehicle = ApiServiceVehicle();

  // ✅ Charger la liste des véhicules depuis SharedPreferences
  Future<void> loadVehicles() async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final vehiclesData = prefs.getString('vehicles');

    if (vehiclesData != null) {
      vehicles = List<dynamic>.from(await _decodeJson(vehiclesData));
    } else {
      vehicles = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // ✅ Mettre à jour la liste des véhicules en récupérant depuis l'API
  Future<void> updateVehicles() async {
    final response = await _apiServiceVehicle.getVehiclesAvailable();

    if (response.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      vehicles = response;

      await prefs.setString('vehicles', await _encodeJson(vehicles));

      notifyListeners();
    }
  }

  // ✅ Charger la liste des véhicules depuis SharedPreferences
  Future<void> loadOwnerVehicles() async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final vehiclesData = prefs.getString('OwnerVehicles');

    if (vehiclesData != null) {
      vehiclesOfOwner = List<dynamic>.from(await _decodeJson(vehiclesData));
    } else {
      vehiclesOfOwner = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // ✅ Mettre à jour la liste des véhicules en récupérant depuis l'API
  Future<void> getOwnerVehicles() async {
    final response = await _apiServiceVehicle.getVehiclesOfOwner();

    if (response.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      vehiclesOfOwner = response;
      print(vehiclesOfOwner);
      await prefs.setString('OwnerVehicles', await _encodeJson(vehiclesOfOwner));

      notifyListeners();
    }
  }

  // ✅ Effacer les données locales des véhicules (ex: lors de la déconnexion)
  Future<void> clearVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vehicles');

    vehicles = [];
    notifyListeners();
  }

  // ✅ Ajouter un véhicule
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
    isLoading = true;
    notifyListeners();

    final response = await _apiServiceVehicle.addVehicle(
      title,
      description,
      pricePerDay,
      localisation,
      puissance,
      typeDeCarburant,
      typeDeVehicule,
      vitesse,
      transmission,
      nbreSieges
    );

    if (!response.containsKey("error")) {
      await updateVehicles(); // Rafraîchir la liste
    }

    isLoading = false;
    notifyListeners();

    return response;
  }

  Future<Map<String,dynamic>> getVehicleById(int vehicleId) async{

    isLoading = true;
    notifyListeners();

    final response = await _apiServiceVehicle.getVehicleById(vehicleId);

    print(response);

    isLoading = false;
    notifyListeners();

    return response;

  }

  // ✅ Modifier un véhicule
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
      bool available) async {
    isLoading = true;
    notifyListeners();

    final response = await _apiServiceVehicle.updateVehicle(
      vehicleId,
      title,
      description,
      pricePerDay,
      localisation,
      puissance,
      typeDeCarburant,
      typeDeVehicule,
      vitesse,
      transmission,
      nbreSieges,
      available,
    );

    if (!response.containsKey("error")) {
      await updateVehicles();
    }

    isLoading = false;
    notifyListeners();

    return response;
  }

  // ✅ Supprimer un véhicule
  Future<Map<String, dynamic>> deleteVehicle(int vehicleId) async {
    isLoading = true;
    notifyListeners();

    final response = await _apiServiceVehicle.deleteVehicle(vehicleId);

    if (!response.containsKey("error")) {
      vehicles.removeWhere((vehicle) => vehicle["id"] == vehicleId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vehicles', await _encodeJson(vehicles));
    }

    isLoading = false;
    notifyListeners();

    return response;
  }

  // ✅ Ajouter des photos à un véhicule
  Future<Map<String, dynamic>> addVehiclePhotos(int vehicleId, File image) async {
    isLoading = true;
    notifyListeners();

    final response = await _apiServiceVehicle.uploadVehicleImage(vehicleId, image);

    if (!response.containsKey("error")) {
      await updateVehicles(); // Mettre à jour la liste des véhicules après ajout des photos
    }

    isLoading = false;
    notifyListeners();

    return response;
  }

  // 🔹 Helper pour encoder/décoder JSON proprement
  Future<String> _encodeJson(List<dynamic> data) async {
    return jsonEncode(data);
  }

  Future<List<dynamic>> _decodeJson(String jsonStr) async {
    return jsonDecode(jsonStr);
  }
 /* Future<String> _encodeJson(List<dynamic> data) async {
    return Future.value(data.toString());
  }

  Future<List<dynamic>> _decodeJson(String jsonStr) async {
    return Future.value(jsonStr.isNotEmpty ? List<dynamic>.from(jsonStr.split(',')) : []);
  }*/
}
