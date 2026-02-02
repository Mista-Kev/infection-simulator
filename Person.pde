class Person {
  // States
  final int HEALTHY = 0;
  final int INFECTED = 1;
  final int IMMUNE = 2; // Preparing for later
  
  PVector pos, vel;
  float size = 12;
  int state = HEALTHY; // Everyone starts healthy
  
  Person(float x, float y) {
    pos = new PVector(x, y);
    vel = PVector.random2D().mult(1.5);
  }
  
  void infect() {
    state = INFECTED;
  }
  
  void makeImmune() {
  if (state == HEALTHY) {
    state = IMMUNE;
  }
}

boolean isImmune() { 
  return state == IMMUNE; 
}


  void update() {
    pos.add(vel);
    // Boundary checks
    if (pos.x < 0 || pos.x > width) vel.x *= -1;
    if (pos.y < 0 || pos.y > height) vel.y *= -1;
  }
  
  void display() {
    noStroke();
    if (state == HEALTHY) fill(100, 150, 255); // Blue
    else if (state == INFECTED) fill(220, 70, 70); // Red
    else fill(80, 255, 150); // Green (Immune)
    
    ellipse(pos.x, pos.y, size, size);
  }
  
  boolean isHealthy() { return state == HEALTHY; }
  boolean isInfected() { return state == INFECTED; }
}