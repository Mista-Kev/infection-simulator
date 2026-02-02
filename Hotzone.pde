class Hotzone {

  PVector center;
  float radius = 0;
  float maxRadius = 100;

  float effectRadius = 0;
  float HOTZONE_RADIUS_BONUS = 20;

  Hotzone(ArrayList<Person> cluster) {
    // Calculate center of the cluster
    float sumX = 0, sumY = 0;
    for (Person p : cluster) { 
      sumX += p.pos.x; 
      sumY += p.pos.y; 
    }
    center = new PVector(sumX / cluster.size(), sumY / cluster.size());

    // Calculate the radius based on the furthest person
    float maxDist = 0;
    for (Person p : cluster) {
      float d = PVector.dist(center, p.pos);
      if (d > maxDist) maxDist = d;
    }

    radius = maxDist + 15;
    effectRadius = radius + HOTZONE_RADIUS_BONUS;
  }

  // collision detection
  boolean contains(PVector pos) {
    return PVector.dist(center, pos) < effectRadius;
  }

  void display() {
    float pulse = 1.0 + sin(millis() * 0.005) * 0.1;

    pushMatrix();
    translate(center.x, center.y);
    scale(pulse);
    rotate(millis() * 0.001);

    noFill();

    stroke(255, 50, 50, 150);
    strokeWeight(2);
    ellipse(0, 0, radius * 2, radius * 2);

    noStroke();
    fill(255, 50, 50, 40);
    ellipse(0, 0, radius, radius);

    fill(255, 100, 100);
    for (int i = 0; i < 3; i++) {
      ellipse(radius, 0, 8, 8);
      rotate(TWO_PI / 3.0);
    }

    popMatrix();

    fill(255, 200, 200);
    textSize(10);
    textAlign(CENTER);
    text("HOTZONE", center.x, center.y + 5);
  }
}
