/*
 *  ofxPanZoom.cpp
 *  iPhoneEmptyExample
 *
 *  Created by Oriol Ferrer Mesià on 5/17/10.
 *  Copyright 2010 uri.cat. All rights reserved.
 *
 */

#include "ofxPanZoom.h"


ofxPanZoom::ofxPanZoom(){
	smoothFactor = 0.55;
	zoom = desiredZoom =  1.0f;
	
	minZoom = 0.1f;
	maxZoom = 10.0f;	
	zoomDiff = -1.0f;
	offset.x = offset.y = desiredOffset.x = desiredOffset.y = 0.0f;

	//vFlip = true;
	viewportConstrained = false;

	enableTranslate();
	setArea(ofVec2f(ofGetWidth(), ofGetHeight()));
}


void ofxPanZoom::setScreenSize(int x, int y){
	
	screenSize.x = x;
	screenSize.y = y;
	topLeft = screenToWorld( ofVec2f(0.0f, 0.0f) );
	bottomRight = screenToWorld( screenSize );
}


bool ofxPanZoom::isOnScreen( const ofVec2f & p, float gap ){	///gets point in gl coords, not screen coords, gap in world units too
	
	if ( p.x > topLeft.x - gap && p.x < bottomRight.x + gap 
		 &&
		 p.y > topLeft.y - gap && p.y < bottomRight.y + gap
		) return true;
	else
		return false;
}

