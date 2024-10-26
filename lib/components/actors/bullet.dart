import 'dart:async';

import 'package:dungeon_mobile/components/actors/wall.dart';
import 'package:dungeon_mobile/components/utils/custom_hitbox.dart';
import 'package:dungeon_mobile/components/utils/scripts.dart';
import 'package:dungeon_mobile/dungeon_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Bullet extends SpriteComponent with HasGameRef<DungeonGame>, CollisionCallbacks {

  Vector2 dest;
  bool isMagic;

  Bullet({
    super.position,
    super.size,
    required this.dest,
    this.isMagic = false
  });

  final hitbox = CustomHitbox(
    offSetX: 8, 
    offSetY: 8, 
    width: 16, 
    height: 16
  );

  double spd = 500;
  double hSpd = 0;
  double vSpd = 0;

  @override
  FutureOr<void> onLoad() {

    add(RectangleHitbox(
      position: Vector2(hitbox.offSetX, hitbox.offSetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));

    if(!isMagic) {
      sprite = Sprite(game.images.fromCache('Items/Bullet.png'));
    }
    else {
      sprite = Sprite(game.images.fromCache('Items/Magic.png'));
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    
    final spdDir = Scripts.pointDirection(position.x, position.y, dest.x, dest.y);

    hSpd = Scripts.lengthdirX(spd, spdDir);
    vSpd = Scripts.lengthdirY(spd, spdDir);

    position.x += hSpd * dt;
    position.y += vSpd * dt;

    Future.delayed(const Duration(milliseconds: 500), () => removeFromParent());

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    
    if(other is Wall) removeFromParent();

    super.onCollision(intersectionPoints, other);
  }
}