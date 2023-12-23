import 'package:flutter/material.dart';
import 'package:fyspot/app/core/spotify_api.dart';
import 'package:fyspot/app/core/spotify_service.dart';
import 'package:fyspot/app/models/spotify_player.dart';
import 'package:fyspot/app/utils/app_colors.dart';
import 'package:fyspot/app/widgets/player_widget.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = TextEditingController();
  var playerState = SpotifyPlayer(artist: '', musicName: '', playing: false);

  @override
  void initState() {
    super.initState();
    service.addPlayerListener((player) {
      setState(() => playerState = player);
    });
  }

  SpotifyService get service => context.read<SpotifyService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      cursorColor: AppColors.primaryText,
                      style: const TextStyle(
                          fontSize: 20, color: AppColors.primaryText),
                      decoration: InputDecoration(
                        isDense: true,
                        hintStyle: const TextStyle(
                            fontSize: 20, color: AppColors.secondaryText),
                        hintText: 'Buscar música',
                        fillColor: AppColors.container,
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.container),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.container),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: controller,
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => onSearch(controller.text),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const Spacer(),
              PlayerWidget(
                playerState: playerState,
                onPlayPause: playerState.playing ? service.pause : service.play,
                onPrevious: service.previous,
                onNext: service.next,
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  void onSearch(String musicName) async {
    context.read<SpotifyApi>().getMusicUri(musicName).then((uri) {
      if (uri == null) return;
      service.play(uri: uri);
    });
  }
}
