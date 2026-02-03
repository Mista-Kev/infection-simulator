
// Settings
int NUM_PEOPLE = 100;
float INFECTION_RADIUS = 45;
float INFECTION_CHANCE = 0.005; // Lowered so it's not impossible
float HOTZONE_RADIUS_BONUS = 25; 

int TOTAL_VACCINES = 20; // Increased to actually make it possible to each 20%
int GAME_DURATION = 60;
int VACCINE_COOLDOWN = 200; // Faster clicking

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
  // background with transparency for trails
  // background with transparency for trails
  fill(25, 20, 35, 60);
  noStroke();
  rect(0, 0, width, height);

  // check if game has started
  if (!gameStarted) {
    drawStartScreen();
    return; 
  }

  // check if game has started
  if (!gameStarted) {
    drawStartScreen();
    return; 
  }

  if (!gameEnded) {
    updateGameLogic(); 
  }
  
  
  // draw hotzones first
  for (Hotzone hz : hotzones) {
    hz.display();
  }

  population.display();

  
  drawHUD();
  drawCursorPreview(); // bit more feedback for what you have to do

  // show end screen if needed
  if (gameEnded) {
    drawEndScreen();
  }
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
  
  // timer and vaccines 
  textAlign(CENTER);
  int time = GAME_DURATION - ((millis() - startTime)/1000);
  if(time < 0) time = 0;
  fill(255);
  text(time + "s", width/2, height - 25);

  textAlign(RIGHT);
  text("Vaccines: " + vaccinesLeft, width - 50, height - 25);
  
  // timer and vaccines 
  textAlign(CENTER);
  int time = GAME_DURATION - ((millis() - startTime)/1000);
  if(time < 0) time = 0;
  fill(255);
  text(time + "s", width/2, height - 25);

  textAlign(RIGHT);
  text("Vaccines: " + vaccinesLeft, width - 50, height - 25);

  float healthPct = (float) healthy / total;

  fill(100);
  rect(width - 250, height - 35, 200, 20, 10);

  if (healthPct > 0.5) fill(100, 255, 100);
  else fill(255, 80, 80);

  rect(width - 250, height - 35, 200 * healthPct, 20, 10);
}

// shows range of vaccine
void drawCursorPreview() {
  if (vaccinesLeft > 0 && !gameEnded && gameStarted) {
    noFill();
    stroke(100, 255, 100, 150); // Green aiming circle
    strokeWeight(2);
    ellipse(mouseX, mouseY, 40, 40); 
    noStroke();
  }
}

// new screens added by dev b
void drawStartScreen() {
  // run sim in background
  population.update();
  population.display();

  fill(0, 200);
  rect(0, 0, width, height);

  textAlign(CENTER);
  fill(100, 255, 100);
  textSize(40);
  text("INFECTION SIMULATOR", width/2, height/2 - 50);

  textSize(16);
  fill(255);
  text("Goal: Keep infection under 80%", width/2, height/2);
  text("Click to Vaccinate. Press 'R' to Restart.", width/2, height/2 + 30);
  
  fill(200);
  textSize(14);
  text("[ CLICK TO START ]", width/2, height/2 + 80);
}

void drawEndScreen() {
  fill(0, 200);
  rect(0, 0, width, height);

  textAlign(CENTER);
  textSize(50);
  
  if (playerWon) {
    fill(100, 255, 100);
    text("OUTBREAK CONTAINED", width/2, height/2 - 20);
  } else {
    fill(255, 80, 80);
    text("CRITICAL FAILURE", width/2, height/2 - 20);
  }
  
  fill(255);
  textSize(20);
  text(playerWon ? "Majority saved." : "Infection > 80%", width/2, height/2 + 40);

  fill(150);
  textSize(14);
  text("Press 'R' to Restart", width/2, height/2 + 100);
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
  // start game on click
  if (!gameStarted) {
    gameStarted = true;
    startTime = millis();
    return;
  }

  if (gameEnded) return;

  if (vaccinesLeft > 0 && millis() - lastVaccineTime > VACCINE_COOLDOWN) {
    boolean success = population.vaccinateNearest(mouseX, mouseY, 60);
    if (success) {
      vaccinesLeft--;
      lastVaccineTime = millis();
      println("Vaccine deployed!");
    }
  // start game on click
  if (!gameStarted) {
    gameStarted = true;
    startTime = millis();
    return;
  }

  if (gameEnded) return;

  if (vaccinesLeft > 0 && millis() - lastVaccineTime > VACCINE_COOLDOWN) {
    boolean success = population.vaccinateNearest(mouseX, mouseY, 60);
    if (success) {
      vaccinesLeft--;
      lastVaccineTime = millis();
      println("Vaccine deployed!");
    }
  }
}

void keyPressed() {
  if (key == 'r' || key == 'R') resetSim();
}