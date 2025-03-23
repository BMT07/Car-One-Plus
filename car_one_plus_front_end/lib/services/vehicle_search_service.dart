import 'dart:convert';
import 'package:http/http.dart' as http;

class VehicleSearchService {
  final String baseUrl = "http://192.168.42.156:5000";

  //VehicleSearchService({required this.baseUrl});

  Future<Map<String, dynamic>> searchVehicles({
    String? localisation,
    double? minPrice,
    double? maxPrice,
    String? typeDeVehicle,
    bool? available,
    int limit = 10,
    int offset = 0,
  }) async {
    // Construire l'URL avec les paramètres de recherche
    final uri = Uri.parse("$baseUrl/vehicles/list").replace(
      queryParameters: {
        if (localisation != null && localisation.isNotEmpty) 'localisation': localisation,
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
        if(typeDeVehicle!=null) 'type_de_vehicule' : typeDeVehicle,
        if (available != null) 'available': available.toString(),
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return {
          'vehicles': jsonData['vehicles'] ?? [],
          'total': jsonData['total'] ?? 0,
          'limit': jsonData['limit'] ?? limit,
          'offset': jsonData['offset'] ?? offset,
        };
      } else {
        return {
          'vehicles': [],
          'total': 0,
          'limit': limit,
          'offset': offset,
          'error': 'Erreur ${response.statusCode}: ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      return {
        'vehicles': [],
        'total': 0,
        'limit': limit,
        'offset': offset,
        'error': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }
}