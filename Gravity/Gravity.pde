ArrayList<Body> bodies = new ArrayList<Body>();
ArrayList<Body> despawnQueue = new ArrayList<Body>();
int despawnCount = 0;
float G = 6.674E-11; // gravitational constant

// Processing clears matrix transformations every draw() call
// so a custom translation system is needed
PVector gridChange = new PVector(); 

// for interactively creating new bodies
PVector newPos = new PVector();
float newRadius;
float newVelMag;
String textField = "r=" + newRadius;
boolean creating = false;

// calculate velocity vector
PVector getNewVel() {
  PVector newVel = new PVector(mouseX - newPos.x, mouseY - newPos.y);
  newVel.normalize().mult(newVelMag);
  return newVel;
}

// update either newRadius or newVelMag
void updateNewBody() {
  float newVal;
  if (textField.length() == 2) {
    newVal = 0;
  } else {
    newVal = Float.parseFloat(textField.substring(2, textField.length()));
  }
  
  if (textField.charAt(0) == 'r') {
    newRadius = newVal;
  } else {
    newVelMag = newVal;
  }
}

// for pausing
boolean paused = false;

// font
PFont roboto_mono;

void setup() {
  size(1140, 720);
  // fullScreen();
  frameRate(60);
  
  roboto_mono = createFont("RobotoMono-Regular", 23);
  textFont(roboto_mono);
  cursor(CROSS);
          
  bodies.add(new Body(700, 400, 0, 4, 50));
  bodies.add(new Body(400, 400, 0, -4, 50));
}

void draw() {
  background(0);
  
  // move using wasd
  if (keyPressed) {
    switch (key) {
      case 'w':
        gridChange.y += 10;
        break;
      case 'a':
        gridChange.x += 10;
        break;
      case 's':
          gridChange.y -= 10;
          break;
      case 'd':
        gridChange.x -= 10;
    }
  }
  
  if (!paused) {
    for (Body b : bodies) {
      b.calcVel();
      b.collisionCheck();
    }
    
    for (Body b : bodies) {
      b.update();
    }
  }
  
  for (Body b : bodies) {
    b.show();
  }
  
  for (Body b : despawnQueue) {
    bodies.remove(b);
  }
  
  despawnCount += despawnQueue.size();
  despawnQueue.clear();
  
  // if creating new body
  if (creating) {
    newPos.add(gridChange);

    noStroke();
    fill(255, 150);
    circle(newPos.x, newPos.y, newRadius * 2);
    
    stroke(232, 28, 28, 150);
    strokeWeight(3);
    
    if (textField.charAt(0) == 'v') {
      PVector newVel = getNewVel();
      line(newPos.x, newPos.y, newPos.x + newVel.x * 4, newPos.y + newVel.y * 4);
    }
    
    fill(32, 199, 90, 150);
    textAlign(CENTER);
    text(textField + "_", newPos.x, newPos.y - newRadius - 15);
  }
  
  fill(32, 199, 90);
  textAlign(LEFT);
  text("FPS: " + round(frameRate), 15, 35);
  text("Objects: " + bodies.size() + (despawnCount > 0 ? " [-" + despawnCount + "]" : ""), 15, 65);
  
  if (paused) {
    textAlign(RIGHT);
    text("PAUSED", width - 15, 35);
  }
    
  gridChange.set(0, 0);
}

// to pause
void keyPressed() {
  if (key == ' ') {
    if (!paused) {
      paused = true;
    } else {
      paused = false;
    }
  }
}

// to create new body
void mouseClicked() {
  if (!creating) {
    creating = true;
    newPos.set(mouseX, mouseY);
  } else {
    textField = "r=";
    creating = false;
  }
}

void keyTyped() {
  if (creating) {
    // delete key
    if (key == 8) {
      if (textField.length() > 2) {
        textField = textField.substring(0, textField.length() - 1);
        updateNewBody();
      }
    }
    
    if (key >= '0' && key <= '9' || key == '.') {
      try  {
        textField += key;
        updateNewBody();
      } catch (NumberFormatException e) {
        textField = textField.substring(0, textField.length() - 1);
      }
    }
    
    // enter key
    if (key == 10) {
      if (textField.charAt(0) == 'r') {
        textField = "v=";
      } else {
        PVector newVel = getNewVel();
        bodies.add(new Body(newPos.x, newPos.y, newVel.x, newVel.y, newRadius));
        textField = "r=";
        creating = false;
      }
    }
  }
}
