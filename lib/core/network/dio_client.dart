import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proplus/core/constants/api_config.dart';
import 'package:proplus/core/error/app_exception.dart';
import 'package:proplus/core/error/error_mapper.dart';
import 'dart:convert';
import 'dart:developer' as developer;

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(baseUrl: ApiConfig.baseUrl);
});

class DioClient {
  late final Dio dio;

  DioClient({required String baseUrl}){
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _printRequest(options);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _printResponse(response);
          return handler.next(response);
        },
        onError: (error, handler) {
          _printError(error);
          final exception = DioErrorMapper.map(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: exception,
            ),
          );
        },
      ),
    );
  }

  // ---------- PRETTY PRINT METHODS ----------

  void _printRequest(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.writeln('');
    buffer.writeln('╔═══════════════════════════════════════════════════════════╗');
    buffer.writeln('║                    📤 HTTP REQUEST                        ║');
    buffer.writeln('╠═══════════════════════════════════════════════════════════╣');
    buffer.writeln('║ METHOD: ${options.method}');
    buffer.writeln('║ URL: ${options.baseUrl}${options.path}');
    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('║ QUERY PARAMS:');
      options.queryParameters.forEach((key, value) {
        buffer.writeln('║   ├─ $key: $value');
      });
    }
    if (options.headers.isNotEmpty) {
      buffer.writeln('║ HEADERS:');
      options.headers.forEach((key, value) {
        buffer.writeln('║   ├─ $key: $value');
      });
    }
    if (options.data != null) {
      buffer.writeln('║ BODY:');
      final bodyData = _formatJson(options.data);
      final lines = bodyData.split('\n');
      for (var line in lines) {
        buffer.writeln('║   $line');
      }
    }
    buffer.writeln('╚═══════════════════════════════════════════════════════════╝');
    buffer.writeln('');
    developer.log(buffer.toString());
  }

  void _printResponse(Response response) {
    final buffer = StringBuffer();
    buffer.writeln('');
    buffer.writeln('╔═══════════════════════════════════════════════════════════╗');
    buffer.writeln('║                    📥 HTTP RESPONSE                       ║');
    buffer.writeln('╠═══════════════════════════════════════════════════════════╣');
    buffer.writeln('║ STATUS CODE: ${response.statusCode}');
    buffer.writeln('║ URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}');
    final headersMap = response.headers.map;
    if (headersMap.isNotEmpty) {
      buffer.writeln('║ HEADERS:');
      headersMap.forEach((key, values) {
        buffer.writeln('║   ├─ $key: ${values.join(', ')}');
      });
    }
    if (response.data != null) {
      buffer.writeln('║ BODY:');
      final bodyData = _formatJson(response.data);
      final lines = bodyData.split('\n');
      for (var line in lines) {
        buffer.writeln('║   $line');
      }
    }
    buffer.writeln('╚═══════════════════════════════════════════════════════════╝');
    buffer.writeln('');
    developer.log(buffer.toString());
  }

  void _printError(DioException error) {
    final buffer = StringBuffer();
    buffer.writeln('');
    buffer.writeln('╔═══════════════════════════════════════════════════════════╗');
    buffer.writeln('║                    ❌ HTTP ERROR                          ║');
    buffer.writeln('╠═══════════════════════════════════════════════════════════╣');
    buffer.writeln('║ TYPE: ${error.type}');
    buffer.writeln('║ MESSAGE: ${error.message}');
    buffer.writeln('║ URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
    if (error.response != null) {
      buffer.writeln('║ STATUS CODE: ${error.response?.statusCode}');
      if (error.response?.data != null) {
        buffer.writeln('║ RESPONSE BODY:');
        final bodyData = _formatJson(error.response?.data);
        final lines = bodyData.split('\n');
        for (var line in lines) {
          buffer.writeln('║   $line');
        }
      }
    }
    buffer.writeln('╚═══════════════════════════════════════════════════════════╝');
    buffer.writeln('');
    developer.log(buffer.toString(), name: 'DioClient_Error');
  }

  String _formatJson(dynamic data) {
    try {
      if (data == null) return 'null';
      if (data is String) return data;
      if (data is Map || data is List) {
        final jsonString = jsonEncode(data);
        final jsonObject = jsonDecode(jsonString);
        return JsonEncoder.withIndent('  ').convert(jsonObject);
      }
      return data.toString();
    } catch (e) {
      return data.toString();
    }
  }

  // ---------- HTTP METHODS ----------

  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      return await dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw e.error ?? UnknownException("Unknown error");
    }
  }

  Future<Response<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw e.error ?? UnknownException("Unknown error");
    }
  }

  Future<Response<T>> put<T>(
      String path, {
        dynamic data,
      }) async {
    try {
      return await dio.put<T>(path, data: data);
    } on DioException catch (e) {
      throw e.error ?? UnknownException("Unknown error");
    }
  }

  Future<Response<T>> delete<T>(
      String path,
      ) async {
    try {
      return await dio.delete<T>(path);
    } on DioException catch (e) {
      throw e.error ?? UnknownException("Unknown error");
    }
  }
}

