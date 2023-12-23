import 'package:dio/dio.dart';
import 'package:fyspot/app/core/spotify_service.dart';

const _baseUrl = 'https://api.spotify.com/v1';

class SpotifyApi {
  final SpotifyService _spotifyService;
  late final Dio _dio;

  SpotifyApi(this._spotifyService) {
    _dio = Dio(BaseOptions(baseUrl: _baseUrl, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${_spotifyService.token}'
    }));
  }

  Future<String?> getMusicUri(String musicName) async {
    try {
      const endpoint = '/search';
      final queryParameters = {
        'q': 'track:$musicName',
        'type': 'track',
        'market': 'BR',
        'limit': '1',
      };

      final response =
          await _dio.get(endpoint, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        return response.data['tracks']['items'][0]['uri'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
