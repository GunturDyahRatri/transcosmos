import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_audio/app/routes.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Cari surah berdasarkan nama atau nomor...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
                  if (_filtered.isEmpty && _searchController.text.isEmpty) {
                    _filtered = _all;
                  }
                  return ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final surah = _filtered[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(surah.nomor.toString()),
                          ),
                          title: Text("${surah.namaLatin} (${surah.nama})"),
                          subtitle: Text(
                            "Ayat: ${surah.jumlahAyat} - ${surah.arti}",
                          ),
                          onTap: () {
                            context.pushNamed(
                              AppRoute.detailSurah,
                              extra: surah.nomor,
                            );
                          },
                        ),
                      );
                    },
                  );
                } else if (state is SurahListError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
