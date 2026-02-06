import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://samyak000-nutrition-barcode.hf.space";

  static Future<Map<String, dynamic>> fetchProductByBarcode(
      String barcode) async {
    try {
      final url = Uri.parse("$baseUrl/scan/$barcode");
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception("Server error ${response.statusCode}");
      }

      return {
        "success": true,
        "data": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }
}
