import 'dart:math';

class Scripts {
  static const double M_PI = 3.1415926535;

  static double lengthdirX(double len, double dir) {
    double angle = dir * (M_PI / 180.0);
    return len * cos(angle);
  }

  static double lengthdirY(double len, double dir) {
    double angle = dir * (M_PI / 180.0);
    return len * sin(angle);
  }

  static double pointDirection(double x1, double y1, double x2, double y2) {
    double dx = x2 - x1;
    double dy = y2 - y1;

    double angle = atan2(dy, dx);
    angle = angle * (180.0 / M_PI);

    if (angle < 0) angle += 360.0;

    return angle;
  }

  static double distanceToPoint(double x1, double y1, double x2, double y2) {
    double dx = x2 - x1;
    double dy = y2 - y1;

    return sqrt(dx * dx + dy * dy);
  }

  static double lerp(double start, double end, double t) {
    if (start < end) {
      start += t;
      if (start > end) return end;
    } else {
      start -= t;
      if (start < end) return end;
    }
    return start;
  }

  static int sign(double value) {
    if (value < 0) return -1;
    if (value > 0) return 1;
    return 0;
  }
}
