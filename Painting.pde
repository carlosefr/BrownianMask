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
static final int NUM_SOURCES = 1;

// The total number of particles...
static final int NUM_PARTICLES = NUM_SOURCES * 8;

// The scale of the particles (smaller number = larger particles)...
static final float PARTICLE_SCALE = 100.0;


class Painting {
  private PGraphics gfx;
  private Particle[] particles;
  private color[] palette;
  
  private float zoom;
  
  Painting(color[] palette) {
    this.palette = palette;
    
    this.gfx = createGraphics(width, height, JAVA2D);

    float[] sx = new float[NUM_SOURCES];
    float[] sy = new float[NUM_SOURCES];

    // Source points for the particles...
    for (int i = 0; i < NUM_SOURCES; i++) {
      sx[i] = random(this.gfx.width/5.0, this.gfx.width - this.gfx.width/5.0);
      sy[i] = random(this.gfx.height/5.0, this.gfx.height - this.gfx.height/5.0);
    }
  
    // Scale things according to the canvas size...
    this.zoom = min(this.gfx.width, this.gfx.height) / PARTICLE_SCALE;
  
    this.particles = new Particle[NUM_PARTICLES];
    
    // Start the particles evenly over the available source points...
    for (int i = 0; i < NUM_PARTICLES; i++) {
      this.particles[i] = new Particle(sx[i % sx.length], sy[i % sy.length], this.palette[round(random(0, this.palette.length - 1))], this.zoom);
    }

    // Initialize out private graphics context...  
    this.gfx.beginDraw();
    this.gfx.smooth();
    this.gfx.background(255);
    this.gfx.endDraw();
  }
  
  PImage update() {
    this.gfx.beginDraw();
    
    // Fade-out a random circular portion of the painting...
    if (frameCount % 100 == 0) {
      this.gfx.noStroke();
      this.gfx.fill(255, 32);
      this.gfx.ellipse(random(0, this.gfx.width), random(0, this.gfx.width), 400 * this.zoom, 400 * this.zoom);
    }
    
    this.gfx.noStroke();
    
    // Draw a "smudge" when particles come close together...
    for (int i = 0; i < this.particles.length; i++) {
      Particle a = this.particles[i];
      
      for (int j = i + 1; j < this.particles.length; j++) {
        Particle b = this.particles[j];  
        float distance = dist(a.x, a.y, b.x, b.y);
        
        if (distance > 40 * this.zoom && distance < 45 * this.zoom) {
          this.gfx.fill(blendColor(a.c, b.c, ADD), 16);
          this.gfx.ellipse((a.x + b.x) / 2.0, (a.y + b.y) / 2.0, distance/2.0, distance/2.0);
        }
      }
    }
    
    // Now draw the particles themselves...
    for (Particle p : this.particles) {
      p.update();
      p.draw(this.gfx);
    }

    this.gfx.endDraw();
    
    return this.gfx;
  }
}


/* EOF - Painting.pde */
