import 'package:dio/dio.dart';
import 'dart:math';

class ApiClient {
  static const String baseUrl = 'https://vortex-downloader-nh6sa471q-xoner1s-projects.vercel.app';
  final Dio _dio;

  ApiClient() : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Robust Browser Headers to bypass Vercel/YouTube 401s
          options.headers.addAll({
            'User-Agent': _getRandomSafariUserAgent(),
            'Accept': 'application/json, text/plain, */*',
            'Accept-Language': 'en-US,en;q=0.9',
            'Connection': 'keep-alive',
            'Sec-Fetch-Dest': 'empty',
            'Sec-Fetch-Mode': 'cors',
            'Sec-Fetch-Site': 'cross-site',
            'Origin': baseUrl,
            'Referer': '$baseUrl/',
          });
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
