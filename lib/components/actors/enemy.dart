import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../dungeon_game.dart';
import '../actors/wall.dart';
import '../utils/scripts.dart';

enum EnemyState { choose, wander, stop, follow, hit }

class Enemy extends SpriteAnimationGroupComponent with HasGameRef<DungeonGame>, CollisionCallbacks {
  Enemy({super.position, super.anchor = Anchor.topLeft});

  Random rand = Random();
  List<Wall> collisions = [];

  EnemyState state = EnemyState.choose;
  late EnemyState nextState;

  double spd = 100;
  double destX = 0;
  double destY = 0;
  double knockBackDir = 0;
  double knobackBackSpd = 0;

  int min = -50;
  int max = 50;

  bool hit = false;

  Vector2 velocity = Vector2.zero();

  void chooseState() {
    nextState = EnemyState.values[rand.nextInt(EnemyState.values.length)];

    if (nextState == EnemyState.wander) {
      state = nextState;
      destX = position.x + (min + rand.nextInt(max - min + 1));
      destY = position.y + (min + rand.nextInt(max - min + 1));

      Future.delayed(Duration(seconds: 1 + rand.nextInt(3)),
          () => state = EnemyState.choose);
    } else {
      state = EnemyState.stop;
      Future.delayed(Duration(seconds: 1 + rand.nextInt(3)),
          () => state = EnemyState.choose);
    }
  }

  void wanderState() {
    if (Scripts.distanceToPoint(position.x, position.y, destX, destY) > 10.0) {
      final dir = Scripts.pointDirection(position.x, position.y, destX, destY);
      velocity.x = Scripts.lengthdirX(spd, dir);
      velocity.y = Scripts.lengthdirY(spd, dir);
    } else {
      velocity.x = 0.0;
      velocity.y = 0.0;
    }

    if (Scripts.distanceToPoint(position.x, position.y, destX, destY) < 1.0) {
      velocity.x = 0;
      velocity.y = 0;
    }
  }

  void followState() {}

  void hitState() {}
}
