// FFT_01.pde
// This example is based in part on an example included with
// the Beads download originally written by Beads creator
// Ollie Bown. It draws the frequency information for a
// sound on screen.
import beads.*;
import controlP5.*;
import java.util.ArrayList;
import org.jaudiolibs.beads.*;


ControlP5 p5;

PowerSpectrum ps;
color fore = color(255, 255, 255);
color back = color(0, 0, 0);
Glide gainGlide;
float gainAmount;
Gain gain;
Button highPassFilter;


Glide duckGainGlide;
float duckGainAmount;
Gain duckGain;
Glide cutoffGlide;
BiquadFilter lpFilter;



SamplePlayer player;
UGen micInput;

RadioButton filterSettings;
int currFilters = 0;

Slider cutoffFreq;
Slider reverbSlider;

RadioButton micButton;
RadioButton reverbButton;

float MIN_GLIDE = 100.0;
float MAX_GLIDE = 10000;

boolean micActive;
boolean reverbActive = true;
Glide filterGlide;
BiquadFilter filter;



ArrayList<Glide> glides = new ArrayList();
ArrayList<UGen> filters = new ArrayList();

Reverb reverb;

float cutoffFreqVal = MIN_GLIDE;

Gain g;

void setup() {
  

  size(1200, 1200);
  p5 = new ControlP5(this);
  ac = new AudioContext();
  gainGlide = new Glide(ac, 0, 100);
  g = new Gain(ac, 1, gainGlide);
 
  duckGainGlide = new Glide(ac, 1, 500);
  duckGain = new Gain(ac, 1, duckGainGlide);

  setupUI();

  Glide lpGlide = new Glide(ac, MIN_GLIDE);
  BiquadFilter lpFilter = new BiquadFilter(ac, BiquadFilter.Type.LP, lpGlide, .6);
  Glide hpGlide = new Glide(ac, MIN_GLIDE);
  BiquadFilter hpFilter = new BiquadFilter(ac, BiquadFilter.Type.HP, hpGlide, .6);
  Glide bpGlide = new Glide(ac, MIN_GLIDE);
  BiquadFilter bpFilter = new BiquadFilter(ac, BiquadFilter.Type.BP_SKIRT, bpGlide, .6);
  
  cutoffGlide = new Glide(ac, 1400.0, 50);
    lpFilter = new BiquadFilter(ac, BiquadFilter.LP, cutoffGlide, 0.4f);
    
    
    

  g.addInput(lpFilter);
 
  // set up a master gain object
  g.addInput(duckGain);
  ac.out.addInput(g);

// load up a sample included in code download
player = null;
try {
// Load up a new SamplePlayer using an included audio
// file.

player = getSamplePlayer("Laidback Luke & Mark Bale - Party Starter.wav", false);
player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
// connect the SamplePlayer to the master Gain

g.addInput(player);
filter = new BiquadFilter(ac, BiquadFilter.AP, 1000.0, 0.5f);
  filter.addInput(player);
  g.addInput(filter);  
  
} 
catch (Exception e) {
// If there is an error,  the steps that got us to
// that error.
e.printStackTrace();
}
    
  glides.add(null);
  glides.add(lpGlide);
  glides.add(hpGlide);
  glides.add(bpGlide);
  filters.add(player);
  filters.add(lpFilter);
  filters.add(hpFilter);
  filters.add(bpFilter);
  
  for (UGen filter : filters)  {
    filter.addInput(player);
  }
  
  reverb = new Reverb(ac);
  reverb.setSize(0);
  reverb.addInput(player);
    
  // In this block of code, we build an analysis chain
  // the ShortFrameSegmenter breaks the audio into short,
  // discrete chunks.
  ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
  sfs.addInput(ac.out);

  // FFT stands for Fast Fourier Transform
  // all you really need to know about the FFT is that it
  // lets you see what frequencies are present in a sound
  // the waveform we usually look at when we see a sound
  // displayed graphically is time domain sound data
  // the FFT transforms that into frequency domain data
  FFT fft = new FFT();
  // connect the FFT object to the ShortFrameSegmenter
  sfs.addListener(fft);

  // the PowerSpectrum pulls the Amplitude information from
  // the FFT calculation (essentially)
  ps = new PowerSpectrum();
  // connect the PowerSpectrum to the FFT
  fft.addListener(ps);
  // list the frame segmenter as a dependent, so that the
  // AudioContext knows when to update it.
  ac.out.addDependent(sfs);
  // start processing audio
  ac.start();
}
// In the draw routine, we will interpret the FFT results and
// draw them on screen.


void setupUI() {
  p5.addSlider("GainSlider")
    .setPosition(40, 20)
    .setSize(250, 40)
    .setValue(50)
    .setRange(0, 100)
    .setLabel("Heart Rate and Hydration");
    p5.addSlider("cutoff")
      .setPosition(40,160)
      .setSize(250,40)
      .setRange(20,15000.0)
      .setValue(1500.0)
      .setLabel("Cortisol");
   
      
  

  reverbButton = p5.addRadioButton("useReverb")
    .setSize(70, 40)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setPosition(50, 220)
    .addItem("Use Reverb", 0);

  reverbSlider = p5.addSlider("reverbSlider")
    .setPosition(40, 300)
    .setSize(250, 40)
    .setLabel("SpO2");
    
 
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
  
  if (micActive) {
    output.add(micInput);
  } else {
    output.add(player);
  }
  
  if (reverbActive) {
    output.add(reverb);
  }
  
  if (currFilters != 0) {
    output.add(filters.get(currFilters));
    glides.get(currFilters).setValue(cutoffFreqVal);
  }
  
  output.add(g);
  
  return output;
}

void filterSettings(int i) {
  if (i != -1) {
    cutoffFreq.unlock();
  }

  if (i == 0 || i == -1) {
    i = 0;
    cutoffFreq.setValue(MIN_GLIDE);
    cutoffFreq.lock();
    filterSettings.activate(0);
  }
  currFilters = i;
  buildGraph();
}
void highPassFilter() {
  filter.setType(BiquadFilter.HP);
}


void useReverb(int i ) {
  if (i == 0) {
    reverbActive = true;
  } else {
    reverbActive = false;
  }
  if (reverbActive) {
    reverbSlider.unlock();
  } else {
    reverbSlider.lock();
    reverbSlider.setValue(0);
  }
  buildGraph();
}

void cutoffFrequency(float i) {
  cutoffFreqVal = i;
  if (filters.size() < 1) {
    return;
  }
  UGen glide = glides.get(currFilters);
  if (glide != null) {
    ((Glide) glide).setValue(i);
  }
}
public void cutoff(float value) {
  cutoffGlide.setValue(value);
}

void reverbSlider(float i) {
  if (reverb == null) {
    return;
  }
  reverb.setSize(i / 800);
}
void GainSlider(int value) {
  gainGlide.setValue(((float) value) / 75);
}

void draw()
{
 background(back);
 stroke(fore);

 // The getFeatures() function is a key part of the Beads
 // analysis library. It returns an array of floats
 // how this array of floats is defined (1 dimension, 2
 // dimensions ... etc) is based on the calling unit
 // generator. In this case, the PowerSpectrum returns an
 // array with the power of 256 spectral bands.
 float[] features = ps.getFeatures();

 // if any features are returned
 if(features != null)
 {

 }
}
