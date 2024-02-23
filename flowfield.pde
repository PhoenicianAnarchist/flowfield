boolean redraw;

int cell_size = 1;              // each cell contains it's own vector
float scale_factor = 64.0;      // adjust scale of noise field (higher == larger features)
float reduction_factor = 0.01;  // reduce influence of flow field
int num_particles = 10000;
int max_frames = 0;

String color_theme = "g";
int alpha = 1;

int num_columns;
int num_rows;

JSONObject config;
PVector[] vecs;
Particle[] particles;
int seed = 0;

void saveImage() {
  String filename;

  String ss = String.format("%6d", seed).replace(' ', '0');
  String fc = String.format("%6d", frameCount).replace(' ', '0');
  filename = String.format("out/%s_%s.png", ss, fc);
  save(filename);

  filename = String.format("out/%s_%s.json", ss, fc);
  config = new JSONObject();
  config.setInt("seed", seed);
  config.setInt("cell_size", cell_size);
  config.setFloat("scale_factor", scale_factor);
  config.setFloat("reduction_factor", reduction_factor);
  config.setInt("num_particles", num_particles);
  config.setInt("width", width);
  config.setInt("height", height);
  config.setInt("frameCount", frameCount);

  JSONObject ct = new JSONObject();
  ct.setString("theme", color_theme);
  ct.setInt("alpha", alpha);
  config.setJSONObject("color", ct);

  saveJSONObject(config, filename);
}

int getIndex(PVector p) {
  int x = int(p.x / cell_size);
  int y = int(p.y / cell_size);

  if (
    (x < 0) || (x >= num_columns) ||
    (y < 0) || (y >= num_rows)
  ) {
    return -1;
  }

  int row_offset = y * num_columns;
  int index = row_offset + x;

  return index;
}

void setup() {
  size(512, 512);

  if (seed == 0) {
    seed = (hour() * 10000) + (minute() * 100) + second();
  }
  println(seed);
  randomSeed(seed);
  noiseSeed(seed);

  particles = new Particle[num_particles];
  for (int i = 0; i < num_particles; ++i) {
    float x = random(0, width);
    float y = random(0, height);
    particles[i] = new Particle(new PVector(x, y), color_theme, alpha);
  }

  num_columns = width / cell_size;
  num_rows = height / cell_size;

  vecs = new PVector[num_rows * num_columns];

  for (int y = 0; y < num_rows; ++y) {
    int row_offset = y * num_columns;

    for (int x = 0; x < num_columns; ++x) {
      int index = row_offset + x;
      float n = map(noise(x / scale_factor, y / scale_factor), 0, 1.0, 0 - (PI/2.0), TWO_PI - (PI/2.0));
      PVector v = PVector.fromAngle(n);
      vecs[index] = v;
    }
  }

  background(0);
  redraw = true;
}

void draw() {
  if (!redraw) {
    return;
  }

  for (int i = 0; i < num_particles; ++i) {
    if (!particles[i].is_alive) {
      continue;
    }

    int index = getIndex(particles[i].position);

    if (index == -1) {
      float x = random(0, width);
      float y = random(0, height);
      particles[i].is_alive = false;
      continue;
    }

    PVector force = vecs[index].copy().mult(reduction_factor);
    particles[i].applyForce(force);
    particles[i].update();
    particles[i].draw();
  }

  int living_count = 0;
  for (int i = 0; i < num_particles; ++i) {
    if (particles[i].is_alive) {
      living_count += 1;
    }
  }

  if (living_count <= 0) {
    println("all particles are dead");
    redraw = false;
    saveImage();
  }

  if (frameCount == max_frames) {
    println("max frames reached");
    redraw = false;
    saveImage();
  }
}

void keyPressed() {
  switch (key) {
    case 'r': redraw = true; break;
    case 's': saveImage(); break;
  }
}
