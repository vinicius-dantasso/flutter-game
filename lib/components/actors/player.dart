import 'dart:async';

import 'package:dungeon_mobile/components/actors/bullet.dart';
import 'package:dungeon_mobile/components/actors/enemy.dart';
import 'package:dungeon_mobile/components/actors/trap.dart';
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

  int life = 3;

  bool lookingRight = true;
  bool hasGun = false;
  bool showOver = true;
  bool isDead = false;
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
    if(!hit && life > 0) {
      _updatePlayerState();
      _updatePlayerMovement(dt);
    }
    else if(hit && life > 0) {
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

    if(life <= 0) {
      current = PlayerState.dead;
      isDead = true;
      if(showOver) {
        showOver = false;
        _showGameOver();
      }
    }

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    
    if(other is Pistol && !other.collected && life > 0) {
      other.collidedWithPlayer();
      gun = other;
      hasGun = true;
    }
    else if(other is Enemy || (other is Trap && other.current == TrapState.open) && life > 0) {
      _addKnockBack(other);
    }
    else if(other is Bullet && other.isMagic && life > 0) {
      _addKnockBack(other);
      other.removeFromParent();
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
  
  void _addKnockBack(other) {
    hit = true;
    life--;

    double ox = other.position.x;
    double oy = other.position.y;

    double dir = Scripts.pointDirection(position.x, position.y, ox, oy);
    knockBackDir = dir;
    knockBackSpd = 400.0;
    current = PlayerState.hit;
  }
  
  void _showGameOver() {
    final over = SpriteComponent(
      sprite: Sprite(game.images.fromCache('Menus/Game_Over.png')),
      position: Vector2((game.size.x * 0.5) - 200, (game.size.y * 0.5) - 100),
      size: Vector2(400, 120),
      priority: 4
    );
    game.add(over);

    Future.delayed(const Duration(seconds: 10), () => game.resetGame());
  }

}