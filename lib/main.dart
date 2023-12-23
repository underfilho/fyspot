import 'package:flutter/material.dart';
import 'package:fyspot/app/core/spotify_api.dart';
import 'package:fyspot/app/core/spotify_service.dart';
import 'package:fyspot/app/home_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final spotifyService = await SpotifyService.init();
  runApp(MainApp(spotifyService: spotifyService));
}

class MainApp extends StatelessWidget {
  final SpotifyService spotifyService;

  const MainApp({super.key, required this.spotifyService});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: spotifyService,
      child: Provider(
        create: (_) => SpotifyApi(spotifyService),
        child: const MaterialApp(
          home: HomePage(),
        ),
      ),
    );
  }
}
