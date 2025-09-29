part of 'bottom_navbar_cubit.dart';

class BottomNavbarState {
  int activeIndex;
  bool isTapped;
  String? title;

  BottomNavbarState({this.activeIndex = 0, this.isTapped = true, this.title});

  BottomNavbarState copyWith({
    final int? activeIndex,
    final bool? isTapped,
    final String? title,
  }) {
    return BottomNavbarState(
      activeIndex: activeIndex ?? this.activeIndex,
      isTapped: isTapped ?? this.isTapped,
      title: title ?? this.title,
    );
  }
}
