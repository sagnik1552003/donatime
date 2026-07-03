import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'navigation/app_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/sessions/models/session_model.dart';
import 'theme/forest_theme.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(
    SessionModelAdapter(),
  );

  await Hive.openBox<SessionModel>(
    'sessionsBox',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(

      debugShowCheckedModeBanner: false,

      routerConfig: appRouter,

      theme: ForestTheme.lightTheme,
    );
  }
}