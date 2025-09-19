part of 'detail_surah_bloc.dart';

abstract class SurahDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchSurahDetail extends SurahDetailEvent {
  final int nomor;
  FetchSurahDetail(this.nomor);

  @override
  List<Object?> get props => [nomor];
}
