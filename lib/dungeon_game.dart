import 'dart:async';

import 'package:dungeon_mobile/components/actors/pistol.dart';
import 'package:dungeon_mobile/components/levels/levels.dart';
import 'package:dungeon_mobile/components/utils/shot_buttom.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import 'components/actors/player.dart';
import 'components/levels/start_screen.dart';

class DungeonGame extends FlameGame with HasCollisionDetection {
  late CameraComponent cam;
  late JoystickComponent joystick;
  late Levels level;

  late TextComponent floor;
  late TextComponent playerLife;
  late TextComponent startText;
  late SpriteComponent gui;
  late SpriteComponent heart;

  Player player = Player();
  Pistol pistol = Pistol();
  List<String> levels = ['Level-00', 'Level-01', 'Level-02', 'Level-03'];
  int currentLevel = -1;

  int show = 0;
  int maxShow = 30;
  bool canShow = true;
  bool playSounds = true;
  double soundVolume = 1.0;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    add(StartScreen());
    if (playSounds) {
      FlameAudio.bgm.initialize();
      FlameAudio.bgm.play("MainTheme.wav", volume: soundVolume * 0.2);
    }
    _showStartText();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (currentLevel >= 0) {
      updateJoyStick();

      floor.text = '$currentLevel';
      playerLife.text = '${player.life}';
    } else {
      _startScreenEffect();
    }

    super.update(dt);
  }

  void addJoyStick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/knob.png')),
      ),
      background:
          SpriteComponent(sprite: Sprite(images.fromCache('HUD/joystick.png'))),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    joystick.priority = 1;
    add(joystick);
  }

  void updateJoyStick() {
    switch (joystick.direction) {
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

  void addGui() async {
    gui = SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/GUI.png')),
        size: Vector2(240, 360),
        position: Vector2(100, 10),
        priority: 1);

    add(gui);

    floor = TextComponent(
      text: '$currentLevel',
      position: Vector2(198, 90),
      textRenderer: TextPaint(
          style: const TextStyle(
              color: Colors.white, fontSize: 56, fontFamily: 'Pixel')),
      priority: 2,
    );

    add(floor);

    heart = SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Heart.png')),
        size: Vector2(32, 28),
        position: Vector2(128, 326),
        priority: 2);

    add(heart);

    playerLife = TextComponent(
      text: '${player.life}',
      position: Vector2(150, 330),
      textRenderer: TextPaint(
          style: const TextStyle(
              color: Colors.white, fontSize: 36, fontFamily: 'Pixel')),
      priority: 3,
    );

    add(playerLife);
  }

  void loadNextLevel() {
    if (currentLevel < levels.length - 1) {
      level.children
          .where((component) => component != player && component != pistol)
          .forEach((component) {
        component.removeFromParent();
      });

      level.collisions.clear();
      level.enemies.clear();

      currentLevel++;
      _loadLevel();
    } else {
      // Cabou os níveis
    }
  }

  void resetGame() {
    removeAll(children);
    currentLevel = -1;

    player = Player();
    pistol = Pistol();

    add(StartScreen());
    _showStartText();
  }

  void startGame() {
    startText.removeFromParent();
    currentLevel++;
    _loadLevel();
    addGui();
    addJoyStick();
    add(ShotButtom());
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      level = Levels(
          levelName: levels[currentLevel], player: player, pistol: pistol);

      cam = CameraComponent.withFixedResolution(
          world: level, width: 830, height: 510);
      cam.priority = 0;
      cam.viewfinder.anchor = Anchor.topLeft;

      addAll([cam, level]);
    });
  }

  void _showStartText() {
    startText = TextComponent(
      text: 'Toque para Iniciar',
      position: Vector2(size.x * 0.5, (size.y * 0.5) + 30),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontFamily: 'Pixel',
        ),
      ),
    );

    add(startText);
  }

  void _startScreenEffect() {
    if (canShow) {
      startText.textRenderer = TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontFamily: 'Pixel',
        ),
      );

      show++;
      if (show >= maxShow) {
        show = 0;
        canShow = false;

        startText.textRenderer = TextPaint(
          style: const TextStyle(
            color: Colors.white10,
            fontSize: 32,
            fontFamily: 'Pixel',
          ),
        );
      }
    } else {
      show++;
      if (show >= maxShow) {
        show = 0;
        canShow = true;
      }
    }
  }
}
