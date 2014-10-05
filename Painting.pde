/*
 * Painting.pde
 *
 * Copyright (c) 2011 Carlos Rodrigues <cefrodrigues@gmail.com>
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


// The number of places from which particles originate...
static final int NUM_SOURCES = 20;

// The total number of particles...
static final int NUM_PARTICLES = NUM_SOURCES * 8;

// The scale of the particles (smaller number = larger particles)...
static final float PARTICLE_SCALE = 500.0;


class Painting {
  private PGraphics[] gfx;
  private Particle[] particles;
  private PImage mask;
  private color[] palette;

  private float zoom;

  Painting(PImage mask, color[] palette, boolean print) {
    assert palette.length >= 2 : "the palette needs to have at least two colors";

    this.mask = mask;
    this.mask.resize(width, height);
    this.mask.filter(THRESHOLD, 0.7);  // ...the mask image should already be close to pure black/white.
    this.mask.loadPixels();

    this.palette = palette;

    float[] sx = new float[NUM_SOURCES];
    float[] sy = new float[NUM_SOURCES];

    // Source points for the particles...
    for (int i = 0; i < NUM_SOURCES; i++) {
      sx[i] = random(width/5.0, width - width/5.0);
      sy[i] = random(height/5.0, height - height/5.0);
    }

    // Scale things according to the canvas size...
    this.zoom = min(width, height) / PARTICLE_SCALE;

    this.particles = new Particle[NUM_PARTICLES];

    // The particle's start position does not influence their
    // initial color, to make the mask image appear from chaos...
    for (int i = 0; i < NUM_PARTICLES; i++) {
      // Start the particles evenly over the available source points...
      this.particles[i] = new Particle(sx[i % sx.length], sy[i % sy.length], this.palette[round(random(0, this.palette.length - 1))], this.zoom);
    }

    this.gfx = new PGraphics[print ? 2 : 1];
    this.gfx[0] = createGraphics(width, height, JAVA2D);

    // The bitmap context must be properly initialized...
    this.gfx[0].beginDraw();
    this.gfx[0].smooth();
    this.gfx[0].background(255);
    this.gfx[0].endDraw();

    if (print) {
      // Output an optional PDF (which only gets written on dispose)...
      String timestamp = String.format("%d%02d%02d-%02d%02d%02d", year(), month(), day(), hour(), minute(), second());
      this.gfx[1] = createGraphics(width, height, PDF, "print-" + timestamp + ".pdf");
    }
  }

  PImage update() {
    for (int g = 0; g < this.gfx.length; g++) {
      this.gfx[g].beginDraw();
    }

    // Fade-out a random circular portion of the painting...
    if (frameCount % 100 == 0) {
      float x = random(0, width);
      float y = random(0, height);
      float diameter = 400 * this.zoom;

      for (int g = 0; g < this.gfx.length; g++) {
        this.gfx[g].noStroke();
        this.gfx[g].fill(255, 32);
        this.gfx[g].ellipse(x, y, diameter, diameter);
      }
    }

    // Update particle positions and colors...
    for (Particle p : this.particles) {
      p.update();

      color prevMaskColor = this.mask.pixels[int(p.px) + int(p.py) * width];
      color currMaskColor = this.mask.pixels[int(p.x) + int(p.y) * width];

      if (currMaskColor == prevMaskColor) {
        // Same color area, keep the particle's color...
        continue;
      }

      if (currMaskColor < prevMaskColor) {
        // Stepping into a black area...
        p.setColor(this.palette[this.palette.length - 1]);
      } else {
        // Stepping into a white area...
        p.setColor(this.palette[round(random(0, this.palette.length - 2))]);
      }
    }

    for (int g = 0; g < this.gfx.length; g++) {
      this.gfx[g].noStroke();
    }

    // Draw a "smudge" when particles come close together...
    for (int i = 0; i < this.particles.length; i++) {
      Particle a = this.particles[i];

      for (int j = i + 1; j < this.particles.length; j++) {
        Particle b = this.particles[j];
        float distance = dist(a.x, a.y, b.x, b.y);

        if (distance > 40 * this.zoom && distance < 45 * this.zoom) {
          color c = blendColor(a.c, b.c, ADD);
          float x = (a.x + b.x) / 2.0;
          float y = (a.y + b.y) / 2.0;
          float diameter = distance/2.0;

          for (int g = 0; g < this.gfx.length; g++) {
            this.gfx[g].fill(c, 16);
            this.gfx[g].ellipse(x, y, diameter, diameter);
          }
        }
      }
    }

    // Now draw the particles themselves...
    for (Particle p : this.particles) {
      for (int i = 0; i < this.gfx.length; i++) {
        p.draw(this.gfx[i]);
      }
    }

    for (int g = 0; g < this.gfx.length; g++) {
      this.gfx[g].endDraw();
    }

    // Return the bitmap for display...
    return this.gfx[0];
  }

  void dispose() {
    // Disposing of the bitmap is optional, but the PDF requires it to get written...
    for (int g = 0; g < this.gfx.length; g++) {
      this.gfx[g].dispose();
    }
  }
}


/* EOF - Painting.pde */
