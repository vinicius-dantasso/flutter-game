import 'dart:async';

import 'package:dungeon_mobile/components/actors/bullet.dart';
import 'package:dungeon_mobile/components/utils/custom_hitbox.dart';
import 'package:dungeon_mobile/components/utils/scripts.dart';
import 'package:dungeon_mobile/dungeon_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

import 'player.dart';

class Pistol extends SpriteComponent
    with HasGameRef<DungeonGame>, CollisionCallbacks {
  bool collected;

  Pistol({super.position, super.size, this.collected = false});

  late Player player;
  late SpriteComponent sprAmmo;

  List<SpriteComponent> ammos = [];

  double offSetX = 0;
  double minDist = 0;

  int ammo = 0;

  bool isShooting = false;
  bool canShoot = true;
  bool drawIcon = true;

  Vector2 dist = Vector2.zero();

  final hitbox = CustomHitbox(offSetX: 0, offSetY: 0, width: 32, height: 32);

  @override
  FutureOr<void> onLoad() {
    player = game.player;

    add(RectangleHitbox(
        position: Vector2(hitbox.offSetX, hitbox.offSetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive));

    sprite = Sprite(game.images.fromCache('Items/Pistol.png'));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (collected) {
      _updatePosition();

      if (isShooting && canShoot && ammo > 0) {
        _shootBullet();
      }

      // Reload
      if (ammo <= 0) {
        Future.delayed(const Duration(seconds: 1), () {
          ammo = 20;
          if (game.playSounds) {
            FlameAudio.play("sfxRecarregarArma.wav",
                volume: game.soundVolume * 0.3);
          }
          _drawAmmo();
        });
      }

      if (drawIcon) {
        drawIcon = false;
        final icon = SpriteComponent(
            sprite: Sprite(game.images.fromCache('HUD/Pistol_Solo.png')),
            position: Vector2(180, 210),
            size: Vector2.all(64),
            priority: 2);
        game.add(icon);
      }
    }

    super.update(dt);
  }

  collidedWithPlayer() {
    collected = true;
  }

  void _updatePosition() {
    if (player.lookingRight && scale.x < 0) {
      flipHorizontallyAroundCenter();
      offSetX = 30;
    } else if (!player.lookingRight && scale.x > 0) {
      flipHorizontallyAroundCenter();
      offSetX = -30;
    }

    position.x = player.position.x + offSetX;
    position.y = player.position.y + 24;
  }

  void _shootBullet() {
    if (game.playSounds) {
      FlameAudio.play("sfxTiroPlayer.wav", volume: game.soundVolume * 0.3);
    }
    canShoot = false;
    ammo--;
    ammos.removeLast().removeFromParent();

    int index = 0;
    double actualX = position.x;
    double actualY = position.y;

    for (final enemy in game.level.enemies) {
      double destX = enemy.position.x + (enemy.width * 0.5);
      double destY = enemy.position.y + (enemy.height * 0.5);

      double value = Scripts.distanceToPoint(actualX, actualY, destX, destY);

      if (index == 0) {
        minDist = value;
        dist = Vector2(destX, destY);
      } else {
        if (minDist > value) {
          minDist = value;
          dist = Vector2(destX, destY);
        }
      }
      index++;
    }

    Vector2 direction = (dist - position).normalized();

    final bullet =
        Bullet(position: Vector2(position.x, position.y), dest: direction);
    game.level.add(bullet);
  }

  void _drawAmmo() {
    for (final ammoSprite in ammos) {
      ammoSprite.removeFromParent();
    }
    ammos.clear();

    for (int i = 0; i < ammo; i++) {
      sprAmmo = SpriteComponent(
          sprite: Sprite(game.images.fromCache('HUD/Ammo.png')),
          position: Vector2(135 + ((i - 1) * 6), 280),
          size: Vector2(6, 16),
          priority: 2);
      ammos.add(sprAmmo);
      game.add(sprAmmo);
    }
  }
}
