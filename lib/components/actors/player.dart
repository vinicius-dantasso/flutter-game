import 'dart:async';

import 'package:dungeon_mobile/dungeon_game.dart';
import 'package:flame/components.dart';

enum PlayerState {idle, running}

class Player extends SpriteAnimationGroupComponent with HasGameRef<DungeonGame> {

  Player({
    super.position,
    super.anchor = Anchor.topLeft
  });

  late final SpriteAnimation idleAnim;
  late final SpriteAnimation runAnim;

  double hSpd = 0;
  double vSpd = 0;
  double spd = 100;

  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {

    _loadAllAnims();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    
    _updatePlayerState();
    _updatePlayerMovement(dt);

    super.update(dt);
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
      flipHorizontallyAroundCenter();
    }
    else if(velocity.x > 0 && scale.x < 0) {
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

    velocity.y = vSpd * spd;
    position.y += velocity.y * dt;
  }

}