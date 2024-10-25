import 'dart:async';
import 'dart:math';

import 'package:dungeon_mobile/components/actors/wall.dart';
import 'package:dungeon_mobile/components/utils/custom_hitbox.dart';
import 'package:dungeon_mobile/components/utils/scripts.dart';
import 'package:dungeon_mobile/dungeon_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../utils/utils.dart';

enum BeeAnim {idle, hit}
enum BeeState {choose, wander, stop, follow}

class Bee extends SpriteAnimationGroupComponent with HasGameRef<DungeonGame> {

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

  Random rand = Random();
  BeeState state = BeeState.choose;
  late BeeState nextState;

  List<Wall> collisions = [];

  double spd = 100;
  double destX = 0;
  double destY = 0;

  int min = -50;
  int max = 50;

  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    
    debugMode = true;
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
    switch(state) {
      case BeeState.choose:

        nextState = BeeState.values[rand.nextInt(BeeState.values.length)];

        if(nextState == BeeState.wander) {
          state = nextState;
          destX = position.x + (min + rand.nextInt(max - min + 1));
          destY = position.y + (min + rand.nextInt(max - min + 1));

          Future.delayed(Duration(seconds: 1 + rand.nextInt(4)), () => state = BeeState.choose);
        }
        else {
          state = BeeState.stop;
          Future.delayed(Duration(seconds: 1 + rand.nextInt(4)), () => state = BeeState.choose);
        }

      break;

      case BeeState.wander:

        if(Scripts.distanceToPoint(position.x, position.y, destX, destY) > 10.0) {
          final dir = Scripts.pointDirection(position.x, position.y, destX, destY);
          velocity.x = Scripts.lengthdirX(spd, dir);
          velocity.y = Scripts.lengthdirY(spd, dir);
        }
        else {
          velocity.x = 0.0;
          velocity.y = 0.0;
        }

        if(Scripts.distanceToPoint(position.x, position.y, destX, destY) < 1.0) {
          velocity.x = 0;
          velocity.y = 0;
        }

      break;

      case BeeState.follow:

      break;

      case BeeState.stop:

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

}