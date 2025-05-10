// lib/service/company_profile_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CompanyProfileService {
   final projectId = dotenv.env['PROJECT_ID'] ?? '';
    final apiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';

  CompanyProfileService();

  // Fetch Owner details
Future<Map<String, String>?> fetchShopDetails() async {
  final url = Uri.parse(
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/shopDetails?key=$apiKey',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    print("responsen $decoded");

    if (decoded.containsKey('documents') && decoded['documents'] is List && decoded['documents'].isNotEmpty) {
      final document = decoded['documents'][0];  // Assuming you're only fetching one document
      final fields = document['fields'];
      return {
        'shopName': fields['shopName']?['stringValue'] ?? '',
        'mobileNumber': fields['mobileNumber']?['stringValue'] ?? '',
        'address': fields['address']?['stringValue'] ?? '',
        'logo': fields['logo']?['stringValue'] ?? '',   // include logo too if needed
      };
    }
  }

  return null; // No data
}

  // Upload Owner details
  Future<bool> uploadShopDetails({
    required String shopName,
    required String mobileNumber,
    required String address,
    required String logoUrl,
  }) async {
   final url = Uri.parse(
  'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/shopDetails?key=$apiKey',
);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "fields": {
          "shopName": {"stringValue": shopName},
          "mobileNumber": {"stringValue": mobileNumber},
          "address": {"stringValue": address},
          "logo": {"stringValue": logoUrl},
        },
      }),
    );

    print('Status code: ${response.statusCode}');
print('Response body: ${response.body}');


    return response.statusCode == 200;
  }
}
