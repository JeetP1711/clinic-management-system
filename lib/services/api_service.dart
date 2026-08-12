import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clinicos/core/constants/app_constants.dart';

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? (json['success'] == true ? 'Success' : 'An error occurred'),
      data: json['data'],
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(success: false, message: message);
  }
}

class ApiService {
  final String baseUrl;

  ApiService({String? url}) : baseUrl = url ?? AppConstants.googleAppsScriptUrl;

  Future<ApiResponse> post(String action, Map<String, dynamic> payload) async {
    if (baseUrl.contains('YOUR_APPS_SCRIPT_WEB_APP_URL_HERE')) {
      return ApiResponse.error(
        'Google Apps Script URL not configured. Please follow setup instructions to deploy your backend.',
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'action': action,
              ...payload,
            }),
          )
          .timeout(const Duration(seconds: 35));

      if (response.statusCode == 200 || response.statusCode == 302) {
        final decoded = jsonDecode(response.body);
        return ApiResponse.fromJson(decoded);
      } else {
        return ApiResponse.error(
            'Server error (${response.statusCode}): ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return ApiResponse.error(
            'Connection timed out. Please check your internet connection.');
      }
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse> get(String action, [Map<String, String>? params]) async {
    if (baseUrl.contains('YOUR_APPS_SCRIPT_WEB_APP_URL_HERE')) {
      return ApiResponse.error(
        'Google Apps Script URL not configured. Please follow setup instructions to deploy your backend.',
      );
    }

    try {
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'action': action,
          ...?params,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 35));

      if (response.statusCode == 200 || response.statusCode == 302) {
        final decoded = jsonDecode(response.body);
        return ApiResponse.fromJson(decoded);
      } else {
        return ApiResponse.error(
            'Server error (${response.statusCode}): ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return ApiResponse.error(
            'Connection timed out. Please check your internet connection.');
      }
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}
