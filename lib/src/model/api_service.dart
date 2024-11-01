import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "http://192.168.43.71:8000/api/v1"; // Ganti dengan base URL API Anda

  // Fungsi untuk menambahkan header authentication opsional
  Map<String, String> _getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // Jika token disediakan, tambahkan ke header Authorization
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Contoh method GET dengan optional authentication header
  Future<Map<String, dynamic>> getData(String endpoint, {String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return json.decode(response.body);
    }
  }

  // Contoh method POST dengan optional authentication header
  Future<Map<String, dynamic>> postData(
      String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _getHeaders(token: token),
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return json.decode(response.body);
      // throw Exception('Failed to post data ' + response.statusCode.toString());
    }
  }

  // Method lain seperti PUT, DELETE bisa ditambahkan sesuai kebutuhan
}
