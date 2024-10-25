import 'dart:async';

import 'package:dungeon_mobile/components/actors/bullet.dart';
import 'package:dungeon_mobile/components/utils/custom_hitbox.dart';
import 'package:dungeon_mobile/components/utils/scripts.dart';
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
  double minDist = 0;

  bool isShooting = false;
  bool canShoot = true;

  Vector2 dist = Vector2.zero();

  final hitbox = CustomHitbox(
    offSetX: 0, 
    offSetY: 0, 
    width: 32, 
    height: 32
  );

  @override
  FutureOr<void> onLoad() {
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

      if(isShooting && canShoot) _shootBullet();
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
  
  void _shootBullet() {
    canShoot = false;

    int index = 0;
    for(final enemy in game.level.enemies) {
      double value = Scripts.distanceToPoint(position.x, position.y, enemy.position.x, enemy.position.y);

      if(index == 0) {
        minDist = value;
        dist = Vector2(enemy.position.x, enemy.position.y);
      }
      else {
        if(minDist > value) {
          minDist = value;
          dist = Vector2(enemy.position.x, enemy.position.y);
        }
      }
      index++;
    }

    final bullet = Bullet(position: Vector2(position.x, position.y), dest: dist);
    game.level.add(bullet);
  }
}