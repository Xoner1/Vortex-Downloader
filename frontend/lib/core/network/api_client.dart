import 'package:dio/dio.dart';
import 'dart:math';
import '../constants.dart';

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Simplified headers after Vercel protection disabled
          // Keeping User-Agent to help yt-dlp
          options.headers['User-Agent'] = _getRandomSafariUserAgent();
          return handler.next(options);
        },
      ),
    );
  }

  Dio get client => _dio;

  String _getRandomSafariUserAgent() {
    final agents = [
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15',
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
      'Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    ];
    return agents[Random().nextInt(agents.length)];
  }
}
