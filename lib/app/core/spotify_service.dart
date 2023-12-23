import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fyspot/app/models/spotify_player.dart';

typedef PlayerCallback = void Function(SpotifyPlayer player);

class SpotifyService {
  static const MethodChannel _channel = MethodChannel('spotify');
  static const EventChannel _eventChannel = EventChannel('spotify_player');

  final listeners = <PlayerCallback>[];
  late final Stream _playerStream;
  late final String _token;

  SpotifyService._();

  String get token => _token;

  static Future<SpotifyService> init() async {
    final i = SpotifyService._();
    await _channel.invokeMethod('initSpotify');
    await i.getSpotifyToken();

    i._playerStream = _eventChannel.receiveBroadcastStream();

    return i;
  }

  void addPlayerListener(PlayerCallback listener) {
    if (listeners.isEmpty) _playerStream.listen(_onPlayerEvent);
    listeners.add(listener);
  }

  void _onPlayerEvent(event) {
    final json = jsonDecode(event);
    if (json['track'] == null) return;

    listeners.forEach((listener) => listener(SpotifyPlayer.fromJson(json)));
  }

  Future<String?> getSpotifyToken() async =>
      _token = await _channel.invokeMethod('getSpotifyToken');
  Future<void> play({String? uri}) =>
      _channel.invokeMethod('play', {'uri': uri});
  Future<void> pause() => _channel.invokeMethod('pause');
  Future<void> previous() => _channel.invokeMethod('previous');
  Future<void> next() => _channel.invokeMethod('next');
  Future<void> stop() => _channel.invokeMethod('stop');
}
