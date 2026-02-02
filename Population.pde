class Population {
  Person[] persons;
  
  Population(int count) {
    persons = new Person[count];
    for(int i = 0; i < count; i++) {
      persons[i] = new Person(random(width), random(height));
    }
  }
  
  void update() {
    for(Person p : persons) p.update();
  }
  
  void display() {
    for(Person p : persons) p.display();
  }
  
  // Collision Detection
  void spreadInfection(float radius, float chance) {
    for(Person p : persons) {
      if(!p.isInfected()) continue; // Only infected can spread
      
      for(Person other : persons) {
        if(other.isHealthy()) {
          float d = dist(p.pos.x, p.pos.y, other.pos.x, other.pos.y);
          if(d < radius && random(1) < chance) {
            other.infect();
          }
        }
      }
    }
  }
  
  // patient zero
  void infectRandom() {
    persons[0].infect(); 
  }

  boolean vaccinateAt(float x, float y) {
  for(Person p : persons) {
    // Check if mouse is clicking this person (with some wiggle room of 20px)
    if(dist(x, y, p.pos.x, p.pos.y) < 20 && p.isHealthy()) {
      p.makeImmune();
      return true; // Successful vaccination
    }
  }
  return false;
}
}