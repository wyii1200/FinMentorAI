import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your actual Firebase Function Base URL from the Firebase Console
  static const String baseUrl = 'https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net';

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Note: If you enable authMiddleware in backend, 
          // you must add 'Authorization': 'Bearer $idToken' here.
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to connect to backend');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}