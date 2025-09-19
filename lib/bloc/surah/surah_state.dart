part of 'surah_bloc.dart';

abstract class SurahListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SurahListInitial extends SurahListState {}

class SurahListLoading extends SurahListState {}

class SurahListLoaded extends SurahListState {
  final List<Surah> surahList;
  SurahListLoaded(this.surahList);

  @override
  List<Object?> get props => [surahList];
}

class SurahListError extends SurahListState {
  final String message;
  SurahListError(this.message);

  @override
  List<Object?> get props => [message];
}
