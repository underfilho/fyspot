import 'package:flutter/material.dart';
import 'package:fyspot/app/models/spotify_player.dart';
import 'package:fyspot/app/utils/app_colors.dart';

class PlayerWidget extends StatelessWidget {
  final SpotifyPlayer playerState;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const PlayerWidget({
    super.key,
    required this.playerState,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          playerState.musicName,
          style: const TextStyle(fontSize: 28, color: AppColors.primaryText),
        ),
        const SizedBox(height: 5),
        Text(
          playerState.artist,
          style: const TextStyle(fontSize: 24, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: onPrevious,
              child: const Icon(
                Icons.skip_previous,
                color: AppColors.accent,
                size: 35,
              ),
            ),
            GestureDetector(
              onTap: onPlayPause,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
                child: Center(
                  child: Icon(
                    playerState.playing ? Icons.pause : Icons.play_arrow,
                    color: AppColors.primaryText,
                    size: 40,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: onNext,
              child: const Icon(
                Icons.skip_next,
                color: AppColors.accent,
                size: 35,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
