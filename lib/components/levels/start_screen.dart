import 'package:dungeon_mobile/dungeon_game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class StartScreen extends SpriteComponent with HasGameRef<DungeonGame>, TapCallbacks {

  @override
  Future<void> onLoad() async {
    
    sprite = Sprite(game.images.fromCache('Menus/Menu_Screen.png'));
    size = Vector2(game.size.x, game.size.y);

    super.onLoad();
  }

  @override
  void onTapUp(TapUpEvent event) {
    Future.delayed(const Duration(seconds: 1), () {
      removeFromParent();
      game.startGame();
    });
    super.onTapUp(event);
  }
}
