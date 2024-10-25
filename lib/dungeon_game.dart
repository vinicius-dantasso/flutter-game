import 'dart:async';

import 'package:dungeon_mobile/components/levels/levels.dart';
import 'package:dungeon_mobile/components/utils/shot_buttom.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/actors/player.dart';

class DungeonGame extends FlameGame with HasCollisionDetection {

  late final CameraComponent cam;
  late JoystickComponent joystick;
  late SpriteComponent gui;
  late Levels level;

  Player player = Player();
  
  @override
  FutureOr<void> onLoad() async {
    
    await images.loadAllImages();

    level = Levels(levelName: 'Level-00', player: player);

    cam = CameraComponent.withFixedResolution(world: level, width: 830, height: 510);
    cam.priority = 0;
    cam.viewfinder.anchor = Anchor.topLeft;

    addGui();
    addJoyStick();
    add(ShotButtom());
    addAll([cam, level]);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    
    updateJoyStick();

    super.update(dt);
  }

  void addJoyStick() {

    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/knob.png')),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/joystick.png'))
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    joystick.priority = 1;
    add(joystick);

  }
  
  void updateJoyStick() {

    switch(joystick.direction) {
      case JoystickDirection.left:
        player.hSpd = -1;
      break;

      case JoystickDirection.upLeft:
        player.hSpd = -1;
        player.vSpd = -1;
      break;

      case JoystickDirection.downLeft:
        player.hSpd = -1;
        player.vSpd = 1;
      break;

      case JoystickDirection.right:
        player.hSpd = 1;
      break;

      case JoystickDirection.upRight:
        player.hSpd = 1;
        player.vSpd = -1;
      break;

      case JoystickDirection.downRight:
        player.hSpd = 1;
        player.vSpd = 1;
      break;

      case JoystickDirection.up:
        player.vSpd = -1;
      break;

      case JoystickDirection.down:
        player.vSpd = 1;
      break;

      default: 
        player.hSpd = 0;
        player.vSpd = 0;
      break;
    }

  }
  
  void addGui() {

    gui = SpriteComponent(
      sprite: Sprite(images.fromCache('HUD/GUI.png')),
      size: Vector2(240, 360),
      position: Vector2(90,0),
      priority: 0
    );
    
    add(gui);

  }

}