bool ofxPanZoom::isOnScreen( const ofRectangle & r, float gap ){	///gets point in gl coords, not screen coords, gap in world units too

	ofRectangle r2 = ofRectangle(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
	return r.intersects( r2 );
}


void ofxPanZoom::apply(int customW, int customH){

	int ww = customW == 0 ? area.x : customW;
	int hh = customH == 0 ? area.y : customH;
	
	float w = ww * 0.5f / zoom;
	float h = hh * 0.5f / zoom;

	//ofSetOrientation(ofGetOrientation(), true);
	ofSetupScreenOrtho( ww, hh, -10.0f, 10.0f);
	//setupScreenOrtho(-10, 10);

	glScalef( zoom, zoom, zoom);
	glTranslatef( offset.x + w, offset.y + h, 0.0f );
	//cout << offset << endl;
	//recalc visible box
	topLeft = screenToWorld( ofVec2f() );
	bottomRight = screenToWorld( screenSize );

	//ofCircle(topLeft.x, topLeft.y, 20);
	//ofCircle(bottomRight.x, bottomRight.y, 20);	
}


void ofxPanZoom::reset(){
	ofSetupScreen();
}

void ofxPanZoom::lookAt( ofVec2f p ){
	desiredOffset.x = offset.x = -p.x;
	desiredOffset.y = offset.y = -p.y;
}

bool ofxPanZoom::fingerDown(){
	return touchIDOrder.size() > 0;
}


void ofxPanZoom::update(float deltaTime){
	float time = 1; deltaTime / 60.0f;
	zoom = (time * smoothFactor) * desiredZoom + (1.0f - smoothFactor * time) * zoom;
	offset = (time * smoothFactor) * desiredOffset + (1.0f - smoothFactor * time) * offset;
	applyConstrains();
}


ofVec2f ofxPanZoom::screenToWorld( const ofVec2f & p ){
	float f = 1.0f / zoom;
	ofVec2f r;
	r.x =  f * p.x - f * area.x * 0.5f - offset.x ;
	r.y =  f * p.y - f * area.y * 0.5f - offset.y ;
	return r;
}

ofVec2f ofxPanZoom::worldToScreen( const ofVec2f & p ){
	float f = 1.0f / zoom;
	ofVec2f r;
	r.x = ( p.x + f * area.x * 0.5f + offset.x ) * zoom;
	r.y = ( p.y + f * area.y * 0.5f + offset.y ) * zoom;
	return r;
}



ofRectangle ofxPanZoom::getCurentViewPort(){
	return ofRectangle(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
}


bool ofxPanZoom::viewportDidChange(){
	ofRectangle r = getCurentViewPort();
	bool ret;
	if (r == pViewport){
		ret = false;
	}else{
		ret = true;
	}
	pViewport = r;
	return ret;
}


void ofxPanZoom::drawDebug(){

	ofSetRectMode(OF_RECTMODE_CORNER);
	for (int i = 0; i < MAX_TOUCHES; i++){
		if (i < touchIDOrder.size()) glColor4f(0, 1, 0, 1);
		else glColor4f(1, 0, 0, 1);
		float w = 8;
		ofRect( i * (w + 3), 3, w, w);
	}

	string order = " touchOrder: ";
	for (int i = 0; i < touchIDOrder.size(); i++){
		order += ofToString( touchIDOrder[i] ) + ", ";
	}

	char msg[1000];
	sprintf(msg, " zoom: %.1f \n offset: %.1f, %.1f \n ", zoom, offset.x, offset.y);
	glColor4f(1, 1, 1, 1);
	ofDrawBitmapString(msg, 3.0f, 25.0f);
	ofDrawBitmapString(order, 3.0f, 55.0f);
}


void ofxPanZoom::touchDown(ofTouchEventArgs &touch){
	//cout << "touchdown " << touch.id << endl;
	touchIDOrder.push_back(touch.id);

	int idx = idToIndex(touch.id);

	if(idx == INDEX_NOT_FOUND){
		// cout << "ofxPanZoom#touchDown INDEX_NOT_FOUND - How could this happen, we just added it?!";
		return;
	}

	// ofTouchEventArgs inherits from ofVec2f, it's essentially a 2d float vector
	lastTouch[idx].set(touch);
	//printf("####### touchDown %d (zoomdif: %f) %f %f \n", touch.id, zoomDiff , touch.x, touch.y);

	if (touchIDOrder.size() >= 2){
		// use first two touches, ignore the rest
		zoomDiff = lastTouch[0].distance( lastTouch[1] );
	}
}


void ofxPanZoom::touchMoved(ofTouchEventArgs &touch){
	ofVec2f p, now;
	float d;

	int idx = idToIndex(touch.id);

	if(idx == INDEX_NOT_FOUND){
		// cout << "ofxPanZoom#touchMoved INDEX_NOT_FOUND";
		return;
	}

	//printf("####### touchMoved %d (%.1f %.1f zoomdif: %f) \n", touch.id, touch.x, touch.y, zoomDiff);

	if (touchIDOrder.size() == 1 && bTranslate){
		// 1 finger >> pan
		p = lastTouch[idx] - ofVec2f(touch.x,touch.y) ;
		desiredOffset = desiredOffset - p * (1.0f / zoom);
		applyConstrains();
	}else{
		if (touchIDOrder.size() >= 2){
			// 2 fingers >> zoom
			// cout << touchIDOrder[0] << " & " << touchIDOrder[1] << " >> " << lastTouch[0] << " || " << lastTouch[1] << endl;

			// use first two touches, ignore the rest
			d = lastTouch[ 0 ].distance( lastTouch[ 1 ] );
			//cout << d << endl;
			if (d > MIN_FINGER_DISTANCE ){
				// printf(" zoomDiff: %f  d:%f  > zoom: %f\n", zoomDiff, d, zoom);
				if ( zoomDiff > 0 ){
					desiredZoom *= ( d / zoomDiff ) ;
					desiredZoom = ofClamp( desiredZoom, minZoom, maxZoom );
					float tx = ( lastTouch[0].x + lastTouch[1].x ) * 0.5f ;
					float ty = ( lastTouch[0].y + lastTouch[1].y ) * 0.5f ;
					tx -= area.x * 0.5;
					ty -= area.y * 0.5;
					// printf(" tx: %f   ty: %f  d / zoomDiff: %f \n", tx, ty, d / zoomDiff);
					if (desiredZoom > minZoom && desiredZoom < maxZoom){
						desiredOffset.x += tx * ( 1.0f - d / zoomDiff ) / desiredZoom ;
						desiredOffset.y += ty * ( 1.0f - d / zoomDiff ) / desiredZoom;
					}
					// printf(" zoom after %f \n", zoom);
				}

				applyConstrains();
			}

			//pan with 2 fingers too
			if ( touchIDOrder.size() == 2 ){
				p = 0.5 * ( lastTouch[idx] - ofVec2f(touch.x,touch.y) ); //0.5 to average both touch offsets
				desiredOffset += - p * (1.0 / desiredZoom);
			}

			zoomDiff = d;
		}
	}

	lastTouch[idx].set(touch);
}

void ofxPanZoom::touchUp(ofTouchEventArgs &touch){
	int idx = idToIndex(touch.id);

	if(idx == INDEX_NOT_FOUND){
		//not found! wtf!
		printf("wtf at touchup! can't find touchID %d\n", touch.id);
		return;
	}

	//printf("####### touchUp %d (zoomdif: %f) \n", touch.id, zoomDiff);
	lastTouch[idx].set(touch);

	if ( touchIDOrder.size() >= 1) {
		zoomDiff = -1.0f;
	}

	touchIDOrder.erase(touchIDOrder.begin()+idx);
	// by taking the touch ID out of the touchIDOrder vector, all the later
	// touches (if any) will shift one index down. So all lastTouch coordinates
	// should shift down with them (because these two lists are related).
	// That's what we're doing here:
	std::memcpy(&lastTouch[idx], &lastTouch[idx+1], sizeof(int) * (MAX_TOUCHES - idx - 1));
}


void ofxPanZoom::touchDoubleTap(ofTouchEventArgs &touch){

}

void ofxPanZoom::setViewportConstrain( ofVec2f topLeftConstrain_, ofVec2f bottomRightConstrain_ ){
	viewportConstrained = true;
	topLeftConstrain = topLeftConstrain_;
	bottomRightConstrain = bottomRightConstrain_;
}

void ofxPanZoom::removeViewportConstrain(){
	viewportConstrained = false;	
}

int ofxPanZoom::idToIndex(int id){
	for(int i = touchIDOrder.size() - 1; i >= 0; i--)
		if(touchIDOrder[i] == id)
			return i;
	return INDEX_NOT_FOUND;
}

void ofxPanZoom::applyConstrains(){
	
	if (viewportConstrained){
		float xx = screenSize.x * 0.5f * (1.0f /  zoom);
		float yy = screenSize.y * 0.5f * (1.0f /  zoom);

		if ( desiredOffset.x > - (topLeftConstrain.x + xx) ){ 
			desiredOffset.x = - (topLeftConstrain.x + xx);
		}
		if( desiredOffset.y > - (topLeftConstrain.y + yy) ){
			desiredOffset.y = - (topLeftConstrain.y + yy);
		}
		if ( desiredOffset.x < - (bottomRightConstrain.x - xx) ){
			desiredOffset.x = - (bottomRightConstrain.x - xx);
		}
		
		if ( desiredOffset.y < - (bottomRightConstrain.y - yy) ){
			desiredOffset.y = - (bottomRightConstrain.y - yy);
		}
	}
}
