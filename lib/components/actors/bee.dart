import 'dart:async';

import 'package:dungeon_mobile/components/actors/enemy.dart';
import 'package:dungeon_mobile/components/utils/custom_hitbox.dart';
import 'package:dungeon_mobile/components/utils/scripts.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../utils/utils.dart';

enum BeeAnim {idle, hit}

class Bee extends Enemy {

  Bee({
    super.position,
    super.anchor = Anchor.topLeft
  });

  final hitbox = CustomHitbox(
    offSetX: 8, 
    offSetY: 8, 
    width: 20, 
    height: 18
  );

  late final SpriteAnimation idleAnim;
  late final SpriteAnimation hitAnim;

  @override
  FutureOr<void> onLoad() {
    _loadAnims();

    add(RectangleHitbox(
      position: Vector2(hitbox.offSetX, hitbox.offSetY),
      size: Vector2(hitbox.width, hitbox.height)
    ));

    collisions = game.player.collisions;

    return super.onLoad();
  }

  @override
  void update(double dt) {

    _nextAction(dt);

    super.update(dt);
  }
  
  void _loadAnims() {
    idleAnim = _setSprite('Idle', 2);
    hitAnim = _setSprite('Hit', 2);

    animations = {
      BeeAnim.idle: idleAnim,
      BeeAnim.hit: hitAnim
    };

    current = BeeAnim.idle;
  }
  
  SpriteAnimation _setSprite(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Bee/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount, 
        stepTime: 0.2, 
        textureSize: Vector2.all(32)
      )
    );
  }
  
  void _nextAction(double dt) {

    if(Scripts.distanceToPoint(position.x, position.y, game.player.position.x, game.player.position.y) <= 100) {
      state = EnemyState.follow;
    }

    switch(state) {
      case EnemyState.choose:
        chooseState();
      break;

      case EnemyState.wander:
        wanderState();
      break;

      case EnemyState.follow:
        followState();
      break;

      case EnemyState.stop:
        velocity.x = 0.0;
        velocity.y = 0.0;
      break;
    }

    position.x += velocity.x * dt;
    _checkHorizontalCollisions();

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

  @override
  void followState() {
    
    destX = game.player.position.x;
    destY = game.player.position.y;

    double dir = Scripts.pointDirection(position.x, position.y, destX, destY);
    velocity.x = Scripts.lengthdirX(spd, dir);
    velocity.y = Scripts.lengthdirY(spd, dir);

    if(Scripts.distanceToPoint(position.x, position.y, destX, destY) >= 150) {
      velocity.x = 0.0;
      velocity.y = 0.0;
      state = EnemyState.choose;
    }

    super.followState();
  }

}