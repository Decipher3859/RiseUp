import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

import 'package:rise_up/managers/app_controller.dart';
import 'package:rise_up/pages/growth_page.dart';
import 'package:rise_up/pages/ressources_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rise_up/pages/habits_page.dart';
import 'package:rise_up/pages/menu_page.dart';
import 'package:rise_up/pages/start_page.dart';
import 'package:rise_up/theme/colors.dart';
// import 'db/app_database.dart';
// import 'package:rise_up/.debugging/provide_sample_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('de_DE', null);
  // await resetDatabase();
  // await ProvideSampleData().insertSampleData(db);
  await AppController.instance.init();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(ProviderScope(child: const MyApp()));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RiseUp',
      debugShowCheckedModeBanner: false,
      home: StartPage(),
      routes: {
        '/startpage': (context) => StartPage(),
        '/menupage': (context) => MenuPage(),
        '/habitspage': (context) => HabitsPage(),
        '/growthpage': (context) => GrowthPage(),
        '/ressourcespage': (context) => RessourcesPage(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.darkBlue,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBlue,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
    );
  }
}
