import 'dart:async';

import 'package:dungeon_mobile/dungeon_game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class ShotButtom extends SpriteComponent with HasGameRef<DungeonGame>, TapCallbacks {
  
  final margin = 32;
  final buttomSize = 64;

  @override
  FutureOr<void> onLoad() {
    
    sprite = Sprite(game.images.fromCache('HUD/bullet_buttom.png'));
    position = Vector2(
      game.size.x - margin - buttomSize,
      game.size.y - margin - buttomSize
    );

    priority = 1;

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.gun.isShooting = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.gun.isShooting = false;
    game.player.gun.canShoot = true;
    super.onTapUp(event);
  }

}