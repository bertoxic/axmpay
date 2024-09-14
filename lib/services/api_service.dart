import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:AXMPAY/utils/global_error_handler.dart';
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
      handleResponse(response);

      return response;
    } on DioException catch (e) {
      if(context.mounted){
        if (e is TokenExpiredException) {
          handleGlobalError(context, e);
        }
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

  Future<Response> post(BuildContext context, String endpoint, Map<String, dynamic> data, String? token) async {
    try {
      final options = await _getOptions(token, "POST");
      final response = await _dio.post(
        endpoint,
        data: jsonEncode(data),
        options: options,
      );

      await _handleSessionCookie(response);
       handleResponse(response);
      return response;
    } on DioException catch (e) {
      _handleDioException(context, e);
      rethrow;
    } catch (e) {
      handleGlobalError(context, e);
      rethrow;
    }
  }

  Future<Options> _getOptions(String? token, String method) async {
    String? sessionCookie = await SharedPreferencesUtil.getString("sessionCookie");

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      'Content-Type': 'application/json',
    };

    if (sessionCookie != null && sessionCookie.isNotEmpty) {
      headers['Cookie'] = sessionCookie;
    }

    return Options(
      followRedirects: false,
      method: method,
      headers: headers,
    );
  }

  Future<void> _handleSessionCookie(Response response) async {
    if (response.statusCode == 200) {
      List<String>? cookies = response.headers['set-cookie'];
      if (cookies != null && cookies.isNotEmpty) {
        for (String cookie in cookies) {
          if (cookie.contains('PHPSESSID')) {
            int index = cookie.indexOf(';');
            String sessionCookie = (index == -1) ? cookie : cookie.substring(0, index);
            await SharedPreferencesUtil.saveString("sessionCookie", sessionCookie);
            break;
          }
        }
      }
    }
  }

  void _handleDioException(BuildContext context, DioException e) {
    switch (e.type) {
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          handleGlobalError(context, TokenExpiredException(message: 'Your session has expired. Please log in again.'));
        } else {
          handleGlobalError(context, e);
        }
        break;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        handleGlobalError(context, e);
        break;
      default:
        handleGlobalError(context, e);
    }
  }

  void handleResponse(Response response) {
    if (response.statusCode != 200) {
      if (response.statusCode == 400) {
        throw BadRequestException('Bad request: ${response.data}');
      } else if (response.statusCode == 401) {
        SharedPreferencesUtil.getInstance().then((prefs) {
          prefs.remove("authToken");
          prefs.remove("sessionCookie");
        });
        throw TokenExpiredException();
      }
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


bool _isShowingErrorDialog = false;

class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
  @override
  String toString() => message;
}