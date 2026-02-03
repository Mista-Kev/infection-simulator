 
 int POPULATION_SIZE = 100;
Population population;
ArrayList<Hotzone> hotzones;
float HOTZONE_RADIUS_BONUS = 25;

void setup() {
  size(1000, 700);

  population = new Population(POPULATION_SIZE);
  hotzones = new ArrayList<Hotzone>();

  population.infectRandom();
}

void draw() {
  fill(25, 20, 35, 60);
  noStroke();
  rect(0, 0, width, height);

  // check for clusters
  hotzones.clear();
  detectHotzones();

  population.update();
  population.spreadInfection(40, 0.05);

  // draw hotzones first
  for (Hotzone hz : hotzones) {
    hz.display();
  }

  population.display();

  // ✅ draw UI LAST (on top)
  drawHUD();
}

void drawHUD() {
  if (population == null) return;

  fill(30, 30, 40, 200);
  noStroke();
  rect(0, height - 50, width, 50);

  int infected = population.getInfectedCount();
  int healthy = population.getHealthyCount();
  int total = POPULATION_SIZE;

  textAlign(LEFT, CENTER);
  textSize(16);

  fill(100, 255, 100);
  text("HEALTHY: " + healthy, 50, height - 25);

  fill(255, 80, 80);
  text("INFECTED: " + infected, 200, height - 25);

  float healthPct = (float) healthy / total;

  fill(100);
  rect(width - 250, height - 35, 200, 20, 10);

  if (healthPct > 0.5) fill(100, 255, 100);
  else fill(255, 80, 80);

  rect(width - 250, height - 35, 200 * healthPct, 20, 10);
}

void detectHotzones() {
  ArrayList<Person> infectedList = new ArrayList<Person>();
  for (Person p : population.persons) {
    if (p.isInfected()) infectedList.add(p);
  }

  boolean[] used = new boolean[infectedList.size()];

  for (int i = 0; i < infectedList.size(); i++) {
    if (used[i]) continue;

    ArrayList<Person> cluster = new ArrayList<Person>();
    cluster.add(infectedList.get(i));
    used[i] = true;

    for (int j = 0; j < infectedList.size(); j++) {
      if (!used[j] &&
        dist(infectedList.get(i).pos.x, infectedList.get(i).pos.y,
             infectedList.get(j).pos.x, infectedList.get(j).pos.y) < 60) {

        cluster.add(infectedList.get(j));
        used[j] = true;
      }
    }

    if (cluster.size() >= 3) {
      hotzones.add(new Hotzone(cluster));
    }
  }
}

void mousePressed() {
  boolean success = population.vaccinateAt(mouseX, mouseY);
  if (success) {
    println("Vaccine deployed!");
  }
}
