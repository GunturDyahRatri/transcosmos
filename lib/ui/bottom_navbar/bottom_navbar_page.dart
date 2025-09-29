import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_audio/app/routes.dart';
import 'package:quran_audio/bloc/bottom_navbar/bottom_navbar_cubit.dart';
import 'package:quran_audio/ui/home/home.dart';

class BottomNavBarPage extends StatelessWidget {
  const BottomNavBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BottomNavBarPage();
  }
}

class _BottomNavBarPage extends StatefulWidget {
  const _BottomNavBarPage({super.key});

  @override
  State<_BottomNavBarPage> createState() => __BottomNavBarPageState();
}

class __BottomNavBarPageState extends State<_BottomNavBarPage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavbarCubit, BottomNavbarState>(
      builder: (context, state) {
        return Scaffold(
          extendBody: true, // wajib untuk efek floating
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Transform.translate(
            offset: const Offset(0, -20),
            child: FloatingActionButton(
              onPressed: () {
                // context.push(AppRoute.addPoint);
              },
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(Icons.play_circle_fill),
            ),
          ),
          // body: _listContentTab()[state.activeIndex],
          body: BottomBar(
            body: (context, scrollController) {
              return PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  context.read<BottomNavbarCubit>().change(index);
                },
                physics: const NeverScrollableScrollPhysics(),
                children: _listContentTab(),
              );
            },
            fit: StackFit.expand,
            borderRadius: BorderRadius.circular(500),
            barDecoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            barAlignment: Alignment.bottomCenter,
            curve: Curves.decelerate,
            showIcon: true,
            width: MediaQuery.of(context).size.width * 0.8,
            barColor: Colors.white.withOpacity(0.75),
            reverse: false,
            hideOnScroll: true,
            scrollOpposite: false,
            respectSafeArea: true,
            start: 2,
            end: 0,
            offset: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navIcon(
                  Icons.music_note_outlined, // icon normal
                  Icons.music_note, // icon aktif
                  0,
                  state,
                ),
                SizedBox(width: 48), // space for FAB
                _navIcon(
                  Icons.video_collection_outlined, // icon normal
                  Icons.video_collection, // icon aktif
                  2,
                  state,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _listContentTab() {
    return <Widget>[const SurahListPage(), const SizedBox(), const SizedBox()];
  }

  Widget _navIcon(
    IconData icon,
    IconData activeIcon,
    int index,
    BottomNavbarState state,
  ) {
    var theme = Theme.of(context);
    return IconButton(
      icon: Icon(
        state.activeIndex == index ? activeIcon : icon,
        color:
            state.activeIndex == index
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
        size: 28, // bisa disesuaikan
      ),
      onPressed: () {
        context.read<BottomNavbarCubit>().change(index);
        _pageController.jumpToPage(index);
      },
    );
  }
}
