import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_audio/app/routes.dart';
import 'package:quran_audio/bloc/audioplayer/audioplayer_cubit.dart';
import 'package:quran_audio/bloc/detail_surah/detail_surah_bloc.dart';
import 'package:quran_audio/bloc/surah/surah_bloc.dart';
import 'package:quran_audio/data/helper/surah_mapper.dart';
import 'package:quran_audio/data/model/ayat.dart';
import 'package:quran_audio/data/model/surah.dart';

class SurahDetailPage extends StatefulWidget {
  final int nomor;

  const SurahDetailPage({super.key, required this.nomor});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    context.read<SurahDetailBloc>().add(FetchSurahDetail(widget.nomor));
    _tabController = TabController(length: 2, vsync: this);
    context.read<SurahListBloc>().add(FetchSurahList());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return "${twoDigits(m)}:${twoDigits(s)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SurahDetailBloc, SurahDetailState>(
        builder: (context, state) {
          if (state is SurahDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SurahDetailLoaded) {
            var surah = state.surahDetail;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    /// 🎵 Cover + Info Surah
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(5),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 190, 154, 251),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 80,
                              backgroundColor: const Color.fromARGB(
                                255,
                                154,
                                119,
                                252,
                              ),
                              child: Text(
                                surah.nama,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "${surah.namaLatin} (${surah.nama})",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Arti: ${surah.arti}"),
                            Text("Jumlah Ayat: ${surah.jumlahAyat}"),
                            Text("Turun di: ${surah.tempatTurun}"),
                          ],
                        ),
                      ),
                    ),

                    /// 🎶 Audio Control pakai AudioPlayerCubit
                    BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                      builder: (context, audioState) {
                        final isCurrent =
                            audioState.currentSurah?.nomor == surah.nomor;
                        final isPlaying = isCurrent && audioState.isPlaying;
                        final duration = audioState.duration ?? Duration.zero;
                        final position = audioState.position ?? Duration.zero;

                        return Column(
                          children: [
                            Slider(
                              min: 0,
                              max: duration.inSeconds.toDouble(),
                              value:
                                  position.inSeconds
                                      .clamp(0, duration.inSeconds)
                                      .toDouble(),
                              onChanged: (value) {
                                context.read<AudioPlayerCubit>().seek(
                                  Duration(seconds: value.toInt()),
                                );
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_format(position)),
                                Text(_format(duration)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    if (isCurrent) {
                                      context.read<AudioPlayerCubit>().toggle();
                                    } else {
                                      context.read<AudioPlayerCubit>().play(
                                        surah.toSurah(),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.stop, size: 36),
                                  onPressed: () {
                                    context.read<AudioPlayerCubit>().stop();
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    /// 📑 Tabs: Lyrics & Queue
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.brown,
                      tabs: const [Tab(text: "Lyrics"), Tab(text: "Queue")],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          /// Lyrics → daftar ayat
                          ListView.builder(
                            itemCount: surah.ayat.length,
                            itemBuilder: (context, index) {
                              final Ayat ayat = surah.ayat[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      ayat.ar,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ayat.tr,
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    Text(ayat.idn),
                                    const Divider(),
                                  ],
                                ),
                              );
                            },
                          ),

                          /// Queue → dinamis dari SurahListBloc
                          BlocBuilder<SurahListBloc, SurahListState>(
                            builder: (context, listState) {
                              if (listState is SurahListLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (listState is SurahListLoaded) {
                                final daftarSurah = listState.surahList;
                                return ListView.builder(
                                  itemCount: daftarSurah.length,
                                  itemBuilder: (context, index) {
                                    final Surah s = daftarSurah[index];
                                    // final currentSurah = context.select(
                                    //   (AudioPlayerCubit c) =>
                                    //       c.state.currentSurah,
                                    // );
                                    // final isPlaying = context.select(
                                    //   (AudioPlayerCubit c) => c.state.isPlaying,
                                    // );
                                    return Builder(
                                      builder: (context) {
                                        final audioState =
                                            context
                                                .watch<AudioPlayerCubit>()
                                                .state;
                                        final currentSurah =
                                            audioState.currentSurah;

                                        return ListTile(
                                          leading: const Icon(
                                            Icons.library_music,
                                          ),
                                          title: Text(s.namaLatin),
                                          subtitle: Text(
                                            "${s.jumlahAyat} ayat",
                                          ),
                                          trailing:
                                              (s.nomor == currentSurah?.nomor)
                                                  ? Icon(
                                                    audioState.isPlaying
                                                        ? Icons.equalizer
                                                        : Icons.pause,
                                                    color: Colors.brown,
                                                  )
                                                  : null,
                                          onTap: () {
                                            context.pushNamed(
                                              AppRoute.detailSurah,
                                              extra: s.nomor,
                                            );
                                            context
                                                .read<AudioPlayerCubit>()
                                                .play(s);
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              } else if (listState is SurahListError) {
                                return Center(
                                  child: Text("❌ ${listState.message}"),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
