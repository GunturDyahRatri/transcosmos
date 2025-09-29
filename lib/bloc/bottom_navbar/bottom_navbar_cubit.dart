import 'package:bloc/bloc.dart';

part 'bottom_navbar_state.dart';

class BottomNavbarCubit extends Cubit<BottomNavbarState> {
  BottomNavbarCubit() : super(BottomNavbarState());
  var appbarTitles = ['Surah', 'PlayNow', 'Video'];

  change(int index, {bool? isTapped}) {
    emit(
      state.copyWith(
        activeIndex: index,
        isTapped: isTapped,
        title: appbarTitles[index],
      ),
    );
  }
}
