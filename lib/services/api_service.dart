import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fintech_app/utils/global_error_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/sharedPrefernce.dart';


class ApiService {
  late Dio _dio;
  String? sessionCookie;
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
       // String? token = await SharedPreferencesUtil.getString("auth_token");
       //  if (token != null) {
       //    options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
       //  }
        print('Request: ${options.method} ${options.uri}');
        print('Headers 1: ${options.headers}');
        print('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response code 1: ${response.statusCode}');
        print('Response Data 2: ${response.data}');
        print('Response header xxx izzzzz 2: ${response.headers.toString()}');
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
        options: await _getOptions(token,"GET"),
      );
      _handleResponse(response);
      return response;
    } on DioException catch (e) {
      if(context.mounted){
        if (e is DioException) {
          if (e.type == DioExceptionType.connectionError) {
            handleGlobalError(context, e);
            //rethrow;
          }else if (e.type == DioExceptionType.connectionTimeout) {
            handleGlobalError(context, e);
            //rethrow;
          }else if (e.type == DioExceptionType.receiveTimeout) {
            handleGlobalError(context, e);
            //rethrow;
          }else if (e.type == DioExceptionType.badResponse) {
            handleGlobalError(context, e);
            //rethrow;
          }else{
          handleGlobalError(context, e);}
         // rethrow;
        }
       // handleGlobalError(context, e);
      }
     rethrow;
    }
  }

  Future<Response> post( BuildContext context, String endpoint, Map<String, dynamic> data, String? token) async {
   var dat = jsonEncode(data);
    try {
      final response = await _dio.post(
        endpoint,
        data: dat,
      //  options: _getOptions(token),
        options: await _getOptions(token,"POST"),
      );
      if (response.statusCode == 200){
        // Extract session cookie
        List<String>? cookies = response.headers['set-cookie'];
        if (cookies != null && cookies.isNotEmpty) {
          for (String cookie in cookies) {
            if (cookie.contains('PHPSESSID')) {
              int index = cookie.indexOf(';');
              sessionCookie = (index == -1) ? cookie : cookie.substring(0, index);
              await SharedPreferencesUtil.saveString("sessionCookie", sessionCookie);
              break;
            }
          }
        }
      }

      _handleResponse(response);
      return response;
    } on DioException catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionError) {
          handleGlobalError(context, e);
          //rethrow;
        }else if (e.type == DioExceptionType.connectionTimeout) {
          handleGlobalError(context, e);
          //rethrow;
         }else if (e.type == DioExceptionType.badResponse) {
          print("gggggggggggggggggggggggggggggggggggggggggggggggg");
          handleGlobalError(context, e);
          //rethrow;
        }else if (e.type == DioExceptionType.unknown) {
          handleGlobalError(context, e);
          //rethrow;
        }else{
          handleGlobalError(context, e);}
        // rethrow;
      }
      handleGlobalError(context, e);
      rethrow;
      //throw _handleError(e);
    }
  }

  Future<Options> _getOptions(String? token, String method) async {
    String? prefsSessionCookie = await SharedPreferencesUtil.getString("sessionCookie");
    print("Token being sent: $token");
    print("sessionid being sent: $prefsSessionCookie");

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      'Content-Type': 'application/json',
    };

    if (prefsSessionCookie != null && prefsSessionCookie.isNotEmpty) {
      headers['Cookie'] = prefsSessionCookie??"";
    }

    return Options(
      followRedirects: false,
      method: method,
      headers: headers,
    );
  }

  Future<void> _handleResponse(Response response) async {
    if (response.statusCode != 200) {
      if (response.statusCode == 400) {
        var  jsondata = jsonDecode(response.data);
        throw BadRequestException('Bad request ohh: ');
      }else if (response.statusCode == 401) {
       var prefs = await SharedPreferencesUtil.getInstance();
       prefs.remove("auth_token");
       prefs.remove("sessionCookie");
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