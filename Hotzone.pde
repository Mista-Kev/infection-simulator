class Hotzone {

  PVector center;
  float radius = 0;
  float maxRadius = 100;

  Hotzone(ArrayList<Person> cluster) {
    // Calculate center of the cluster
    float sumX = 0, sumY = 0;
    for (Person p : cluster) { 
      sumX += p.pos.x; 
      sumY += p.pos.y; 
    }
    center = new PVector(sumX / cluster.size(), sumY / cluster.size());
  }

  void display() {
    radius = lerp(radius, maxRadius, 0.05); // Animation
    noFill();
    stroke(255, 50, 50, 150); // Red Warning Ring
    strokeWeight(2);
    ellipse(center.x, center.y, radius * 2, radius * 2);
  }
}
