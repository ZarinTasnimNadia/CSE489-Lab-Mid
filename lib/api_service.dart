// api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'landmark.dart';

const String _kBaseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

class ApiService {
  

  Future<List<Landmark>> fetchLandmarks() async {
    final response = await http.get(Uri.parse(_kBaseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      
      return jsonList
          .map((json) => Landmark.fromJson(json))
          .where((lm) => lm.lat != 0.0 && lm.lon != 0.0)
          .toList();
    } else {
      throw Exception('Failed to load landmarks. Status code: ${response.statusCode}');
    }
  }


  Future<void> deleteLandmark(int id) async {
    final response = await http.delete(
      Uri.parse('$_kBaseUrl?id=$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete landmark. Status code: ${response.statusCode}');
    }
  }
  


  Future<void> createLandmark({
    required String title,
    required double lat,
    required double lon,
    required String imageFilePath, 
  }) async {

    final request = http.MultipartRequest('POST', Uri.parse(_kBaseUrl));
    

    request.fields['title'] = title;
    request.fields['lat'] = lat.toString();
    request.fields['lon'] = lon.toString();
    

    request.files.add(await http.MultipartFile.fromPath(
      'image', // Field name for the image
      imageFilePath,
      contentType: MediaType('image', 'jpeg'), 
    ));


    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {

      return; 
    } else {
      throw Exception('Failed to create landmark. Status code: ${response.statusCode}. Body: ${response.body}');
    }
  }

  Future<void> updateLandmark({
    required int id,
    required String title,

    required double lat,
    required double lon,
    String? imageFilePath, 
  }) async {

    final Map<String, dynamic> data = {
      'id': id.toString(),
      'title': title,
      'lat': lat.toString(),
      'lon': lon.toString(),
    };

    if (imageFilePath != null && imageFilePath.isNotEmpty) {

      
      final request = http.MultipartRequest('POST', Uri.parse(_kBaseUrl)); 
      

      data['_method'] = 'PUT'; 
      

      request.fields.addAll(data.map((key, value) => MapEntry(key, value.toString())));

      request.files.add(await http.MultipartFile.fromPath(
        'image', 
        imageFilePath,
        contentType: MediaType('image', 'jpeg'),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Failed to update landmark (Multipart/Override). Status code: ${response.statusCode}. Body: ${response.body}');
      }
      
    } else {

      
      final response = await http.put(
        Uri.parse(_kBaseUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },

        body: data.keys.map((key) => '$key=${Uri.encodeComponent(data[key].toString())}').join('&'),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update landmark (Text-only). Status code: ${response.statusCode}. Body: ${response.body}');
      }
    }
  }
}