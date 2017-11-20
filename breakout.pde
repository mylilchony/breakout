final int RIGHT_WALL = 700, BRICK_OFFSET = 80; // number of ROW[lvl]s and columns of bricks, width and height of bricks
final int SPEED_INCREMENT = 3, INITIAL_SPEED = 5;
final float ANGULAR_OFFSET = 0.3;
final int[] COL = {7, 10, 14, 14};
final int[] ROW = {5, 6, 8, 8};
final int[] brickH = {40, 30, 20, 20};
int lives, clickTime, bounces, score = 0; // number of lives, score, bounces, clickTime to delay multiple click registers
int brickW; // width and height of bricks
float x, y, oldX, oldY, paddle, paddleX, paddleY; // location of ball and paddle
float speed, angle; // speed and angle of ball
boolean isInPlay, clear;// is the ball in play?
boolean[][] isBrick; // is the brick there?

              ////////////////////////////////////////////////////////////////
int lvl = 0; // CHANGE THIS TO EDIT LEVEL. TRY lvl = 3 FOR SOMETHING COOL! //
            ////////////////////////////////////////////////////////////////

void setup() {
  size(800, 600);
  paddleY = height - 50;
  paddle = 100;
  speed = INITIAL_SPEED;
  lives = 3;
  bounces = 0;
  brickW = RIGHT_WALL/COL[lvl];
  
  isInPlay = false;
  clear = false;
  isBrick = new boolean[ROW[lvl]][COL[lvl]]; // initialize all the bricks to be there
  for(int c = 0; c < ROW[lvl]; c++)
    for(int d = 0; d < COL[lvl]; d++)
      isBrick[c][d] = true;
}
// the meat and potatoes
void draw() {
  background(0); // clear each frame with a black background
  bricks(); // the bricks
  status(); // score, lvl/game over, line
  paddle(); // the paddle
  balls(); // the balls
  if(lives == 0) { // if the game is over, it will hold the game over screen until the user presses the mouse
    if(mousePressed) {
      score = 0;
      clickTime = millis();
      setup();
    }
    return;
  }
  if(!clear) {
    clear = true;
    for(int c = 0; c < ROW[lvl]; c++)
      for(int d = 0; d < COL[lvl]; d++)
        if(isBrick[c][d])
          clear = false;
  }
  if(clear) { // if the game lvl is cleared, it will hold the empty screen allowing the user a moment of rest and celebration
    if(mousePressed) {
      clickTime = millis();
      if(lvl < 3) // 3 is the last level and unbeatable, so there is no need to increment further.
        lvl++;
      setup(); // I called setup to reset the game, BUT I also changed the lvl afterwards
    }
    return;
  }
  if(!isInPlay) { // when the ball is not in play
    serve(); // attach the ball to the paddle and prepare to serve
    return;
  }
  oldX = x; // store old ball coordinates
  oldY = y;
  x += speed*(cos(angle)); // move ball
  y += speed*(sin(angle));
  bounce(); // bounce detection and action
  paddleBounce(); // bounce detection, action, AND angular manipulation
  if(y >= height) { // if you lose the ball off the screen
    isInPlay = false; // it'll reset the ball for the next serve
    lives--;
    bounces = 0;
    speed = INITIAL_SPEED;
  }
}
void bricks() { // draw bricks
  stroke(0);
  strokeWeight(2);
  fill(237,28,36);
  for(int c=0; c<ROW[lvl]; c++) {
    if(ROW[lvl]-c==6 || ROW[lvl]-c==5) // switches colors at designated ROW[lvl]s
      fill(255,242,0);
    if(ROW[lvl]-c==4)
      fill(34,177,76);
    if(ROW[lvl]-c==2)
      fill(63,72,204);
    for(int d=0; d<COL[lvl]; d++) // only shows the bricks that haven't been destroyed
      if(isBrick[c][d])
        rect(d*brickW, (c*brickH[lvl])+BRICK_OFFSET, brickW, brickH[lvl]);
  }
}
void status() {
  fill(255); // all the stats are colored white for aesthetics
  stroke(255);
  textSize(32);
  float textOffset = 10;
  if(score >= 10)
    textOffset = 20;
  if(score >= 100)
    textOffset = 30;
  String status = "L\nE\nV\nE\nL\n\n"+(lvl+1); // lvl 1 
  if(lvl == 3)
    status = "E\nX\nT\nR\nA"; // extra lvl
  if(lives == 0)
    status = "G\nA\nM\nE\n\nO\nV\nE\nR"; // game over
  if(clear)
    status = "C\nL\nE\nA\nR\nE\nD\n!"; // cleared
  text(status, (width+RIGHT_WALL)/2 - 10, 75);
  text(score, (width+RIGHT_WALL)/2 - textOffset, height-50);
  line(RIGHT_WALL,0,RIGHT_WALL,height); // separate the leftover space from the playing space
}
void paddle() { // the paddle
  paddleX = mouseX-(paddle/2); // paddle follows the x-value of the mouse
  if(paddleX < 0) // prevents the paddle from going out of bounds
    paddleX = 0;
  if(paddleX > RIGHT_WALL - paddle)
    paddleX = RIGHT_WALL - paddle;
  noStroke();
  rect(paddleX, paddleY, paddle, 20);
}
void balls() { // the balls
  if(lvl != 3 || millis() % 700 < 300) // extra lvl makes the ball turn invisible
    ellipse(x, y, 10, 10); // the ball
  if(lives == 3) { // the lives
    ellipse((width+RIGHT_WALL)/2, height - 150, 10,10);
    ellipse((width+RIGHT_WALL)/2, height - 125, 10,10);
  }
  if(lives == 2)
    ellipse((width+RIGHT_WALL)/2, height - 125, 10,10);
}
void serve() { // attach the ball to the paddle and prepare to serve
  x = paddleX + (paddle/2); // the ball follows the paddle position
  y = paddleY - 5;
  if(mousePressed && (millis()-clickTime) > 100) { // clicking the mouse sends the ball into play
    isInPlay = true;
    angle = random(-PI+ANGULAR_OFFSET, -ANGULAR_OFFSET);
  }
}
void bounce() { // checks for a bounce condition, then proceeds to bounce
  if(x <= 0 || x >= RIGHT_WALL) { // checks for left and right wall bounce
    x = oldX;
    if(angle >= 0)
      angle = PI - angle;
    else
      angle = -PI - angle;
  }
  if(y <= 0) // checks for top wall bounce
    angle = -angle;
  
  int scoreIncrement = 7;
  for(int c = 0; c < ROW[lvl]; c++) { // checks for a bounce on the top and bottom of each brick
    if(ROW[lvl]-c == 6 || ROW[lvl]-c==5)
      scoreIncrement = 5;
    if(ROW[lvl]-c == 4)
      scoreIncrement = 3;
    if(ROW[lvl]-c == 2)
      scoreIncrement = 1;
    if((y <= ((c+1)*brickH[lvl])+BRICK_OFFSET && oldY >= ((c+1)*brickH[lvl])+BRICK_OFFSET) || (y >= (c*brickH[lvl])+BRICK_OFFSET && oldY <= (c*brickH[lvl])+BRICK_OFFSET))
      for(int d = 0; d < COL[lvl]; d++)
        if(isBrick[c][d] && x > d*brickW && x < (d+1)*brickW) {
          y = oldY; // my trick to keeping the ball from running off too far between bounces
          angle = -angle;
          isBrick[c][d] = false;
          score += scoreIncrement;
        }
  }
  for(int c = 0; c < COL[lvl]; c++) // checks for a bounce on the left and right of each brick
    if((x <= (c+1)*brickW && oldX >= (c+1)*brickW) || (x >= c*brickW && oldX <= c*brickW))
      for(int d = 0; d < ROW[lvl]; d++)
        if(isBrick[d][c] && y > (d*brickH[lvl])+BRICK_OFFSET && y < ((d+1)*brickH[lvl])+BRICK_OFFSET) {
          x = oldX; // my trick to keeping the ball from running off too far between bounces
          if(angle >= 0)
            angle = PI - angle;
          else
            angle = -PI - angle;
          isBrick[d][c] = false;
        }
}
void paddleBounce() {
  if(y >= paddleY && oldY <= paddleY) // checks for paddle bounce
    if(x >= paddleX && x <= paddleX + paddle) { // counts paddle bounces
      bounces++;
      if(bounces == 4) // increases ball speed throughout game
        speed += SPEED_INCREMENT;
      if(bounces == 12)
        speed += SPEED_INCREMENT;
      if(bounces == 28)
        speed += SPEED_INCREMENT;
      angle = -angle; // reflects the ball back upward
      float change = ((x-paddleX)*PI/paddle)-HALF_PI; // calculates a change in the angle based on where the ball hits the paddle 
      angle += change;
      if(angle < -PI+ANGULAR_OFFSET) // prevents the ball from being reflected any lower than a set amount
        angle = -PI+ANGULAR_OFFSET;
      if(angle > -ANGULAR_OFFSET)
        angle = -ANGULAR_OFFSET;
    }
}