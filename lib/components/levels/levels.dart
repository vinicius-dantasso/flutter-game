import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import '../actors/player.dart';

class Levels extends World {
  
  final String levelName;
  final Player player;

  Levels({
    required this.levelName,
    required this.player
  });

  late TiledComponent level;

  @override
  FutureOr<void> onLoad() async {
    
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(32));
    add(level);

    _spawnObjects();

    return super.onLoad();
  }
  
  void _spawnObjects() {
    
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('Spawns');

    if(spawnPointLayer != null) {
      for(final spawnPoint in spawnPointLayer.objects) {
        switch(spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
          break;
        }
      }
    }

  }

}