import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Wall extends PositionComponent with CollisionCallbacks {
  Wall({
    super.position,
    super.size
  });

  @override
  FutureOr<void> onLoad() {

    add(RectangleHitbox(
      position: Vector2(0,0),
      size: Vector2(width, height),
      collisionType: CollisionType.passive
    ));
    
    return super.onLoad();
  }
}