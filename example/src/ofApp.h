#pragma once

#include "ofMain.h"

#include "ofxPanZoom.h"
#include "Grid.h"
#include "TouchAnimation.h"
#include "Win7TouchQueue.h"

#define GLUT_MULTITOUCH

#ifdef GLUT_MULTITOUCH
#include "ofBaseTouchApp.h"
#else
#include "ofAppGLFWWindow.h"
#endif

#ifdef GLUT_MULTITOUCH
class ofApp : public ofBaseTouchApp{
#else
class ofApp : public ofBaseApp{
#endif
	
public:
	void setup();
	void update();
	void draw();
	void exit(){};
	

#ifdef GLUT_MULTITOUCH
	void touchDown(int x, int y, int id);
	void touchMoved(int x, int y, int id);
	void touchUp(int x, int y, int id);
	// NOTE: you must call setUseGestures() in your main.cpp to use these last two
	void twoFingerTap() {}
	void twoFingerZoom(double dZoomFactor,const LONG lZx,const LONG lZy) {}
#endif

	ofxPanZoom	cam;
	Grid grid;
	TouchAnimation touchAnims;

	Win7TouchQueue tq; //touch queue, to avoid doing heavy work on touch callbacks
	void processTouches(vector<Win7TouchQueue::WinTouch> & t);

	ofVec2f ball;
};


