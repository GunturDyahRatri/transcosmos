import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/bloc/detail_surah/detail_surah_bloc.dart';
import 'package:quran_audio/data/model/ayat.dart';

class SurahDetailPage extends StatefulWidget {
  final int nomor;

  const SurahDetailPage({super.key, required this.nomor});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;

  @override
  void initState() {
    super.initState();
    // Trigger fetch detail via BLoC
    context.read<SurahDetailBloc>().add(FetchSurahDetail(widget.nomor));

    // Listen audio events
    _durationSub = _audioPlayer.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });
    _positionSub = _audioPlayer.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });
    _stateSub = _audioPlayer.onPlayerStateChanged.listen((s) {
      setState(() => _isPlaying = s == PlayerState.playing);
    });
  }

  Future<void> _play(String url) async {
    await _audioPlayer.play(UrlSource(url));
  }

  Future<void> _pause() async {
    await _audioPlayer.pause();
  }

  Future<void> _stop() async {
    await _audioPlayer.stop();
    setState(() => _position = Duration.zero);
  }

  String _format(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0
        ? "${twoDigits(h)}:${twoDigits(m)}:${twoDigits(s)}"
        : "${twoDigits(m)}:${twoDigits(s)}";
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _stateSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SurahDetailBloc, SurahDetailState>(
        builder: (context, state) {
          if (state is SurahDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SurahDetailLoaded) {
            final SurahDetail surah = state.surahDetail;

            return Column(
              children: [
                // Info + Player
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${surah.namaLatin} (${surah.nama})",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Arti: ${surah.arti}"),
                      Text("Jumlah Ayat: ${surah.jumlahAyat}"),
                      Text("Turun di: ${surah.tempatTurun}"),
                      const SizedBox(height: 10),
                      // Audio Player Controls
                      Column(
                        children: [
                          Slider(
                            min: 0,
                            max: _duration.inSeconds.toDouble(),
                            value:
                                _position.inSeconds
                                    .clamp(0, _duration.inSeconds.toDouble())
                                    .toDouble(),
                            onChanged: (value) async {
                              final seekPos = Duration(seconds: value.toInt());
                              await _audioPlayer.seek(seekPos);
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_format(_position)),
                              Text(_format(_duration)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                ),
                                onPressed: () {
                                  if (_isPlaying) {
                                    _pause();
                                  } else {
                                    _play(surah.audio);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.stop),
                                onPressed: _stop,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // List Ayat
                Expanded(
                  child: ListView.builder(
                    itemCount: surah.ayat.length,
                    itemBuilder: (context, index) {
                      final ayat = surah.ayat[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(ayat.nomor.toString()),
                          ),
                          title: Text(
                            ayat.ar,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 20),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ayat.tr,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Text(ayat.idn),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is SurahDetailError) {
            return Center(child: Text("❌ ${state.message}"));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
