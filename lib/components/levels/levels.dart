import 'dart:async';

import 'package:dungeon_mobile/components/actors/bee.dart';
import 'package:dungeon_mobile/components/actors/door.dart';
import 'package:dungeon_mobile/components/actors/pistol.dart';
import 'package:dungeon_mobile/components/actors/trap.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import '../actors/player.dart';
import '../actors/wall.dart';

class Levels extends World {
  
  final String levelName;
  final Player player;
  final Pistol pistol;

  Levels({
    required this.levelName,
    required this.player,
    required this.pistol
  });

  late TiledComponent level;
  List<Wall> collisions = [];
  List<Bee> enemies = [];

  @override
  FutureOr<void> onLoad() async {
    
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(32));
    add(level);

    _spawnObjects();
    _spawnCollisions();

    return super.onLoad();
  }
  
  void _spawnObjects() {
    
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('Spawns');

    if(spawnPointLayer != null) {
      for(final spawnPoint in spawnPointLayer.objects) {
        switch(spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.priority = 2;
            add(player);
          break;

          case 'Pistol':
            pistol.position = Vector2(spawnPoint.x, spawnPoint.y);
            pistol.size = Vector2(spawnPoint.width, spawnPoint.height);
            pistol.priority = 2;
            add(pistol);
          break;

          case 'Door':
            final door = Door(
              position: Vector2(spawnPoint.x, spawnPoint.y)
            );
            add(door);
          break;

          case 'Trap':
            final trap = Trap(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2.all(56)
            );
            add(trap);
          break;

          case 'Bee':
            final bee = Bee(position: Vector2(spawnPoint.x, spawnPoint.y));
            enemies.add(bee);
            add(bee);
          break;
        }
      }
    }

  }
  
  void _spawnCollisions() {
    final collisionLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if(collisionLayer != null) {
      for(final collision in collisionLayer.objects) {
        switch(collision.class_) {
          default:
            final wall = Wall(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height)
            );
            collisions.add(wall);
            add(wall);
          break;
        }
      }

      player.collisions = collisions;
    }
  }

}