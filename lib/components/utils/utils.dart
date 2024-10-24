bool checkCollisions(player, block) {
  
  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.offSetX;
  final playerY = player.position.y + hitbox.offSetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.position.x;
  final blockY = block.position.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedX = player.scale.x < 0 ? playerX - (hitbox.offSetX * 2) - playerWidth : playerX;

  return (
    playerY < blockY + blockHeight &&
    playerY + playerHeight > blockY &&
    fixedX < blockX + blockWidth &&
    fixedX + playerWidth > blockX
  );

}