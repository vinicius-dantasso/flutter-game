import 'package:dungeon_mobile/dungeon_game.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  DungeonGame game = DungeonGame();
  runApp(GameWidget(game: kDebugMode ? DungeonGame() : game));
}
