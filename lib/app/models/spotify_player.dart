class SpotifyPlayer {
  final String artist;
  final String musicName;
  final bool playing;

  SpotifyPlayer({
    required this.artist,
    required this.musicName,
    required this.playing,
  });

  SpotifyPlayer.fromJson(Map<String, dynamic> json)
      : artist = json['track']['artist']['name'],
        musicName = json['track']['name'],
        playing = !json['is_paused'];
}
