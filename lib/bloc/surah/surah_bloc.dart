import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:quran_audio/data/model/surah.dart';

part 'surah_event.dart';
part 'surah_state.dart';

class SurahListBloc extends Bloc<SurahListEvent, SurahListState> {
  SurahListBloc() : super(SurahListInitial()) {
    on<FetchSurahList>(_onFetchSurahList);
  }

  Future<void> _onFetchSurahList(
    FetchSurahList event,
    Emitter<SurahListState> emit,
  ) async {
    emit(SurahListLoading());
    try {
      final res = await http.get(
        Uri.parse("https://open-api.my.id/api/quran/surah"),
      );
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        final surahList = data.map((e) => Surah.fromJson(e)).toList();
        emit(SurahListLoaded(surahList));
      } else {
        emit(SurahListError("Gagal memuat daftar surah"));
      }
    } catch (e) {
      emit(SurahListError(e.toString()));
    }
  }
}
