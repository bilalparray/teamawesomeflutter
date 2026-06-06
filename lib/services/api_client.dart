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

  static Future<http.Response> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return http.put(uri, headers: headers, body: body).timeout(timeout);
  }

  static Future<http.Response> delete(Uri uri, {Map<String, String>? headers}) {
    return http.delete(uri, headers: headers).timeout(timeout);
  }

  static Future<http.Response> postMultipart({
    required Uri uri,
    required String fileField,
    required List<int> fileBytes,
    required String filename,
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    final request = http.MultipartRequest('POST', uri);
    if (headers != null) request.headers.addAll(headers);
    request.files.add(
      http.MultipartFile.fromBytes(
        fileField,
        fileBytes,
        filename: filename,
      ),
    );
    if (fields != null) request.fields.addAll(fields);

    final streamed = await request.send().timeout(timeout);
    return http.Response.fromStream(streamed);
  }

  static bool isNetworkError(Object error) {
    return error is TimeoutException ||
        error is SocketException ||
        error is HandshakeException ||
        error is http.ClientException;
  }
}
