 
// Settings
int NUM_PEOPLE = 100;
float INFECTION_RADIUS = 45;
float INFECTION_CHANCE = 0.012;
float HOTZONE_RADIUS_BONUS = 25; 

int TOTAL_VACCINES = 8; 
int GAME_DURATION = 60;
int VACCINE_COOLDOWN = 500;

Population population;
ArrayList<Hotzone> hotzones;

boolean gameStarted = false; // needed for start screen
boolean gameEnded = false; 
boolean playerWon = false;

int startTime;
int vaccinesLeft;
int lastVaccineTime = 0;


void setup() {
  size(1000, 700);
  resetSim();
}

void resetSim() {
  population = new Population(NUM_PEOPLE);
  hotzones = new ArrayList<Hotzone>();
  vaccinesLeft = TOTAL_VACCINES;
  
  gameStarted = false;
  gameEnded = false;
  startTime = millis(); 

  // 2 patient zeros
  population.infectRandom();
  population.infectRandom();
}

void draw() {
  fill(25, 20, 35, 60);
  noStroke();
  rect(0, 0, width, height);

  if (!gameEnded) {
    updateGameLogic(); 
  }
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
  int total = NUM_PEOPLE;
  
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

void updateGameLogic() {
  detectHotzones();
  
  // link hotzone and population
  population.spreadInfection(INFECTION_RADIUS, INFECTION_CHANCE, hotzones);
  population.update();

  // Stats 
  int infected = population.getInfectedCount();
  int total = NUM_PEOPLE;
  int elapsed = (millis() - startTime) / 1000;

  // Game Over if > 80% infected
  if (infected > total * 0.80) {
    gameEnded = true;
    playerWon = false;
    println("DEBUG: Lost via infection limit"); 
  }
  // Time up
  else if (elapsed >= GAME_DURATION) {
    gameEnded = true;
    // Win if we kept it under 80%
    playerWon = (infected <= total * 0.80);
    println("DEBUG: Time up. Won? " + playerWon);
  }
}

void detectHotzones() {
  hotzones.clear();
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
  boolean success = population.vaccinateNearest(mouseX, mouseY, 60);
  if (success) {
    println("Vaccine deployed!");
  }
}
