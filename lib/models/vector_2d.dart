import 'dart:math';

class Vector2D {
  double x, y;

  Vector2D(this.x, this.y);

  Vector2D sum(Vector2D b) {
    return Vector2D(x + b.x, y + b.y);
  }

  Vector2D sub(Vector2D b) {
    return Vector2D(x - b.x, y - b.y);
  }

  double distanceSquared(Vector2D other) {
    double dx = other.x - x;
    double dy = other.y - y;

    return (dx * dx) + (dy * dy);
  }

  double distance(Vector2D other) {
    return sqrt(distanceSquared(other));
  }

  double dotProduct(Vector2D other) {
    return other.x * x + other.y * y;
  }

  Vector2D normalize() {
    double magnitude = sqrt(dotProduct(this));
    return Vector2D(x / magnitude, y / magnitude);
  }

  Vector2D mult(double scalar) {
    return Vector2D(x * scalar, y * scalar);
  }

  @override
  String toString() => '($x, $y)';
}
