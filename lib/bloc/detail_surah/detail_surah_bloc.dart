// import 'package:bloc/bloc.dart';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:quran_audio/data/model/ayat.dart';

part 'detail_surah_event.dart';
part 'detail_surah_state.dart';

class SurahDetailBloc extends Bloc<SurahDetailEvent, SurahDetailState> {
  SurahDetailBloc() : super(SurahDetailInitial()) {
    on<FetchSurahDetail>(_onFetchSurahDetail);
  }

  Future<void> _onFetchSurahDetail(
    FetchSurahDetail event,
    Emitter<SurahDetailState> emit,
  ) async {
    emit(SurahDetailLoading());
    try {
      final res = await http.get(
        Uri.parse("https://open-api.my.id/api/quran/surah/${event.nomor}"),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        emit(SurahDetailLoaded(SurahDetail.fromJson(data)));
      } else {
        emit(SurahDetailError("Gagal memuat detail surah"));
      }
    } catch (e) {
      emit(SurahDetailError(e.toString()));
    }
  }
}
