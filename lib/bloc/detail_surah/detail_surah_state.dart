part of 'detail_surah_bloc.dart';

abstract class SurahDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SurahDetailInitial extends SurahDetailState {}

class SurahDetailLoading extends SurahDetailState {}

class SurahDetailLoaded extends SurahDetailState {
  final SurahDetail surahDetail;
  SurahDetailLoaded(this.surahDetail);

  @override
  List<Object?> get props => [surahDetail];
}

class SurahDetailError extends SurahDetailState {
  final String message;
  SurahDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
