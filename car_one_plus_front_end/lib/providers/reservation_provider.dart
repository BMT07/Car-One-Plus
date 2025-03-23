import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service_reservation.dart';

class ReservationProvider extends ChangeNotifier {
  bool isLoading = false;
  List<dynamic> reservations = [];
  List<dynamic> pendingReservations = []; // Réservations en attente
  List<dynamic> confirmedReservations = []; // Réservations confirmées
  List<dynamic> ownerReservations = [];
  List<dynamic> pendingReservationsOwner = []; // Réservations en attente
  List<dynamic> confirmedReservationsOwner = []; // Réservations confirmées

  final ApiReservationService _apiServiceReservation = ApiReservationService();

  // Charger depuis SharedPreferences
  Future<void> loadReservations() async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final reservationsData = prefs.getString('reservations');

    if (reservationsData != null) {
      reservations = List<dynamic>.from(await _decodeJson(reservationsData));
      _filterReservations(); // Séparer les réservations
    } else {
      reservations = [];
      pendingReservations = [];
      confirmedReservations = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // Mettre à jour la liste des réservations
  Future<void> updateReservations() async {
    final response = await _apiServiceReservation.getUserReservations();

    if (response.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      reservations = response;
      await prefs.setString('reservations', await _encodeJson(reservations));

      //_filterReservations(); // Séparer les réservations
      notifyListeners();
    }
  }

  // Charger depuis SharedPreferences reservations pour propriètaire de la voiture
  Future<void> loadOwnerReservations() async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final reservationsData = prefs.getString('ownerReservations');

    if (reservationsData != null) {
      ownerReservations = List<dynamic>.from(await _decodeJson(reservationsData));
      _filterOwnerReservations(); // Séparer les réservations
    } else {
      ownerReservations = [];
      pendingReservationsOwner = [];
      confirmedReservationsOwner = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // Mettre à jour la liste des réservations pour le propriètaire de la voiture
  Future<void> getReservationsforOwner() async {
    final response = await _apiServiceReservation.getOwnerReservations();

    if (response.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      ownerReservations = response;
      await prefs.setString('ownerReservations', await _encodeJson(ownerReservations));

      //_filterReservations(); // Séparer les réservations
      notifyListeners();
    }
  }

  // Filtrer les réservations owner en fonction du statut
  void _filterOwnerReservations() {
    pendingReservationsOwner = ownerReservations.where((r) => r['status'] == "EN ATTENTE").toList();
    confirmedReservationsOwner = ownerReservations.where((r) => r['status'] == "CONFIRMER").toList();
  }


  // Filtrer les réservations en fonction du statut
  void _filterReservations() {
    pendingReservations = reservations.where((r) => r['status'] == "EN ATTENTE").toList();
    confirmedReservations = reservations.where((r) => r['status'] == "CONFIRMER").toList();
  }

  // ✅ Effacer les données locales des réservations (ex: lors de la déconnexion)
  Future<void> clearReservations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reservations');

    reservations = [];
    notifyListeners();
  }

  // ✅ Ajouter une réservation
  Future<Map<String, dynamic>> addReservation(int vehicleId, String startDate, String endDate) async {
    isLoading = true;
    notifyListeners();


    final response = await _apiServiceReservation.createReservation(vehicleId, startDate, endDate);

    if (!response.containsKey("error")) {
      await updateReservations(); // Rafraîchir la liste des réservations

    }

    isLoading = false;
    notifyListeners();

    return response;
  }

  // ✅ Modifier le statut d'une réservation
  Future<Map<String, dynamic>> updateReservationStatus(int reservationId, String newStatus) async {
    isLoading = true;
    notifyListeners();

    final response = await _apiServiceReservation.updateReservationStatus(reservationId, newStatus);

    if (!response.containsKey("error")) {
      await updateReservations();
    }

    isLoading = false;
    notifyListeners();

    return response;
  }

  /* ✅ Supprimer une réservation
  Future<Map<String, dynamic>> deleteReservation(int reservationId) async {
    isLoading = true;
    notifyListeners();

    final response = await _apiServiceReservation.cancelReservation(reservationId);

    if (!response.containsKey("error")) {
      reservations.removeWhere((reservation) => reservation["id"] == reservationId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reservations', await _encodeJson(reservations));
    }

    isLoading = false;
    notifyListeners();

    return response;
  }*/

  // 🔹 Helper pour encoder/décoder JSON proprement
  Future<String> _encodeJson(List<dynamic> data) async {
    return jsonEncode(data);
  }

  Future<List<dynamic>> _decodeJson(String jsonStr) async {
    return jsonDecode(jsonStr);
  }
}
