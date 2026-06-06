import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Shared HTTP client with a consistent request timeout.
class ApiClient {
  static const Duration timeout = Duration(seconds: 30);

  static Future<http.Response> get(Uri uri, {Map<String, String>? headers}) {
    return http.get(uri, headers: headers).timeout(timeout);
  }

  static Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return http.post(uri, headers: headers, body: body).timeout(timeout);
  }

  static bool isNetworkError(Object error) {
    return error is TimeoutException ||
        error is SocketException ||
        error is HandshakeException ||
        error is http.ClientException;
  }
}
