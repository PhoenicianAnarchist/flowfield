color clerp(color c1, color c2, float t) {

  color nc = color(
    (red(c1)   * t) + (red(c2)   * (1.0 - t)),
    (green(c1) * t) + (green(c2) * (1.0 - t)),
    (blue(c1)  * t) + (blue(c2)  * (1.0 - t)),
    (alpha(c1) * t) + (alpha(c2) * (1.0 - t))
  );

  return nc;
}

class Particle {
  Particle(PVector position, String color_mode, int alpha) {
    this.position = position;
    this.velocity = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);

    this.is_alive = true;

    switch (color_mode) {
      case "cm":
        color cyan = color(0, 255, 255, alpha);
        color magenta = color(255, 0, 255, alpha);
        this.c = clerp(cyan, magenta, position.x / width);
        break;

      case "xy":
        int r = int(map(position.x, 0, width, 0, 255));
        int b = int(map(position.y, 0, height, 0, 255));

        this.c = color(
          ((255 - r) + b        ) / 2.0,
          (r         + b        ) / 2.0,
          (r         + (255 - b)) / 2.0,
          alpha
        );
        break;
      default: case "g":
        this.c = color(255, alpha);
    }
  }

  void setColor(color c) {
    this.c = c;
  }

  void applyForce(PVector force) {
    this.acceleration.add(force);
  }

  void update() {
    this.velocity.add(this.acceleration);
    this.position.add(this.velocity);
    this.acceleration.mult(0);
    this.velocity.mult(0.99);
  }

  void draw() {
    stroke(this.c);
    point(this.position.x, this.position.y);
  }

  PVector position;
  PVector velocity;
  PVector acceleration;
  color c;
  boolean is_alive;
}
