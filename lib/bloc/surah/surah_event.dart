part of 'surah_bloc.dart';

abstract class SurahListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchSurahList extends SurahListEvent {}
