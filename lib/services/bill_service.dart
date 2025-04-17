import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BillService {
  final String projectId = dotenv.env['PROJECT_ID'] ?? '';
  final String apiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';

  Future<List<Map<String, dynamic>>> fetchBills() async {
    final url = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/bills?key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<Map<String, dynamic>> bills = [];

      for (var doc in decoded['documents'] ?? []) {
        final fields = doc['fields'];

        var purchaseList = (fields['purchaseList']?['arrayValue']?['values'] ?? []).map<Map<String, dynamic>>((item) {
          var productCategory = item['mapValue']['fields']['productCategory']?['stringValue'] ?? '';
          var productName = item['mapValue']['fields']['productName']?['stringValue'] ?? '';
          var price = double.tryParse(fields['mapValue']?['fields']?['price']?['doubleValue'].toString() ?? '0') ?? 0.0;
          var quantity = int.tryParse(item['mapValue']['fields']['quantity']?['integerValue'] ?? '0') ?? 0;
          var total = double.tryParse(fields['mapValue']?['fields']?['total']?['doubleValue'].toString() ?? '0') ?? 0.0;

          return {
            'productCategory': productCategory,
            'productName': productName,
            'price': price,
            'quantity': quantity,
            'total': total,
          };
        }).toList();

        final rawDate = fields['billDate']?['stringValue'];
        String formattedDate = '';
        if (rawDate != null) {
          final parsedDate = DateTime.tryParse(rawDate);
          if (parsedDate != null) {
            formattedDate = '${parsedDate.year.toString().padLeft(4, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
          }
        }

        bills.add({
          'customerName': fields['customerName']?['stringValue'] ?? '',
          'mobileNumber': fields['mobileNumber']?['stringValue'] ?? '',
          'date': formattedDate,
          'payStatus': fields['payStatus']?['C'] ?? '',
          'paymentMethod': fields['paymentMethod']?['stringValue'] ?? '',
          'amount': double.tryParse(fields['totalAmount']?['doubleValue']?.toString() ?? '0') ?? 0.0,
          'purchaseList': purchaseList,
        });
      }

      return bills;
    } else {
      throw Exception('Failed to fetch bills: ${response.body}');
    }
  }
}
