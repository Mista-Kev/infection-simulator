int POPULATION_SIZE = 100;
Population population; 

void setup() {
  size(1000, 700);
  
  // start the game
  population = new Population(POPULATION_SIZE);
  
  // patient zero
  population.infectRandom();
}

void draw() {
  
  fill(25, 20, 35, 60); 
  noStroke();
  rect(0, 0, width, height);
  
  
  population.update();
  
  
  population.spreadInfection(40, 0.05); 
  
  
  population.display();
}