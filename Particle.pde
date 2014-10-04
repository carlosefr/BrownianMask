/*
 * Particle.pde
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


class Particle {
  // Current position...
  public float x;
  public float y;

  // Previous position...
  public float px;
  public float py;
  
  public color c;
  
  private float range;
  
  Particle(float x, float y, color c, float zoom) {
    this.x = x;
    this.y = y;

    this.px = x;
    this.py = y;
    
    this.c = c;
    
    // The maximum motion range at each step...
    this.range = random(6 * zoom, 10 * zoom);
  }
  
  void setColor(color c) {
    this.c = c;
  }

  void update() {
    this.px = this.x;
    this.py = this.y;

    // Wander around randomly...
    this.x += random(-this.range, this.range);
    this.y += random(-this.range, this.range);
  
    // But stay on screen...
    this.x = constrain(this.x, 0, width - 1);
    this.y = constrain(this.y, 0, height - 1);
  }
  
  void draw(PGraphics gfx) {
    gfx.pushStyle();
    
    // Cycle the particle size over time...
    float radius = ((frameCount + this.range) % this.range) + 1;
    
    gfx.noStroke();
    gfx.fill(this.c, 192);
    gfx.ellipse(this.x, this.y, radius, radius);

    gfx.popStyle();
  }
}


/* EOF - Particle.pde */
