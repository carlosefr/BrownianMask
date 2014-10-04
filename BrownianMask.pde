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

/*
 * This program requires a valid Kuler API key. Get one at:
 *
 *    https://kuler.adobe.com
 *
 * When you have your key, create a "kuler.properties" file
 * in the same folder as this sketch, containing the line:
 *
 *    api-key=YOUR_API_KEY
 *
 * Do not use quotes in the key.
 */


import java.util.Properties;

import processing.opengl.*;

import colorLib.*;
import colorLib.webServices.*;

import processing.video.*;


PImage mask;
PImage canvas;
Painting painting;
Palette[] themes;
String kulerKey;


void setup() {
  mask = loadImage("worldmap.png");

  size(mask.width, mask.height, JAVA2D);
  frameRate(24);

  //glSync(true);
  //glSmooth(false);

  Properties p = new Properties();

  try {
    p.load(createReader("kuler.properties"));
  } catch (IOException e) {
    e.printStackTrace();
    return;
  }

  kulerKey = p.getProperty("api-key", "");

  canvas = loadImage("canvas.png");
  painting = new Painting(mask, getPalette());
}


void draw() {
  PImage p = painting.update();

  // We cound draw the canvas first but, since the painting has
  // the same dimensions as our frame, this way is much faster...
  background(p);
  blend(canvas, 0, 0, width, height, 0, 0, width, height, MULTIPLY);

  if (frameCount % 100 == 0) {
    println(frameRate + " fps");
  }
}


void keyReleased() {
  // Restart the painting...
  if (key == ' ') {
    painting = new Painting(mask, getPalette());
  }

  // Save a snapshot...
  if (key == 'c') {
    saveFrame("painting-" + frameCount + ".png");
  }
}


color[] getPalette() {
  if (themes == null) {
    Kuler kuler = new Kuler(this);

    kuler.setKey(kulerKey);
    kuler.setNumResults(20);

    themes = kuler.getPopular();
  }

  return themes[round(random(0, themes.length - 1))].getColors();
}


/* EOF - BrownianMask.pde */
