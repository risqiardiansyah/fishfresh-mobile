import 'package:flutter/material.dart';
import 'api_service.dart';

class DataProvider with ChangeNotifier {
  final ApiService apiService = ApiService();
  Map<String, dynamic> _data = {};
  bool _isLoading = false;

  Map<String, dynamic> get data => _data;
  bool get isLoading => _isLoading;

  // Fungsi untuk fetch data dari API dengan token opsional
  Future<void> fetchData(String endpoint, {String? token}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedData = await apiService.getData(endpoint, token: token);
      _data = fetchedData;
    } catch (error) {
      print("Error fetching data: $error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi untuk post data ke API dengan token opsional
  Future<void> postData(String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final postedData =
          await apiService.postData(endpoint, body, token: token);
      // if (postedData['success']) {
      _data = postedData;
      // }
    } catch (error) {
      print("Error posting data: $error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _data = {};
    } catch (error) {
      print("Error posting data: $error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
