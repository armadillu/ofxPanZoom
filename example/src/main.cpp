#include "ofMain.h"
#include "ofApp.h"
#include "ofxTimeMeasurements.h"

#ifdef GLUT_MULTITOUCH
#include "ofWinGlutWindow.h"
#else
#include "ofAppGLFWWindow.h"
#endif

int main(){

#ifdef GLUT_MULTITOUCH
	//GLUT window
	ofWinGlutWindow win;
	//win.setGlutDisplayString("rgba double samples=>8 depth");
#else
	//GLFW window
	ofAppGLFWWindow win;
	win.setNumSamples(NUM_SAMPLES);
	win.setMultiDisplayFullscreen(false);
	//win.setDepthBits(24);
#endif

	TIME_SAMPLE_ENABLE();
	ofSetupOpenGL(&win, 480, 320, OF_FULLSCREEN);
	ofRunApp(new ofApp());
}
