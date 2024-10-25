import 'dart:async';

import 'package:dungeon_mobile/components/actors/enemy.dart';
import 'package:dungeon_mobile/components/utils/scripts.dart';
import 'package:dungeon_mobile/dungeon_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../actors/pistol.dart';
import '../actors/wall.dart';
import '../utils/custom_hitbox.dart';
import '../utils/utils.dart';

enum PlayerState {idle, running, hit, dead}

class Player extends SpriteAnimationGroupComponent with HasGameRef<DungeonGame>, CollisionCallbacks {

  Player({
    super.position,
    super.anchor = Anchor.topLeft
  });

  late final SpriteAnimation idleAnim;
  late final SpriteAnimation runAnim;
  late final SpriteAnimation hitAnim;
  late final SpriteAnimation deadAnim;

  late Pistol gun;

  List<Wall> collisions = [];
  CustomHitbox hitbox = CustomHitbox(
    offSetX: 22, 
    offSetY: 24, 
    width: 18, 
    height: 28
  );

  double hSpd = 0;
  double vSpd = 0;
  double spd = 120;
  double knockBackSpd = 0;
  double knockBackDir = 0;

  bool lookingRight = true;
  bool hit = false;

  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {

    _loadAllAnims();

    add(RectangleHitbox(
      position: Vector2(hitbox.offSetX, hitbox.offSetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(!hit) {
      _updatePlayerState();
      _updatePlayerMovement(dt);
    }
    else {
      knockBackSpd = Scripts.lerp(knockBackSpd, 0, 0.3);
      velocity.x = Scripts.lengthdirX(knockBackSpd, knockBackDir);
      velocity.y = Scripts.lengthdirX(knockBackSpd, knockBackDir);

      position.x += velocity.x * dt;
      _checkHorizontalCollisions();

      position.y += velocity.y * dt;
      _checkVerticalCollisions();

      Future.delayed(const Duration(milliseconds: 100), () {
        hit = false;
        current = PlayerState.idle;
      });
    }

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    
    if(other is Pistol && !other.collected) {
      other.collidedWithPlayer();
      gun = other;
    }
    else if(other is Enemy) {
      hit = true;

      double ox = other.position.x;
      double oy = other.position.y;

      double dir = Scripts.pointDirection(ox, oy, position.x, position.y);
      knockBackDir = dir;
      knockBackSpd = 200.0;
      current = PlayerState.hit;
    }

    super.onCollision(intersectionPoints, other);
  }
  
  void _loadAllAnims() {
    idleAnim = _setSprite('Idle', 2, 0.5);
    runAnim = _setSprite('Run', 4, 0.3);
    hitAnim = _setSprite('Hit', 2, 0.2);
    deadAnim = _setSprite('Dead', 1, 1);

    animations = {
      PlayerState.idle: idleAnim,
      PlayerState.running: runAnim,
      PlayerState.hit: hitAnim,
      PlayerState.dead: deadAnim
    };

    current = PlayerState.idle;
  }
  
  SpriteAnimation _setSprite(String state, int amount, double stepTime) {
    
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Player/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount, 
        stepTime: stepTime, 
        textureSize: Vector2.all(64)
      )
    );

  }
  
  void _updatePlayerState() {

    PlayerState playerState = PlayerState.idle;

    if(velocity.x < 0 && scale.x > 0) {
      lookingRight = false;
      flipHorizontallyAroundCenter();
    }
    else if(velocity.x > 0 && scale.x < 0) {
      lookingRight = true;
      flipHorizontallyAroundCenter();
    }

    if(velocity.x > 0 || velocity.x < 0) {
      playerState = PlayerState.running;
    }

    current = playerState;

  }
  
  void _updatePlayerMovement(double dt) {
    velocity.x = hSpd * spd;
    position.x += velocity.x * dt;

    _checkHorizontalCollisions();

    velocity.y = vSpd * spd;
    position.y += velocity.y * dt;

    _checkVerticalCollisions();
  }
  
  void _checkHorizontalCollisions() {
    for(final block in collisions) {
      if(checkCollisions(this, block)) {
        if(velocity.x > 0) {
          velocity.x = 0;
          position.x = block.x - hitbox.offSetX - hitbox.width;
        }
        else if(velocity.x < 0) {
          velocity.x = 0;
          position.x = block.x + block.width + hitbox.width + hitbox.offSetX;
        }
        velocity.x = 0;
      }
    }
  }
  
  void _checkVerticalCollisions() {
    for(final block in collisions) {
      if(checkCollisions(this, block)) {
        if(velocity.y > 0) {
          velocity.y = 0;
          position.y = block.y - hitbox.height - hitbox.offSetY;
        }
        else if(velocity.y < 0) {
          velocity.y = 0;
          position.y = block.y + block.height - hitbox.offSetY;
        }
        velocity.y = 0;
      }
    }
  }

}