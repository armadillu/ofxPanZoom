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
	for (int i = 0; i < MAX_TOUCHES; i++){
		touching[i] = false;
	}
	
	minZoom = 0.1f;
	maxZoom = 10.0f;	
	zoomDiff = -1.0f;
	offset.x = offset.y = desiredOffset.x = desiredOffset.y = 0.0f;

	//vFlip = true;
	viewportConstrained = false;
}

void ofxPanZoom::setDeviceScaleFactor(float f){
	retinaUtils.setDeviceScaleFactor(f);
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

	int ww = customW == 0 ? ofGetWidth() : customW;
	int hh = customH == 0 ? ofGetHeight() : customH;
	
	float w = ww * 0.5f / zoom;
	float h = hh * 0.5f / zoom;

	//ofSetupScreenOrtho( ww, hh, (ofOrientation) ofxiPhoneGetOrientation(), true, -10.0f, 10.0f);
	retinaUtils.setupScreenOrtho( -10.0f, 10.0f );
	glScalef( zoom, zoom, zoom);
	glTranslatef( offset.x + w, offset.y + h, 0.0f );
	
	//recalc visible box
	topLeft = screenToWorld( ofVec2f() );
	bottomRight = screenToWorld( screenSize );

	//ofCircle(topLeft.x, topLeft.y, 20);
	//ofCircle(bottomRight.x, bottomRight.y, 20);	
}


void ofxPanZoom::reset(){
	//ofSetupScreen();
	retinaUtils.setupScreenPerspective();
}

void ofxPanZoom::lookAt( ofVec2f p ){
	desiredOffset.x = offset.x = -p.x;
	desiredOffset.y = offset.y = -p.y;
}

bool ofxPanZoom::fingerDown(){
	
	bool fingerDown = false;
	for (int i = 0; i < MAX_TOUCHES; i++) {
		if (touching[i] == true){
			fingerDown = true;
			break;
		}
	}
	return fingerDown;
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
	r.x =  f * p.x - f * ofGetWidth() * 0.5f - offset.x ;
	r.y =  f * p.y - f * ofGetHeight() * 0.5f - offset.y ;
	return r;
}

ofVec2f ofxPanZoom::worldToScreen( const ofVec2f & p ){
	float f = 1.0f / zoom;
	ofVec2f r;
	r.x = ( p.x + f * ofGetWidth() * 0.5f + offset.x ) * zoom;
	r.y = ( p.y + f * ofGetHeight() * 0.5f + offset.y ) * zoom;
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
		if (touching[i]) glColor4f(0, 1, 0, 1);
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
	//ofDrawBitmapString(order, 3.0f, 55.0f);
}


void ofxPanZoom::touchDown(ofTouchEventArgs &touch){

	cout << "touchdown " << touch.id << endl;
	touchIDOrder.push_back(touch.id);
	
	lastTouch[touch.id].x = touch.x;
	lastTouch[touch.id].y = touch.y;

	//printf("####### touchDown %d (zoomdif: %f) %f %f \n", touch.id, zoomDiff , touch.x, touch.y);

	if (touchIDOrder.size() >= 2){
		zoomDiff = lastTouch[ touchIDOrder[0] ].distance( lastTouch[ touchIDOrder[1] ] );
	}

	touching[touch.id] = true;
}


void ofxPanZoom::touchMoved(ofTouchEventArgs &touch){
	
	ofVec2f p, now;
	float d;
	
	//printf("####### touchMoved %d (%.1f %.1f zoomdif: %f) \n", touch.id, touch.x, touch.y, zoomDiff);
	if (touching[touch.id] == false) return;

	if (touchIDOrder.size() == 1){

		// 1 finger >> pan
		p = lastTouch[ touchIDOrder[0] ] - ofVec2f(touch.x,touch.y) ;
		desiredOffset = desiredOffset - p * (1.0f / zoom);
		applyConstrains();

	}else{

		if (touchIDOrder.size() >= 2){

			// 2 fingers >> zoom
			//cout << touchIDOrder[0] << " & " << touchIDOrder[1] << " >> " << lastTouch[ touchIDOrder[0] ] << " || " << lastTouch[ touchIDOrder[1] ] << endl;
			d = lastTouch[ touchIDOrder[0] ].distance( lastTouch[ touchIDOrder[1] ] );
			//cout << d << endl;
			if (d > MIN_FINGER_DISTANCE ){

				//printf(" zoomDiff: %f  d:%f  > zoom: %f\n", zoomDiff, d, zoom);
				if ( zoomDiff > 0 ){
					desiredZoom *= ( d / zoomDiff ) ;
					desiredZoom = ofClamp( desiredZoom, minZoom, maxZoom );
					float tx = ( lastTouch[0].x + lastTouch[1].x ) * 0.5f ;
					float ty = ( lastTouch[0].y + lastTouch[1].y ) * 0.5f ;
					tx -= ofGetWidth() * 0.5f;
					ty -= ofGetHeight() * 0.5f;
					//printf(" tx: %f   ty: %f  d / zoomDiff: %f \n", tx, ty, d / zoomDiff);
					if (desiredZoom > minZoom && desiredZoom < maxZoom){
						desiredOffset.x += tx * ( 1.0f - d / zoomDiff ) / desiredZoom ;
						desiredOffset.y += ty * ( 1.0f - d / zoomDiff ) / desiredZoom;
					}
					//printf(" zoom after %f \n", zoom);
				}

				applyConstrains();
			}

			//pan with 2 fingers too
			if ( touchIDOrder.size() == 2 ){
				p = 0.5 * ( lastTouch[touch.id] - ofVec2f(touch.x,touch.y) ); //0.5 to average both touch offsets
				desiredOffset += - p * (1.0 / desiredZoom);
			}

			zoomDiff = d;
		}
	}

	lastTouch[touch.id].x = touch.x;
	lastTouch[touch.id].y = touch.y;
}

void ofxPanZoom::touchUp(ofTouchEventArgs &touch){
	

	vector<int>::iterator it = std::find(touchIDOrder.begin(), touchIDOrder.end(), touch.id);
	if ( it == touchIDOrder.end()){
		//not found! wtf!
		//printf("wtf at touchup! can't find touchID %d\n", touch.id);
	}else{
		//printf("####### touchUp %d (zoomdif: %f) \n", touch.id, zoomDiff);
		touching[touch.id] = false;
		lastTouch[touch.id].x = touch.x;
		lastTouch[touch.id].y = touch.y;

		if ( touchIDOrder.size() >= 1) {
			zoomDiff = -1.0f;
		}

		touchIDOrder.erase(it);
	}
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
