class Vehicle {
  final int id;
  final int ownerId;
  final String title;
  final String description;
  final double pricePerDay;
  final String localisation;
  final String puissance;
  final String typeDeCarburant;
  final String typeDeVehicule;
  final String vitesse;
  final String transmission;
  final int nbreSieges;
  final double? lat;
  final double? lng;
  final bool available;
  final String createdAt;
  final List<String> images;

  Vehicle({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.pricePerDay,
    required this.localisation,
    required this.puissance,
    required this.typeDeCarburant,
    required this.typeDeVehicule,
    required this.vitesse,
    required this.transmission,
    required this.nbreSieges,
    this.lat,
    this.lng,
    required this.available,
    required this.createdAt,
    required this.images,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      ownerId: json['owner_id'],
      title: json['title'] ?? 'Sans titre',
      description: json['description'] ?? '',
      pricePerDay: json['price_per_day'] is String
          ? double.parse(json['price_per_day'])
          : json['price_per_day'].toDouble(),
      localisation: json['localisation'] ?? 'Localisation inconnue',
      puissance: json['puissance'] ?? '',
      typeDeCarburant: json['type_de_carburant'] ?? '',
      typeDeVehicule: json['type_de_vehicule'] ?? '',
      vitesse: json['vitesse'] ?? '',
      transmission: json['transmission'] ?? '',
      nbreSieges: json['nbreSieges'] ?? 0,
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
      available: json['available'] ?? false,
      createdAt: json['created_at'] ?? '',
      images: (json['images'] as List?)?.map((img) => img.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'price_per_day': pricePerDay,
      'localisation': localisation,
      'puissance': puissance,
      'type_de_carburant': typeDeCarburant,
      'type_de_vehicule': typeDeVehicule,
      'vitesse': vitesse,
      'transmission': transmission,
      'nbreSieges': nbreSieges,
      'lat': lat,
      'lng': lng,
      'available': available,
      'created_at': createdAt,
      'images': images,
    };
  }

  String get mainImage {
    return images.isNotEmpty ? images.first : '';
  }
}