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
  
  // Collision Detection,, now with hotzone
  void spreadInfection(float radius, float chance, ArrayList<Hotzone> hotzones) {
    for(Person p : persons) {
      if(!p.isInfected()) continue; 
      
      float currentRadius = radius;
      float currentChance = chance;
      
      // LOGIC: If inside a Hotzone, spread 2x faster!
      if (hotzones != null) {
        for (Hotzone hz : hotzones) {
          if (hz.contains(p.pos)) {
             currentRadius += 25; // Bonus Radius
             currentChance *= 2.0; 
          }
        }
      }
      
      // Standard Spread
      for(Person other : persons) {
        if(other.isHealthy()) {
          float d = dist(p.pos.x, p.pos.y, other.pos.x, other.pos.y);
          if(d < currentRadius && random(1) < currentChance) {
            other.infect();
          }
        }
      }
    }
  }
  
  // patient zero
  void infectRandom() {
    int r = int(random(persons.length));
    persons[r].infect(); // so we can now have more than one patient zero
  }

 boolean vaccinateNearest(float x, float y, float maxDist) {
    Person p = getNearest(x, y);
    if (p != null && p.isHealthy() && dist(x,y,p.pos.x,p.pos.y) < maxDist) {
      p.makeImmune(true); 
      return true;
    }
    return false;
  }

  Person getNearest(float x, float y) {
    Person nearest = null;
    float minDist = 9999;
    for (Person p : persons) {
      float d = dist(x, y, p.pos.x, p.pos.y);
      if (d < minDist) { minDist = d; nearest = p; }
    }
    return nearest;
  }
  
// counters for HUD
int getInfectedCount() {
  int count = 0;
  for (Person p : persons) {
    if (p.isInfected()) count++;
  }
  return count;
}

int getHealthyCount() {
  int count = 0;
  for (Person p : persons) {
    if (p.isHealthy()) count++;
  }
  return count;
}

int getImmuneCount() {
  int count = 0;
  for (Person p : persons) {
    if (p.isImmune()) count++;
  }
  return count;
}
}