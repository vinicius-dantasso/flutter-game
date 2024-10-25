import 'dart:async';

import 'package:dungeon_mobile/dungeon_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../actors/pistol.dart';
import '../actors/wall.dart';
import '../utils/custom_hitbox.dart';
import '../utils/utils.dart';

enum PlayerState {idle, running}

class Player extends SpriteAnimationGroupComponent with HasGameRef<DungeonGame>, CollisionCallbacks {

  Player({
    super.position,
    super.anchor = Anchor.topLeft
  });

  late final SpriteAnimation idleAnim;
  late final SpriteAnimation runAnim;

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

  bool lookingRight = true;

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
    _updatePlayerState();
    _updatePlayerMovement(dt);

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    
    if(other is Pistol && !other.collected) {
      other.collidedWithPlayer();
      gun = other;
    }

    super.onCollision(intersectionPoints, other);
  }
  
  void _loadAllAnims() {
    idleAnim = _setSprite('Idle', 2, 0.5);
    runAnim = _setSprite('Run', 4, 0.3);

    animations = {
      PlayerState.idle: idleAnim,
      PlayerState.running: runAnim
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