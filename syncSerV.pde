//*
//* This program records serial data, video in synchronize.
//* Author&Copyright: Akira Kashihara <akira.kashihara@hotmail.com>
//* License: Check LICENSE file.
//* 

import processing.serial.*;   // Import serial port library
import processing.video.*;    // Import video library
import processing.sound.*;    // Import sound library

// Import necessary minim module to record sound
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

long startTime = -1;          // Start time variable

Minim minim;                  // Set minim
AudioInput in;                // Use AudioInput 
AudioOutput out;              // Use AudioOutput
AudioRecorder recorder;       // Set audio recorder
PrintWriter outputSerial;     // Set printwriter

String portName = "COM4";     // Define comport name
int baudrate = 9600;          // Define baundrate
String gettenData = "";       // The variable to store getten data.
int valueData = -1;           // The value of getten data

Serial myPort;                // Define serial port as instance
Capture cam;                  // Define camera as instance

long numFrame = 0;            // The number of frame

boolean flagF = false;        // The flag of the start point to get data
boolean flagManager = false;  // The flag to manage the start of recording data

void setup() {
  minim = new Minim(this);
  in = minim.getLineIn();
  out = minim.getLineOut();
  recorder = minim.createRecorder(in, "./sounds/record.wav");  // The file holds sound data
  outputSerial = createWriter("./csv/serial.csv");             // The file holds serial data
  printArray(Serial.list());          // Display serial port list
  myPort = new Serial(this, portName, baudrate);  // Define serial port
  size(640, 480);                     // Set display size

  String[] cameras = Capture.list();  // The list of cameras

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();  // escape from this program
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);  // Display cameras
    }

    // The camera can be initialized directly using an
    // element from the array returened by list();
    cam = new Capture(this, cameras[0]);
    startMediaRecord();
  }
}


void draw() {
  image(cam, 0, 0);
  cam.save("./images/" + str(numFrame++) + ".png");
}

// Event handler for capture video from camera
void captureEvent(Capture video) {
  video.read();
}

// Event handler for serial connection
void serialEvent(Serial p) {
  String buf = p.readString();
  if (buf != null) {
    //println(buf);
    if (flagF == false) {
      if (buf.equals("\n")) {
        flagF = true;
      }
    } else {
      if (flagManager) {
        if (!buf.equals("\n")) {
          gettenData = gettenData + buf;
          buf = "";
        } else if (buf.equals("\n")) {
          buf = "";
          valueData = int(trim(gettenData));  // To convert from string to int with trimming
          println(valueData);                 // Display getten value
          outputSerial.println(str(millis()-startTime) + "," + str(numFrame) + "," + str(valueData));
          gettenData = "";
        }
      }
    }
  }
}

// Start to record media
void startMediaRecord() {
  recorder.beginRecord();
  cam.start();
  flagManager = true;
  startTime = millis();
  outputSerial.println("Time, Frame, Serial");
}

// The function stop to record media
void stopMediaRecord() {
  flagManager = false;
  recorder.endRecord();
  print("Stop tp record media");
  outputSerial.close();
  println("End process.");
}

// Keypressed interrupt
void keyPressed() {
  stopMediaRecord();
}
