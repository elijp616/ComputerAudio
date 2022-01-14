import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

ControlP5 p5;
SamplePlayer buttonSound;
Gain gain;
Glide gainGlide;
Glide cutoffGlide;
BiquadFilter lpFilter;


//end global variables

//runs once when the Play button above is pressed
void setup() {
  size(320, 240); //size(width, height) must be the first line in setup()
  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions 
           
    p5 = new ControlP5(this);
    buttonSound = getSamplePlayer("585661__optisch__creepy-loop-melody-130-bpm.wav");
    buttonSound.pause(true);
    
    gainGlide = new Glide(ac, 1.0, 400);
    gain = new Gain(ac, 1, gainGlide);
    
    cutoffGlide = new Glide(ac, 1400.0, 50);
    lpFilter = new BiquadFilter(ac, BiquadFilter.LP, cutoffGlide, 0.4f);
    
    lpFilter.addInput(buttonSound);
    
    gain.addInput(lpFilter);
    ac.out.addInput(gain);
    
    
    //play button
    p5.addButton("Play")
      .setPosition(width/3, height/3)
      .setSize(width/5, height/5)
      .activateBy(ControlP5.RELEASE);
      
    p5.addSlider("Gain")
      .setPosition(20,20)
      .setSize(20,200)
      .setRange(0,100)
      .setValue(50)
      .setLabel("Volume");
      
    p5.addSlider("cutoff")
      .setPosition(225,20)
      .setSize(20,200)
      .setRange(20,15000.0)
      .setValue(1500.0)
      .setLabel("Cutoff");
      
    
    //ac.out.addInput(buttonSound);
    ac.start();
}

public void Gain(float value) {
  gainGlide.setValue(value/100.0);
}

public void cutoff(float value) {
  cutoffGlide.setValue(value);
}

public void Play(int value) {
  println("play button pressed");
  buttonSound.setToLoopStart();
  buttonSound.start();
}


void draw() {
  background(0);  //fills the canvas with black (0) each frame
  
}
