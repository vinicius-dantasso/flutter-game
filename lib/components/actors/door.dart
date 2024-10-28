import 'dart:async';

import 'package:dungeon_mobile/components/actors/player.dart';
import 'package:dungeon_mobile/dungeon_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

enum DoorState { open, close }

class Door extends SpriteGroupComponent
    with HasGameRef<DungeonGame>, CollisionCallbacks {
  Door({super.position, super.anchor = Anchor.topLeft});

  late final Sprite closed;
  late final Sprite opened;

  @override
  FutureOr<void> onLoad() {
    closed = Sprite(game.images.fromCache('Items/Door_Close.png'));
    opened = Sprite(game.images.fromCache('Items/Door_Open.png'));

    sprites = {DoorState.open: opened, DoorState.close: closed};

    current = DoorState.close;

    add(RectangleHitbox(position: Vector2(0, 0), size: Vector2(width, height)));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (game.level.enemies.isEmpty && game.player.hasGun) {
      current = DoorState.open;
    }

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && current == DoorState.open) {
      _loadNextLevel();
      other.position = Vector2.all(-640);
    }

    super.onCollision(intersectionPoints, other);
  }

  void _loadNextLevel() {
    if (game.playSounds) {
      FlameAudio.play("sfxPortaAbrida.wav", volume: game.soundVolume);
    }
    Future.delayed(const Duration(seconds: 2), () {
      game.loadNextLevel();
    });
  }
}
