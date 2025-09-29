import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_audio/app/routes.dart';
import 'package:quran_audio/bloc/audioplayer/audioplayer_cubit.dart';
import 'package:quran_audio/bloc/surah/surah_bloc.dart';
import 'package:quran_audio/data/model/surah.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  List<Surah> _all = [];
  List<Surah> _filtered = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SurahListBloc>().add(FetchSurahList());
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered =
          _all.where((s) {
            return s.namaLatin.toLowerCase().contains(query) ||
                s.nomor.toString().contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            /// 📖 Konten utama
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Cari surah berdasarkan nama atau nomor...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  FocusScope.of(context).unfocus();
                                },
                              )
                              : null,
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<SurahListBloc, SurahListState>(
                    builder: (context, state) {
                      if (state is SurahListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is SurahListLoaded) {
                        _all = state.surahList;
                        if (_filtered.isEmpty &&
                            _searchController.text.isEmpty) {
                          _filtered = _all;
                        }
                        return ListView.separated(
                          itemCount: _filtered.length,
                          separatorBuilder:
                              (_, __) => Divider(
                                height: 1,
                                color: Colors.grey.shade300,
                              ),
                          itemBuilder: (context, index) {
                            final surah = _filtered[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurpleAccent,
                                child: Text(surah.nomor.toString()),
                              ),
                              title: Text(surah.namaLatin),
                              subtitle: Text(
                                "${surah.nama} • ${surah.jumlahAyat} ayat • ${surah.arti}",
                              ),
                              trailing: const Icon(
                                Icons.play_circle_fill,
                                color: Colors.deepPurpleAccent,
                                size: 28,
                              ),
                              onTap: () {
                                context.read<AudioPlayerCubit>().play(surah);
                              },
                            );
                          },
                        );
                      } else if (state is SurahListError) {
                        return Center(child: Text("❌ ${state.message}"));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),

            /// 🎶 MiniPlayer floating
            BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
              builder: (context, state) {
                if (state.currentSurah == null) {
                  return const SizedBox.shrink();
                }

                final progress =
                    state.duration.inSeconds == 0
                        ? 0.0
                        : state.position.inSeconds / state.duration.inSeconds;

                return Positioned(
                  left: 12,
                  right: 12,
                  bottom: 36,
                  child: GestureDetector(
                    onTap: () {
                      context.pushNamed(
                        AppRoute.detailSurah,
                        extra: state.currentSurah!.nomor,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green.shade300,
                            child: Text(state.currentSurah!.nomor.toString()),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.currentSurah!.namaLatin,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey.shade100,
                                  color: Colors.deepPurpleAccent,
                                  minHeight: 2,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              state.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.deepPurpleAccent,
                              size: 32,
                            ),
                            onPressed:
                                () => context.read<AudioPlayerCubit>().toggle(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
