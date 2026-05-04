import 'package:flutter/material.dart';

import 'screens/game_screen.dart';
import 'utils/game_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048消消乐',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: GameColors.buttonBackground),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
