//SHF - Weather System
//Nov 2023

// Tweakable parameters
int SNOW_COLOR = color(255);
int SNOWFLAKES_PER_LAYER = 200;
int MAX_SIZE = 10;
float GRAVITY = 0.75;
int LAYER_COUNT = 4;

int SKY_COLOR = color(177, 232, 255);
float SKY_SPACE = 0.4;

float WIND_SPEED = 1;
float WIND_CHANGE = 0.0025;

int SUN_COLOR = color(255, 242, 173);
int SUN_GLOW = 100;
int SUN_RADIUS = 150;

int RIDGE_TOP_COLOR = color(188, 206, 221);
int RIDGE_BOT_COLOR = color(126, 156, 185);
int RIDGE_STEP = 4;
int RIDGE_AMP = 250;
float RIDGE_ZOOM = 0.005;

ArrayList<Snowflake[]> SNOWFLAKES;

void setup() {
  size(1080, 1350);
  fill(SNOW_COLOR);
  noStroke();

  // Initialize the snowflakes with random positions
  SNOWFLAKES = new ArrayList<Snowflake[]>();
  for (int l = 0; l < LAYER_COUNT; l++) {
    Snowflake[] layer = new Snowflake[SNOWFLAKES_PER_LAYER];
    for (int i = 0; i < SNOWFLAKES_PER_LAYER; i++) {
      layer[i] = new Snowflake(random(width), random(height), random(0.75, 1.25), l + 1);
    }
    SNOWFLAKES.add(layer);
  }
}

void draw() {
  background(SKY_COLOR);
  int skyHeight = round(height * SKY_SPACE);
  drawSun(width / 2, skyHeight - RIDGE_AMP / 2);

  // Iterate through the layers of snowflakes
  for (int l = 0; l < SNOWFLAKES.size(); l++) {
    Snowflake[] snowLayer = SNOWFLAKES.get(l);

    // Draw a ridge for each layer of snow
    float layerPosition = l * ((height - skyHeight) / LAYER_COUNT);
    drawRidge(l, skyHeight + layerPosition);

    // Draw each snowflake
    for (int i = 0; i < snowLayer.length; i++) {
      Snowflake snowflake = snowLayer[i];
      ellipse(snowflake.x, snowflake.y, (snowflake.l * MAX_SIZE) / LAYER_COUNT, (snowflake.l * MAX_SIZE) / LAYER_COUNT);
      updateSnowflake(snowflake);
    }
  }
}

// Draw a simple sun
void drawSun(float x, float y) {
  fill(SUN_COLOR);
  ellipse(x, y, SUN_RADIUS * 2, SUN_RADIUS * 2);
}

// Compute and draw a ridge
void drawRidge(int l, float y) {
  // Choose a color for the ridge based on its height
  int fillColor = lerpColor(RIDGE_TOP_COLOR, RIDGE_BOT_COLOR, (float) l / (LAYER_COUNT - 1));
  fill(fillColor);

  beginShape();
  // Iterate through the width of the canvas
  for (float x = 0; x <= width; x += RIDGE_STEP) {
    float noisedY = noise(x * RIDGE_ZOOM, y);
    vertex(x, y - noisedY * RIDGE_AMP);
  }
  vertex(width, height);
  vertex(0, height);
  endShape(CLOSE);
  fill(SNOW_COLOR);
}

// Helper function to prepare a given snowflake for the next frame
void updateSnowflake(Snowflake snowflake) {
  float diameter = (snowflake.l * MAX_SIZE) / LAYER_COUNT;
  if (snowflake.y > height + diameter) snowflake.y = -diameter;
  else snowflake.y += GRAVITY * snowflake.l * snowflake.mass;

  // Get the wind speed at the given layer and area of the page
  float wind = noise(snowflake.l, snowflake.y * WIND_CHANGE, frameCount * WIND_CHANGE) - 0.5;
  if (snowflake.x > width + diameter) snowflake.x = -diameter;
  else if (snowflake.x < -diameter) snowflake.x = width + diameter;
  else snowflake.x += wind * WIND_SPEED * snowflake.l;
}

class Snowflake {
  float x, y;
  float mass;
  int l;

  Snowflake(float x, float y, float mass, int l) {
    this.x = x;
    this.y = y;
    this.mass = mass;
    this.l = l;
  }
}
