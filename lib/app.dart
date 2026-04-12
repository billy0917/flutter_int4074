import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/app_stats_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/history_provider.dart';
import 'providers/quiz_provider.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class PinPinGoApp extends StatelessWidget {
  const PinPinGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AppStatsProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: 'PinPin Go 拼拼樂',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('zh'),
              Locale('en'),
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: AppRoutes.splash,
            // Prevent system text-scaling from blowing up the layout
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  textScaler: mq.textScaler.clamp(
                    minScaleFactor: 0.8,
                    maxScaleFactor: 1.0,
                  ),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
