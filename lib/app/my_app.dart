import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quran_audio/app/routes.dart';
import 'package:quran_audio/app/theme/app_theme.dart';
import 'package:quran_audio/bloc/detail_surah/detail_surah_bloc.dart';
import 'package:quran_audio/bloc/surah/surah_bloc.dart';
import 'package:toastification/toastification.dart';

class MyApp extends StatelessWidget {
  final appTheme = AppTheme();

  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SurahListBloc()),
        BlocProvider(create: (_) => SurahDetailBloc()),
      ],
      child: ToastificationWrapper(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: appTheme.theme(),
          routerConfig: Routes.router,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'GB'), // English, UK
            Locale('id', 'ID'),
            Locale('en', 'US'),
          ],
        ),
      ),
    );
  }
}
