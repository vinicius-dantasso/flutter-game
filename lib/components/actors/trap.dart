import 'dart:async';

import 'package:dungeon_mobile/components/actors/player.dart';
import 'package:dungeon_mobile/dungeon_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum TrapState {close, semi, open}

class Trap extends SpriteGroupComponent with HasGameRef<DungeonGame>, CollisionCallbacks {
  Trap({
    super.position,
    super.size,
    super.anchor = Anchor.topLeft
  });

  late final Sprite sprClose;
  late final Sprite sprSemi;
  late final Sprite sprOpen;

  @override
  FutureOr<void> onLoad() {
    
    sprClose = Sprite(game.images.fromCache('Traps/Trap_Close.png'));
    sprSemi = Sprite(game.images.fromCache('Traps/Trap_Semi.png'));
    sprOpen = Sprite(game.images.fromCache('Traps/Trap_Open.png'));

    sprites = {
      TrapState.close: sprClose,
      TrapState.semi: sprSemi,
      TrapState.open: sprOpen
    };

    current = TrapState.close;

    add(RectangleHitbox(
      position: Vector2(14, 14),
      size: Vector2(32, 32)
    ));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    
    if(current == TrapState.open) {
      Future.delayed(const Duration(seconds: 2), () => current = TrapState.close);
    }

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    
    if(other is Player && current == TrapState.close) {
      Future.delayed(const Duration(milliseconds: 500), () {
        current = TrapState.semi;
        Future.delayed(const Duration(milliseconds: 500), () => current = TrapState.open);
      });
    }

    super.onCollision(intersectionPoints, other);
  }
}