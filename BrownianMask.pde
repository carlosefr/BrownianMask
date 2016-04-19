/*
 * BrownianMask.pde
 *
 * Copyright (c) 2014 Carlos Rodrigues <cefrodrigues@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


// B&W palette...
static final color BG_COLOR = 0;
static final color[] PALETTE = {#0f0f0f, #0c0c0c, #0a0a0a, #080808, #ffffff};

// Restart the painting every so often...
static final float RESTART_INTERVAL = 45 * 1000.0;  // ...milliseconds.
static final float FADE_INTERVAL = 500.0;  // ...milliseconds.


PImage mask;
Painting painting;

float start = -MAX_INT;


void setup() {
  size(1024, 576, P2D);
  frameRate(24);

  mask = loadImage("data/worldmap.png");
  background(BG_COLOR);
}


void draw() {
  float now = millis();
  float elapsed = now - start;

  if (elapsed > RESTART_INTERVAL) {
    // Restart every so often to maintain interest...
    painting = new Painting(mask, PALETTE, BG_COLOR);
    start = now;
    noTint();
  } else if (elapsed > RESTART_INTERVAL - FADE_INTERVAL) {
    // Fade before restarting the painting...
    tint(BG_COLOR, 64);
  }
      
  painting.update();
  image(painting.draw(), 0, 0);
}


void mousePressed() {
  // Restart the painting immediately...
  painting = new Painting(mask, PALETTE, BG_COLOR);
  start = millis();
}


/* EOF - BrownianMask.pde */
