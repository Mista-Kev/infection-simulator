 
 int POPULATION_SIZE = 100;
Population population;
ArrayList<Hotzone> hotzones;
float HOTZONE_RADIUS_BONUS = 25;

void setup() {
  size(1000, 700);
  
  // start the game
  population = new Population(POPULATION_SIZE);
  hotzones = new ArrayList<Hotzone>();
  
  // patient zero
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
  for(Hotzone hz : hotzones) {
    hz.display();
  }
  
  population.display();
}
 
void detectHotzones() {
  // get infected people
  ArrayList<Person> infectedList = new ArrayList<Person>();
  for(Person p : population.persons) {
    if(p.isInfected()) infectedList.add(p);
  }
  
  boolean[] used = new boolean[infectedList.size()];
  
  // find neighbors
  for (int i=0; i<infectedList.size(); i++) {
    if (used[i]) continue;
    
    ArrayList<Person> cluster = new ArrayList<Person>();
    cluster.add(infectedList.get(i));
    used[i] = true;
    
    for (int j=0; j<infectedList.size(); j++) {
      // check distance
      if (!used[j] && dist(infectedList.get(i).pos.x, infectedList.get(i).pos.y, infectedList.get(j).pos.x, infectedList.get(j).pos.y) < 60) {
        cluster.add(infectedList.get(j));
        used[j] = true;
      }
    }
    
    // add zone if 3+ people
    if (cluster.size() >= 3) {
      hotzones.add(new Hotzone(cluster));
    }
  }
}
void mousePressed() {
  // Try to vaccinate where the player clicked
  boolean success = population.vaccinateAt(mouseX, mouseY);
  
  if(success) {
    println("Vaccine deployed!");
  }
}