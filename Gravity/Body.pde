class Body {
  float radius;
  float mass;
  PVector pos;
  PVector vel;
  int lastInFrame = millis();
  ArrayList<Body> prevCollisions = new ArrayList<Body>();
  int eventConfirmationTime = 3000;
  int deleteEventStart = 0;
  
  Body(float x, float y, float vx, float vy, float r) {
    radius = r;
    // constant density, thus constant surface gravity
    mass = 2E10 * PI * pow(r, 2);
    pos = new PVector(x, y);
    vel = new PVector(vx, vy);
  }
  
  void calcVel() {
     for (Body b : bodies) {
       if (b != this) {
         // distance between center of this body and center of b
         float distance = pos.dist(b.pos);
         // acceleration of this body towards b
         float accel = (G * b.mass) / pow(distance, 2);
         // normal of position
         PVector n = PVector.sub(b.pos, pos).normalize();
         // movement due to gravitational forces
         vel.add(PVector.mult(n, accel));
       }
     }
  }
  
  void collisionCheck() {
    ArrayList<Body> uncollidedBodies = new ArrayList<Body>(bodies);
    uncollidedBodies.removeAll(prevCollisions);
    uncollidedBodies.remove(this);
    
    for (Body b : uncollidedBodies) {
      if (pos.dist(b.pos) <= radius + b.radius) {
        // static collision
        // position difference
        PVector posDiff = PVector.sub(pos, b.pos);
        // overlap length
        float overlap = 0.5 * (posDiff.mag() - radius - b.radius);
        // displacement vector
        PVector displacementVect = posDiff.normalize().mult(overlap);
        // displace bodies away from collision
        pos.sub(displacementVect);
        b.pos.add(displacementVect);
        
        // dynamic collision
        // normal of position
        PVector n = PVector.sub(pos, b.pos).normalize();
        // velocity difference
        PVector k = PVector.sub(vel, b.vel);
        float p = 2 * k.dot(n) / (mass + b.mass);
        // update velocities
        vel.sub(PVector.mult(n, p * b.mass));
        b.vel.add(PVector.mult(n, p * mass));
        
        // no need to recalculate collision between this and b
        b.prevCollisions.add(this);
      }
    }
  }
  
  void update() {
    pos.add(vel);
    prevCollisions.clear();
    
    if (pos.x + radius >= 0 && pos.x - radius < width && 
    pos.y + radius >= 0 && pos.y - radius < height) {
      lastInFrame = millis();
      // else if out of frame for at least 18E4 ms = 3 min
    } else if (millis() - lastInFrame >= 18E4) {
      despawnQueue.add(this);
    }
  }
  
  void show() {
    pos.add(gridChange);
    
    noStroke();
    fill(255);
    circle(pos.x, pos.y, radius * 2);
    
    stroke(232, 28, 28);
    strokeWeight(3);
    line(pos.x, pos.y, pos.x + vel.x * 4, pos.y + vel.y * 4);
    
    if (pos.dist(new PVector(mouseX, mouseY)) <= radius) {
      fill(32, 199, 90);
      textAlign(CENTER);
      
      if (keyPressed) {
        switch (key) {
          case 'z':
            if (deleteEventStart == 0) {
              deleteEventStart = millis();
            }
            
            text("deleting - " + (1+ (3000 - millis() + deleteEventStart) / 1000), 
            pos.x, pos.y - radius - 15);
            
            if (millis() - deleteEventStart >= 3000) {
              despawnQueue.add(this);
            }
        }
      } else {
        deleteEventStart = 0;
        text("r=" + radius + " v=" + String.format("%.2f", vel.mag()), pos.x, pos.y - radius - 15);
      }
    }
  }
}
