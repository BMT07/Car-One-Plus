import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';
import 'api_service.dart';

class ReviewService {
  final String baseUrl = "http://192.168.42.156:5000";
  ApiService apiService = ApiService();

  //ReviewService({required this.baseUrl});

 /* Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }*/

  // Créer un nouvel avis
  Future<Map<String, dynamic>> createReview({
    required int vehicleId,
    required int rating,
    required String comment,
  }) async {

    final token = await apiService.getToken();
    if (token == null) {
      throw Exception('Vous devez être connecté pour laisser un avis');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/reviews/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'vehicle_id': vehicleId,
        'rating': rating,
        'comment': comment,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Échec lors de la création de l\'avis');
    }
  }

  // Récupérer les avis d'un véhicule
  Future<Map<String, dynamic>> getVehicleReviews({
    required int vehicleId,
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reviews/vehicles/$vehicleId/reviews?page=$page&per_page=$perPage'),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Échec lors de la récupération des avis');
    }
  }

  // Récupérer les avis d'un utilisateur
  Future<Map<String, dynamic>> getUserReviews({
    required int userId,
    int page = 1,
    int perPage = 10,
  }) async {
    final token = await apiService.getToken();
    if (token == null) {
      throw Exception('Vous devez être connecté pour voir vos avis');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/reviews/users/$userId/reviews?page=$page&per_page=$perPage'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Échec lors de la récupération des avis');
    }
  }

  // Mettre à jour un avis
  Future<Map<String, dynamic>> updateReview({
    required int reviewId,
    int? rating,
    String? comment,
  }) async {
    final token = await apiService.getToken();
    if (token == null) {
      throw Exception('Vous devez être connecté pour modifier un avis');
    }

    final Map<String, dynamic> body = {};
    if (rating != null) body['rating'] = rating;
    if (comment != null) body['comment'] = comment;

    final response = await http.put(
      Uri.parse('$baseUrl/reviews/update/$reviewId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Échec lors de la mise à jour de l\'avis');
    }
  }

  // Supprimer un avis
  Future<Map<String, dynamic>> deleteReview(int reviewId) async {
    final token = await apiService.getToken();
    if (token == null) {
      throw Exception('Vous devez être connecté pour supprimer un avis');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/reviews/delete/$reviewId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Échec lors de la suppression de l\'avis');
    }
  }
}