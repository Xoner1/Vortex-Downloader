import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/media_model.dart';

abstract class MediaRemoteDataSource {
  Future<MediaModel> extractMedia(String url);
}

class MediaRemoteDataSourceImpl implements MediaRemoteDataSource {
  final ApiClient apiClient;

  MediaRemoteDataSourceImpl(this.apiClient);

  @override
  Future<MediaModel> extractMedia(String url) async {
    try {
      final response = await apiClient.client.post(
        '/api/extract',
        data: {'url': url},
      );

      if (response.statusCode == 200) {
        if (response.data is Map && response.data.containsKey('error')) {
          throw Exception(response.data['error']);
        }
        return MediaModel.fromJson(response.data);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network Error: ${e.message}');
    }
  }
}
