import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fintech_app/main.dart';
import 'package:fintech_app/utils/global_error_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/sharedPrefernce.dart';


class ApiService {
  late Dio _dio;

  ApiService() {
    String baseUrl = _getBaseUrl();

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) {
        return status! < 500; // Accept all status codes less than 500
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async{
        String? token = await SharedPreferencesUtil.getString("auth_token");
        if (token != null) {
          options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
        }
        print('Request: ${options.method} ${options.uri}');
        print('Headers: ${options.headers}');
        print('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response code 1: ${response.statusCode}');
        print('Response Data 2: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('Error: ${e.message}');
        print('Error Response: ${e.response?.data}');
        return handler.next(e);
      },
    ));
  }

  String _getBaseUrl() {
    if (kIsWeb) return 'https://www.axmpay.com/api/v1/';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return 'https://www.axmpay.com/app/api/v1/';
       // return 'https://www.axmpay.com/api/v1/';
      default:
        return 'https://www.axmpay.com/app/api/v1/';
    }
  }

  // Future<Response> get(String endpoint, String? token) async {
  //   try {
  //     final response = await _dio.get(
  //       endpoint,
  //     options: _getOptions(token),
  //     );
  //     _handleResponse(response);
  //     return response;
  //   } on DioException catch (e) {
  //     if (!_isShowingErrorDialog) {
  //       _isShowingErrorDialog = true;
  //       handleGlobalError(navigatorKey.currentContext!, e).then((_) {
  //         _isShowingErrorDialog = false;
  //       });
  //     }
  //     rethrow;
  //     //throw _handleError(e);
  //   }
  // }

  Future<Response> get(BuildContext context, String endpoint, String? token) async {
    try {
      final response = await _dio.get(
        endpoint,
        options: _getOptions(token),
      );
      _handleResponse(response);
      return response;
    } on DioException catch (e) {
      handleGlobalError(context, e);
      rethrow;
    }
  }

  Future<Response> post(String endpoint, Map<String, dynamic> data, String? token) async {
   var dat = jsonEncode(data);
    try {
      final response = await _dio.post(
        endpoint,
        data: dat,
      //  options: _getOptions(token),
        options: _getOptions(token),
      );

      _handleResponse(response);
      return response;
    } on DioException catch (e) {
      handleGlobalError(navigatorKey.currentContext!, e);
      rethrow;
      //throw _handleError(e);
    }
  }

  Options _getOptions(String? token) {
    print("Token being sent: $token");
    return Options(
      followRedirects: false,
      method: "GET",
      headers: token !=null ?{
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
        'Content-Type': 'application/json',
      }: null,
    );
  }

  Future<String?> poster(String token) async{
    var headers = {
      'authorization': ' Bearer $token'
    };
    var request = http.Request('GET', Uri.parse(
      'https://www.axmpay.com/api/v1/getUserDetails.php'
    ));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode ==200){
      print(await response.stream.bytesToString());
      return response.stream.bytesToString();
    }else {
      print("ohhh, ${response.statusCode}");
      print("ohhh, ${response.headers}");
      print("ohhh, ${response.reasonPhrase}");
      return null;
    }
  }
  void _handleResponse(Response response) {
    if (response.statusCode != 200) {
      if (response.statusCode == 400) {
        var  jsondata = jsonDecode(response.data);
        throw BadRequestException('Bad request ohh: ');
      }else if (response.statusCode == 401) {
        throw TokenExpiredException();
      }

    }
  }

  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return TimeoutException('Connection timed out');
    } else if (e.type == DioExceptionType.badResponse) {
      return HttpException('Server responded with ${e.response?.statusCode}');
    } else {
      return Exception('An error occurred: ${e.message}');
    }
  }
}

bool _isShowingErrorDialog = false;

class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
  @override
  String toString() => message;
}