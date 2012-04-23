
/*
 *  TouchAnimation.mm
 *  emptyExample
 *
 *  Created by Oriol Ferrer Mesià on 28/03/12.
 *  Copyright 2012 uri.cat. All rights reserved.
 *
 */

#include "TouchAnimation.h"


void TouchAnimation::update(float dt){

	//to keep it simple, walk the vector backwards and delete dead touches easily
	for (int i = touches.size() - 1; i >= 0; i--){
		touch t = touches[i];
		t.time -= dt;
		touches[i] = t;
		if( touches[i].time <= 0){
			touches.erase( touches.begin() + i);
		}
	}
}


void TouchAnimation::addTouch(float x, float y){
	
	touch t;
	t.pos = ofVec2f(x, y);
	t.time = TOUCH_ANIM_DURATION;	
	touches.push_back(t);	
}


void TouchAnimation::draw(){
	
	for (int i = 0; i < touches.size(); i++){
		touch t = touches[i];
		ofVec2f p = touches[i].pos;
		float lifePercent = (TOUCH_ANIM_DURATION - t.time) / TOUCH_ANIM_DURATION; //[0..1]
		float radius = TOUCH_ANIM_RADIUS * lifePercent;
		float alpha = 1.0f;
		if ( lifePercent < 0.5f){
			alpha = 1.0f;
		}else {
			alpha = 0.5 + 0.5 * cosf( -M_PI + 2.0f * M_PI * lifePercent );
		}

		ofPushStyle();
			ofNoFill();
			ofSetLineWidth(1);
			ofSetColor(255,255,255, alpha * 255);
			ofCircle(p.x, p.y, radius);
			ofFill();
			ofSetColor(255,255,255, alpha * 128);
			ofCircle(p.x, p.y, radius);
		ofPopStyle();
		
		ofSetColor(255,255,255, alpha * 255);
		ofDrawBitmapString( "["+ofToString(p.x, 1) + ", " +  ofToString(p.y, 1) + "]", p.x, p.y);
	}
}
	
