Position start;
Position end;
Mover m;
int moverSize = 10;
ArrayList<Position>world;
ArrayList<Position> openSet;
ArrayList<Position> exploredSet;
ArrayList<Position> solution;
ArrayList<Edge> edges;
int count;
int moverPos;
float moverPerc;
Obstacle obstacle;
boolean done;
int size = 1;
void setup(){
  size(800,800);
  start = new Position(20,780);
  end = new Position(780,20);
  world = new ArrayList<Position>();
  openSet = new ArrayList<Position>();
  exploredSet = new ArrayList<Position>();
  solution = new ArrayList<Position>();
  edges = new ArrayList<Edge>();
  obstacle = new Obstacle(width/2,height/2,400);
  m = new Mover();
  int total = 0;
  while(total <= 20){
    Position p = new Position(random(size,width-size),random(size,height-size));
    if(!p.inObstacle()){
      world.add(p);
      total++;
    }  
  }
  
  world.add(start);
  world.add(end);
  for(int i = 0; i < world.size(); i++){
    Position p = world.get(i);
    for(int j = 0; j < world.size(); j++){
      if(p.hasClearPath(world.get(j)) && i != j){
        edges.add(new Edge(p,world.get(j)));
        p.neighbors.add(world.get(j));
      }
      
    }
  }
  count = 0;
  moverPos = 0;
  moverPerc = 0;
  done = false;
  openSet.add(start);

}

void draw(){
  background(255);


  Position currentPos = start;

  if(!done){
    if(openSet.size()>0){
      int curIndex = 0;
      for(int i = 0; i < openSet.size();i++){
        if(openSet.get(i).f_score < openSet.get(curIndex).f_score){
          curIndex = i;
        }
      }
      currentPos = openSet.get(curIndex);
      currentPos.display(color(255,255,0),10);
      
      if(currentPos == end){
        println("done");
        done = true;
        solution = reconstructPath();
        
      }
      
      openSet.remove(curIndex);
      exploredSet.add(currentPos);
      
      for(int i = 0; i < currentPos.neighbors.size(); i++){
        Position curr = currentPos.neighbors.get(i);
        if(exploredSet.contains(curr)){
          continue;
        }
        float tentative_gScore = currentPos.g_score + costEstimate(currentPos, curr);
        if(!openSet.contains(curr)){
          openSet.add(curr);
        }else if(tentative_gScore >= curr.g_score){
          continue;
        }
        
        curr.cameFrom = currentPos;
        curr.g_score = tentative_gScore;
        curr.f_score = curr.g_score + costEstimate(curr,end);
        }
      }
    }
  
       
            
    
    
  start.display(color(0,255,0),1);
  end.display(color(0,0,255),1);
  ellipse(start.loc.x,start.loc.y,20,20);
  fill(0,255,0);
  ellipse(end.loc.x,end.loc.y,20,20);
  obstacle.display();
  if(!done){
    for(Position p : world){
      p.display(color(255,255,255),1);
    }
    for(Edge e : edges){
      e.display(100);
    }
  }
  else{    
    
    for(int i = 0; i < solution.size()-1; i++){
      Position p1 = solution.get(i);
      Position p2 = solution.get(i+1);
      strokeWeight(1);
      line(p1.loc.x,p1.loc.y,p2.loc.x,p2.loc.y);
    }
    println(moverPos);
    if(moverPerc >= 1){
      moverPerc = 0;
      moverPos--;
      
    }
    
    if(moverPos <= 0){
      moverPos = solution.size()-1;
      count++;
    }
  
    PVector s = solution.get(moverPos).loc;
    PVector e = solution.get(moverPos - 1).loc;
    
    PVector current = PVector.lerp(s, e, moverPerc);
    m.loc = current;
    m.display();
    println(moverPerc);
    moverPerc+=0.009;
    
    for(Edge edg : edges){
      edg.display(20);
    }
    if(count > 1){
      setup();
    }

    
   
  }
 
  
}

float costEstimate(Position p1, Position p2){
  float v1 = (p2.loc.x - p1.loc.x) * (p2.loc.x - p1.loc.x);
  float v2 = (p2.loc.y - p1.loc.y) * (p2.loc.y - p1.loc.y);
  
  return (float)Math.sqrt(v1 + v2);
}
ArrayList reconstructPath(){
  ArrayList<Position> path = new ArrayList<Position>();
  
  Position tmp = end;
  
  path.add(tmp);
  while(tmp != start){
    path.add(tmp.cameFrom); 
    tmp = tmp.cameFrom;
  }

  return path;
}
class Edge{
  Position p1;
  Position p2;
  Edge(Position p1_, Position p2_){
    p1 = p1_;
    p2 = p2_;
  }
  
  void display(float alph){
    strokeWeight(1);
    stroke(0,0,0,alph);
    line(p1.loc.x,p1.loc.y,p2.loc.x,p2.loc.y);
  }
}
    
    
class Obstacle{
  PVector loc;
  float r;
  Obstacle(float x, float y, float r_){
    loc = new PVector(x,y);
    r = r_;
  }
  
  void display(){
    fill(255,0,0);
    ellipse(loc.x,loc.y,r,r);
  }
}

class Mover{
  PVector loc;
  Mover(){
    loc = new PVector(start.loc.x,start.loc.y);
  }
  void display(){
    fill(0,0,0);
    ellipse(loc.x,loc.y,moverSize,moverSize);
  }
}
    
class Position{
  float f_score;
  float g_score;
  float h_score;
  PVector loc;
  Position cameFrom;
  ArrayList<Position> neighbors;
  Position(float x, float y){
    neighbors = new ArrayList<Position>();
    cameFrom = start;
    f_score = 0;
    g_score = 0;
    h_score = 0;
    loc = new PVector(x,y);
  }
  
  boolean inObstacle(){
    float v1 = (loc.x - obstacle.loc.x) * (loc.x - obstacle.loc.x);
    float v2 = (loc.y - obstacle.loc.y) * (loc.y - obstacle.loc.y);
    float d = sqrt(v1 + v2);
    
    if((d - moverSize) <= (obstacle.r/2)){
      return true;
    }
    else{
      return false;
    }
 
  }
  
  boolean hasClearPath(Position p){
    float a = loc.x - p.loc.x;
    float b = loc.y - p.loc.y;
    float x = sqrt(a*a + b*b);
    
    return((abs((width/2 - loc.x) * (p.loc.y - loc.y) - 
    (height/2 - loc.y) * (p.loc.x - loc.x)) / x - moverSize)>= obstacle.r/2);
     
  }

    
  void display(color c, float w){
    stroke(0);
    fill(c);
    ellipse(loc.x,loc.y,w,w);
  }
    
}
