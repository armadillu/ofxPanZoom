#pragma once

#include "ofMain.h"

#include "ofxPanZoom.h"
#include "Grid.h"
#include "TouchAnimation.h"


class ofApp : public ofBaseApp {
	
public:
	void setup();
	void update();
	void draw();
	void exit(){};
	
	void touchDown(ofTouchEventArgs &touch);
	void touchMoved(ofTouchEventArgs &touch);
	void touchUp(ofTouchEventArgs &touch);
	void touchDoubleTap(ofTouchEventArgs &touch);
	void touchCancelled(ofTouchEventArgs &touch);

	void lostFocus(){};
	void gotFocus(){};
	void gotMemoryWarning(){};
	void deviceOrientationChanged(int newOrientation);

	ofxPanZoom	cam;
	Grid grid;
	TouchAnimation touchAnims;

	ofVec2f ball;
};


