// landmark.dart

import 'package:latlong2/latlong.dart';

class Landmark {
  final int id;
  final String title;
  final double lat;
  final double lon;
  final String? imagePath;

  Landmark({
    required this.id,
    required this.title,
    required this.lat,
    required this.lon,
    required this.imagePath,
  });

  
  factory Landmark.fromJson(Map<String, dynamic> json) {
    
    final idValue = int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    final latValue = double.tryParse(json['lat']?.toString() ?? '0.0') ?? 0.0;
    final lonValue = double.tryParse(json['lon']?.toString() ?? '0.0') ?? 0.0;
    
    return Landmark(
      id: idValue,
      title: json['title'] as String,
      lat: latValue,
      lon: lonValue,
      imagePath: json['image'] as String?,
    );
  }

  
  LatLng get coordinates => LatLng(lat, lon);
}