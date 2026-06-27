import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
  
  // Add logging interceptors in debug mode
  dio.interceptors.add(LogInterceptor(
    requestHeader: false,
    responseHeader: false,
    requestBody: true,
    responseBody: true,
  ));

  return dio;
});
