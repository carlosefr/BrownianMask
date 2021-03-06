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
 * in the "data" folder of this sketch, containing the line:
 *
 *    api-key=YOUR_API_KEY
 *
 * Do not use quotes in the key.
 */


import java.util.Properties;

import processing.pdf.*;

import colorLib.*;
import colorLib.webServices.*;


// Optionally produce a PDF for every painting...
static final boolean PDF_OUTPUT = false;

// Output path for frame snapshots...
static final String FRAME_TEMPLATE = String.format("snapshots-%d%02d%02d-%02d%02d%02d/########.png", year(), month(), day(), hour(), minute(), second());

// The initial palette can be forced, or obtained dynamically from Kuler...
static final color[] INITIAL_PALETTE = null /* {#250222, #3f0b35, #c1a598, #f2e1d8, #100b0b} */;


/*
 * A PNG snapshot of each frame will be continuously dumped while recording is active.
 * These can be composed later into a video with an "ffmpeg" command like the following:
 *
 *   ffmpeg -r 24 -f image2 -i 'snapshots-20141012-151745/%08d.png' -y video-20141012-151745.mp4
 */
boolean recording = false;

PImage mask;
PImage canvas;
Painting painting;
Palette[] themes;
String kulerKey;


void setup() {
  size(1024, 576, JAVA2D);
  frameRate(24);

  Properties p = new Properties();

  try {
    p.load(createReader("data/kuler.properties"));
  } catch (IOException e) {
    e.printStackTrace();
    return;
  }

  kulerKey = p.getProperty("api-key", "");

  mask = loadImage("worldmap.png");
  canvas = loadImage("canvas.png");

  painting = new Painting(mask, INITIAL_PALETTE != null ? INITIAL_PALETTE : getPalette(), PDF_OUTPUT);
}


void draw() {
  painting.update();

  // We cound draw the canvas first but, since the painting has
  // the same dimensions as our frame, this way is much faster...
  background(painting.draw());
  blend(canvas, 0, 0, width, height, 0, 0, width, height, MULTIPLY);

  if (frameCount % 100 == 0) {
    println(String.format("%.1f fps", frameRate));
  }

  if (recording) {
    saveFrame(FRAME_TEMPLATE);
  }
}


void keyReleased() {
  // Restart the painting...
  if (key == ' ') {
    painting.dispose();  // ...write the PDF (if any).
    painting = new Painting(mask, getPalette(), PDF_OUTPUT);
    println("Restarted painting at frame " + frameCount + ".");
  }

  // Save a snapshot...
  if (key == 'c') {
    saveFrame(FRAME_TEMPLATE);
    println("Captured snapshot at frame " + frameCount + ".");
  }

  // Toggle recording...
  if (key == 'r') {
    recording = !recording;
    println((recording ? "Started" : "Stopped") + " recording at frame " + frameCount + ".");
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


void dispose() {
  // Ensure the PDF (if any) gets written on exit...
  painting.dispose();
}


/* EOF - BrownianMask.pde */
