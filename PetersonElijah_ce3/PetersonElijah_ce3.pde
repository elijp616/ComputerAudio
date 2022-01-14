import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;
import java.util.ArrayList;


//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions

private static final int FREQ = 500;

SamplePlayer loop;
SamplePlayer v1;
SamplePlayer v2;
SamplePlayer player;

ControlP5 p5;

Glide gainGlide;
float gainAmount;
Gain gain;

Glide duckGainGlide;
float duckGainAmount;
Gain duckGain;

BiquadFilter filter;
Glide filterGlide;
Slider reverbSlider;
RadioButton reverbButton;
boolean reverbActive;



Reverb reverb;


//end global variables

//runs once when the Play button above is pressed
void setup() {
  p5 = new ControlP5(this);
  ac = new AudioContext();
  size(320, 240); //size(width, height) must be the first line in setup()

  setupFields();
 
  gainGlide = new Glide(ac, 0, 100);
  gain = new Gain(ac, 1, gainGlide);
 
  duckGainGlide = new Glide(ac, 1, 500);
  duckGain = new Gain(ac, 1, duckGainGlide);
  
  filterGlide = new Glide(ac, 1, 500);
  filter = new BiquadFilter(ac, BiquadFilter.Type.HP, filterGlide, 1);
  player = getSamplePlayer("intermission.wav");
  
  filter.addInput(loop);
  duckGain.addInput(filter);
  gain.addInput(duckGain);
  gain.addInput(v1);
  gain.addInput(v2);
  reverb = new Reverb(ac);
  reverb.setSize(0);
  reverb.addInput(player);
  
  setupUI();
  
  ac.out.addInput(gain);
  ac.start();
}

void setupUI() {
    
    p5.addSlider("GainSlider")
    .setPosition(40, 20)
    .setSize(150, 20)
    .setValue(50)
    .setRange(0, 100)
    .setLabel("Master Gain");
    
    reverbButton = p5.addRadioButton("useReverb")
    .setSize(70, 40)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setPosition(50, 110)
    .addItem("Use Reverb", 0);
    
    reverbSlider = p5.addSlider("reverbSlider")
    .setPosition(700, 110)
    .setSize(250, 40)
    .lock()
    .setLabel("Reverb Slider");
}
void buildGraph() {
  ArrayList<UGen> depList = getUGenList();
  for (int i = 1; i < depList.size(); i++) {
    depList.get(i).clearInputConnections();
    depList.get(i).addInput(depList.get(i - 1));
  }
}
ArrayList<UGen> getUGenList() {
  ArrayList<UGen> output = new ArrayList();
  output.add(reverb);
  output.add(gain);
  return output;
}

void play(SamplePlayer sp) {
  sp.setToLoopStart();
  sp.start();
}

void setupFields() {
  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions 
  p5 = new ControlP5(this);
  
  loop = getBackground("intermission.wav");
  v1 = getVoiceSP("voice1.wav");
  v2 = getVoiceSP("voice2.wav");
}

void voice1() {
  v2.pause(true);
  play(v1);
  duckGainGlide.setValue(.5);
  filterGlide.setValue(FREQ);
}

void voice2() {
  v1.pause(true);
  play(v2);
  duckGainGlide.setValue(.5);
  filterGlide.setValue(FREQ);
}

SamplePlayer getBackground(String loc) {
  SamplePlayer sp = getSamplePlayer(loc);
  sp.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  return sp;
}

SamplePlayer getVoiceSP(String loc) {
  final SamplePlayer sp = getSamplePlayer(loc);
  sp.pause(true);
  sp.setEndListener(
    new Bead() {
      public void messageReceived(Bead mess) {
        sp.pause(true);
        sp.setToLoopStart();
        if (voicePlaying()) {
          filterGlide.setValue(FREQ);
        } else {
          filterGlide.setValue(1);
        }
        duckGainGlide.setValue(1.0);
      }
    }
  );
  return sp;
}

void GainSlider(int value) {
  gainGlide.setValue(((float) value) / 100);
}
void reverbSlider(float i) {
  if (reverb == null) {
    return;
  }
  reverb.setSize(i / 100);
}

boolean voicePlaying() {
  return !v1.isPaused() || !v2.isPaused();
}
void draw() {
  background(0);  //fills the canvas with black (0) each frame
}
