import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:quran_audio/data/model/surah.dart';

part 'audioplayer_state.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayerCubit() : super(AudioPlayerState()) {
    _audioPlayer.onDurationChanged.listen((d) {
      emit(state.copyWith(duration: d));
    });
    _audioPlayer.onPositionChanged.listen((p) {
      emit(state.copyWith(position: p));
    });
    _audioPlayer.onPlayerStateChanged.listen((s) {
      emit(state.copyWith(isPlaying: s == PlayerState.playing));
    });
  }

  Future<void> play(Surah surah) async {
    await _audioPlayer.play(UrlSource(surah.audio ?? ""));
    emit(state.copyWith(currentSurah: surah));
  }

  Future<void> toggle() async {
    if (state.isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> seek(Duration pos) async {
    await _audioPlayer.seek(pos);
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    emit(state.copyWith(position: Duration.zero, isPlaying: false));
  }
}
