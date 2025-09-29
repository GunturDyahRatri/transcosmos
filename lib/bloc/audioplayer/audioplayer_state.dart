part of 'audioplayer_cubit.dart';

class AudioPlayerState {
  final Surah? currentSurah;
  final Duration duration;
  final Duration position;
  final bool isPlaying;

  AudioPlayerState({
    this.currentSurah,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.isPlaying = false,
  });

  AudioPlayerState copyWith({
    Surah? currentSurah,
    Duration? duration,
    Duration? position,
    bool? isPlaying,
  }) {
    return AudioPlayerState(
      currentSurah: currentSurah ?? this.currentSurah,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}
