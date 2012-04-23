/*
 *  ofxPanZoom.h
 *  iPhoneEmptyExample
 *
 *  Created by Oriol Ferrer Mesià on 5/17/10.
 *  Copyright 2010 uri.cat. All rights reserved.
 *
 */

#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#define	MAX_TOUCHES		12
#define MIN_FINGER_DISTANCE 50.0f /* in pixels - zooming when fingers were too close was unaccurate & jumpy*/

class testApp;

class ofxPanZoom{

public:
	
	ofxPanZoom();
	~ofxPanZoom(){};
	
	ofVec3f screenSize;
	
	//those keep the bbox of the world (in gl units) that are visible on screen
	ofVec3f topLeft;
	ofVec3f bottomRight;
	
	ofVec3f offset;
	ofVec3f zoomOffset;
	float zoom;
	
	float minZoom;
	float maxZoom;
	
	float zoomDiff;
	
	bool touching[MAX_TOUCHES];
	ofVec3f lastTouch[MAX_TOUCHES];

	bool vFlip;	//of give you standard OF flipped y
	bool viewportConstrained;
	ofVec3f topLeftConstrain, bottomRightConstrain;
	
	void touchDown(ofTouchEventArgs &touch);
	void touchMoved(ofTouchEventArgs &touch);
	void touchUp(ofTouchEventArgs &touch);
	void touchDoubleTap(ofTouchEventArgs &touch);

	void setViewportConstrain(ofVec3f topLeftConstrain_, ofVec3f bottomRightConstrain_ );
	void removeViewportConstrain();
	
	void setMinZoom(float min){ minZoom = min;}
	void setMaxZoom(float max){ maxZoom = max;}
	void setZoom(float z){ zoom = z;}
	void setVerticalFlip( bool flip){ vFlip = flip; }

	bool fingerDown();
	
	void setScreenSize(int x, int y);
	bool isOnScreen(ofVec3f p);
	void lookAt(ofVec3f p);
	void apply(int customW = 0, int customH = 0);	//if you need to provide a viewport size (not full screen)
	void reset();
	void drawDebug();
	ofVec3f screenToWorld(ofVec3f p);
	
private:
	
	void applyConstrains();
	
};