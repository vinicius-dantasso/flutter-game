import 'dart:async';

import 'package:dungeon_mobile/components/utils/custom_hitbox.dart';
import 'package:dungeon_mobile/dungeon_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'player.dart';

class Pistol extends SpriteComponent with HasGameRef<DungeonGame>, CollisionCallbacks {
  bool collected;

  Pistol({
    super.position,
    super.size,
    this.collected = false
  });

  late Player player;

  double offSetX = 0;

  final hitbox = CustomHitbox(
    offSetX: 0, 
    offSetY: 0, 
    width: 32, 
    height: 32
  );

  @override
  FutureOr<void> onLoad() {
    
    debugMode = true;
    player = game.player;

    add(RectangleHitbox(
      position: Vector2(hitbox.offSetX, hitbox.offSetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.passive
    ));

    sprite = Sprite(game.images.fromCache('Items/Pistol.png'));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    
    if(collected) {
      _updatePosition();
    }

    super.update(dt);
  }

  collidedWithPlayer() {
    collected = true;
  }
  
  void _updatePosition() {
    if(player.lookingRight && scale.x < 0) {
      flipHorizontallyAroundCenter();
      offSetX = 30;
    }
    else if(!player.lookingRight && scale.x > 0) {
      flipHorizontallyAroundCenter();
      offSetX = -30;
    }

    position.x = player.position.x + offSetX;
    position.y = player.position.y + 24;
  }
}