/* --------------------------------------------------------------------------
 * Fabiola Einhorn Major Studio 1 Final // CC Lab Final 
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */

import processing.video.*;
Movie theMovEmpty, theMovrightHandFoot;

import SimpleOpenNI.*;

SimpleOpenNI  context;
color[]       userClr = new color[] { 
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};                              

PVector rightHand = new PVector();
PVector leftHand = new PVector();

PVector com = new PVector();                                   
PVector com2d = new PVector();     

//declare global variables for tracking which way the user enters the Kinect area
float Ledge;
float Redge;


boolean L = true;
boolean R = true;


//How big the change needs to be in order to count as "motion".
float threshold = 127;

int loc = x + y*image.width;
color pix = image.pixels[loc];

int leftLoc = (x-1) + y*image.width;
color leftPix = image.pixels[leftLoc];


void setup()
{
  size(640, 480, P2D); //or JAVA2D makes processing faster with video. 

  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser();

  //context.enableRGB();

  Ledge = (width*.3)*height;
  Redge = (width*.6)*height;


  background(200, 0, 0);

  stroke(0, 0, 255);
  strokeWeight(3);
  smooth();

  // video
  theMovEmpty = new Movie(this, "Empty.MOV");
  theMovrightHandFoot = new Movie(this, "rightHandFoot.MOV");

  theMovrightHandFoot.play(); 
  theMovEmpty.loop();
}

void draw()
{
  // update the cam
  context.update();

  // video
  image(theMovEmpty, 0, 0);
  //image(theMovrightHandFoot, 0, 0);

  //draw depthImageMap
  //image(context.depthImage(), 0, 0);
  //image(context.userImage(), 0, 0);
  
  
   for (int i = 0; i < Ledge; i++) {
      if (pixels[i] = x-1 && y*width/2){
      L = true;
      }

  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for (int i=0;i<userList.length;i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
    {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);
    }      

    // draw the center of mass
    if (context.getCoM(userList[i], com))
    {
      context.convertRealWorldToProjective(com, com2d);
      stroke(100, 255, 0);
      strokeWeight(1);
      beginShape(LINES);
      vertex(com2d.x, com2d.y - 5);
      vertex(com2d.x, com2d.y + 5);

      vertex(com2d.x - 5, com2d.y);
      vertex(com2d.x + 5, com2d.y);
      endShape();

      fill(0, 255, 100);
      text(Integer.toString(userList[i]), com2d.x, com2d.y);
    }
  }
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
   context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
   println(jointPos);
   */

  PVector jointPos = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
  println(jointPos);


  //My selected positions 
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);

  //Current Tracking
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}

//My events

void onRightHand(SimpleOpenNI curContext, int userId) 
{
  // if (rightHand == true;) { 
  //   theMovrightHandFoot.read();
  // } else if (theMovEmpty.loop();
}

//void movieEvent(Movie m) {
//  //  if (m == Movie) {
//  //    theMovrightHandFoot.read();
//  //  } else if (m == yourMovie) {
//  //    theMovEmpty.loop();
//  //}
//}

void movieEvent(Movie m) {
  m.read();
}

void keyPressed()
{
  switch(key)
  {
  case 'm':
    context.setMirror(!context.mirror());
    break;

  case ' ':
    loadPixels();  // how does it know we want to pull this from the RGB camera? 
    break;
  }
}  

