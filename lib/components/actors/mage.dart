import 'dart:async';

import 'package:dungeon_mobile/components/actors/bullet.dart';
import 'package:dungeon_mobile/components/actors/enemy.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../utils/custom_hitbox.dart';
import '../utils/scripts.dart';
import '../utils/utils.dart';

enum MageAnim {idle, run, attack, hit}

class Mage extends Enemy {

  Mage({
    super.position,
    super.anchor = Anchor.topLeft
  });

  final hitbox = CustomHitbox(
    offSetX: 16, 
    offSetY: 16, 
    width: 30, 
    height: 28
  );

  late final SpriteAnimation idleAnim;
  late final SpriteAnimation runAnim;
  late final SpriteAnimation attackAnim;
  late final SpriteAnimation hitAnim;

  int life = 4;
  int castCharge = 0;
  int cast = 60 * 2;

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    _loadAnims();

    add(RectangleHitbox(
      position: Vector2(hitbox.offSetX, hitbox.offSetY),
      size: Vector2(hitbox.width, hitbox.height)
    ));

    collisions = game.level.collisions;

    return super.onLoad();
  }

  @override
  void update(double dt) {

    _nextAction(dt);

    if(life <= 0) {
      removeFromParent();
      game.level.enemies.remove(this);
    }
    
    if(velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    }
    else if(velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    
    if(other is Bullet && !other.isMagic) {
      life--;
      hit = true;
      double pX = game.player.position.x;
      double pY = game.player.position.y;

      double dir = Scripts.pointDirection(pX, pY, other.position.x, other.position.y);
      knockBackDir = dir;
      knockBackSpd = 150.0;
      state = EnemyState.hit;

      current = MageAnim.hit;
      other.removeFromParent();
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void followState() {
    
    castCharge++;
    if(castCharge >= cast) {
      castCharge = 0;
      current = MageAnim.attack;

      double dX = game.player.position.x + (game.player.width * 0.5);
      double dY = game.player.position.y + (game.player.height * 0.5);

      final magic = Bullet(
        position: Vector2(position.x, position.y),
        dest: Vector2(dX, dY),
        isMagic: true
      );

      game.level.add(magic);
    }

    if(Scripts.distanceToPoint(
      position.x, position.y, 
      game.player.position.x, game.player.position.y
    ) <= 300) {
      state = EnemyState.choose;
    }

    super.followState();
  }

  @override
  void hitState() {
    
    knockBackSpd = Scripts.lerp(knockBackSpd, 0.0, 0.3);

    velocity.x = Scripts.lengthdirX(knockBackSpd, knockBackDir);
    velocity.y = Scripts.lengthdirY(knockBackSpd, knockBackDir);

    Future.delayed(const Duration(milliseconds: 100), () {
      hit = false;
      state = EnemyState.choose;
      current = MageAnim.idle;
    });

    super.hitState();
  }
  
  void _loadAnims() {

    idleAnim = _setSprite('Idle', 1, 1.0);
    runAnim = _setSprite('Run', 4, 0.2);
    attackAnim = _setSprite('Attack', 1, 1.0);
    hitAnim = _setSprite('Hit', 1, 1.0);

    animations = {
      MageAnim.idle: idleAnim,
      MageAnim.run: runAnim,
      MageAnim.attack: attackAnim,
      MageAnim.hit: hitAnim
    };

    current = MageAnim.idle;

  }
  
  SpriteAnimation _setSprite(String state, int amount, double stepTime) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Mage/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount, 
        stepTime: stepTime, 
        textureSize: Vector2.all(64)
      )
    );
  }
  
  void _nextAction(double dt) {

    if(Scripts.distanceToPoint(
      position.x, position.y, 
      game.player.position.x, game.player.position.y
    ) <= 250 && !hit) {
      state = EnemyState.follow;
    }

    switch(state) {
      case EnemyState.choose:
        chooseState();
      break;

      case EnemyState.wander:
        current = MageAnim.run;
        wanderState();
      break;

      case EnemyState.follow:
        followState();
      break;

      case EnemyState.stop:
        current = MageAnim.idle;
        velocity.x = 0.0;
        velocity.y = 0.0;
      break;

      case EnemyState.hit:
        hitState();
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

}