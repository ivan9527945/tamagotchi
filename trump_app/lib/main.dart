import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart' as rive;
import 'models/game_state.dart';
import 'screens/main_game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 鎖定直向
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await rive.RiveNative.init();
  runApp(const TrumpTamagotchiApp());
}

class TrumpTamagotchiApp extends StatelessWidget {
  const TrumpTamagotchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        title: 'THE GREATEST PET',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFD700),
            brightness: Brightness.light,
          ),
          fontFamily: 'Inter',
        ),
        home: const MainGameScreen(),
      ),
    );
  }
}
