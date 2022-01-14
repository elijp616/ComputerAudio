import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions

ControlP5 p5;

Glide musicRateGlide;
double musicLength;
Bead musicEndListener;

SamplePlayer music;
SamplePlayer play;
SamplePlayer rewind;
SamplePlayer stop;
SamplePlayer fastforward;
SamplePlayer reset;

//end global variables

void setup() {
  size(640, 520);
  ac = new AudioContext(); 
  p5 = new ControlP5(this);
  
  assignSounds();
  musicRateGlide = new Glide(ac, 0, 700);
  music.setRate(musicRateGlide);
  musicLength = music.getSample().getLength();
  
  musicEndListener =  new Bead() {
    public void messageReceived(Bead message) {
        music.setEndListener(null);
        if (musicRateGlide.getValue() > 0 && music.getPosition() >= musicLength) {
            musicRateGlide.setValueImmediately(0);
            music.setToEnd();
        }
        if (musicRateGlide.getValue() < 0 && music.getPosition() <= 0.0) {
            musicRateGlide.setValueImmediately(0);
            music.reset();
        }
    }
  };
  createUI();
  addInputs();
  
  ac.start();
}
void assignSounds() {
  music = getSamplePlayer("Divna Ljubojević - Agni Partene.wav", false);
  play = getButtonSamplePlayer("play.wav", ac);
  rewind = getButtonSamplePlayer("stop.wav", ac);
  stop = getButtonSamplePlayer("ff.wav", ac);
  fastforward = getButtonSamplePlayer("rewind.wav", ac);
  reset = getButtonSamplePlayer("reset.wav", ac);
  
}
void createUI() {
    p5.addButton("Play")
    .setWidth(width - 30)
    .setHeight(60)
    .setPosition(10 , 10);  
  p5.addButton("Stop")
    .setWidth(width - 30)
    .setHeight(60)
    .setPosition(10, 110);
  p5.addButton("FastForward")
    .setWidth(width - 30)
    .setHeight(60)
    .setPosition(10, 210)
    .setLabel("Fast Forward");
  p5.addButton("Rewind")
    .setPosition(10, 310)
    .setWidth(width - 30)
    .setHeight(60); 
  p5.addButton("Reset")
    .setWidth(width - 30)
    .setHeight(60)
    .setPosition(10, 410); 
}

void addInputs() {
  ac.out.addInput(music);
  ac.out.addInput(play);
  ac.out.addInput(rewind);
  ac.out.addInput(stop);
  ac.out.addInput(reset);
  ac.out.addInput(fastforward);
}

public SamplePlayer getButtonSamplePlayer(String fname, AudioContext ac) {
  final SamplePlayer sp = getSamplePlayer(fname);
  final Glide g = new Glide(ac, 0, 0);
  sp.setRate(g);
  sp.setEndListener(new Bead() {
    public void messageReceived(Bead b) {
      g.setValueImmediately(0);
      sp.setToLoopStart();
    }
  });
  return sp;
}
public void Play() {
    play.getRateUGen().setValue(1);
    if (music.getPosition() < musicLength) {
        music.setEndListener(musicEndListener);
        musicRateGlide.setValue(1);
    }
}

public void Stop() {
    stop.getRateUGen().setValue(1);
    musicRateGlide.setValue(0);
}


public void FastForward() {
    fastforward.getRateUGen().setValue(1);
    musicRateGlide.setValueImmediately(0);
    if (music.getPosition() < musicLength) {
        music.setEndListener(musicEndListener);
        musicRateGlide.setValue(3);
    }
}

public void Rewind() {
    rewind.getRateUGen().setValue(1);
    music.setEndListener(musicEndListener);
    musicRateGlide.setValue(-3);
}

public void Reset() {
    reset.getRateUGen().setValue(1);
    music.setEndListener(musicEndListener);
    music.setToLoopStart();
    musicRateGlide.setValueImmediately(0);
}

void draw() {
  background(0);  //fills the canvas with black (0) each frame
}
