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
	
	zoom = 1.0f;	
	for (int i = 0; i < MAX_TOUCHES; i++){
		touching[i] = false;
	}
	
	minZoom = 0.1f;
	maxZoom = 10.0f;	
	zoomDiff = -1.0f;
	offset.x = offset.y = 0;

	vFlip = true;
	viewportConstrained = false;
}

void ofxPanZoom::setScreenSize(int x, int y){
	
	screenSize.x = x;
	screenSize.y = y;
	topLeft = screenToWorld( ofVec3f(0, 0) );
	bottomRight = screenToWorld( screenSize );
}


bool ofxPanZoom::isOnScreen( ofVec3f p ){	///gets point in gl coords, not screen coords
	
	if ( p.x > topLeft.x && p.x < bottomRight.x 
		 &&
		 p.y < topLeft.y && p.y > bottomRight.y 
		) return true;
	else
		return false;
}


void ofxPanZoom::apply(){

	float w = ofGetWidth() * 0.5f / zoom;
	float h = ofGetHeight() * 0.5f / zoom;

	//old custom projection code
	
//	glMatrixMode(GL_PROJECTION);
//	glLoadIdentity();
//	//glScalef( zoom, zoom, zoom );
//	glOrthof(	- w - offset.x + zoomOffset.y, 
//				w - offset.x + zoomOffset.x,
//				- h + offset.y + zoomOffset.x,
//				h + offset.y + zoomOffset.y,
//				-10, 10);
//	
//	glMatrixMode(GL_MODELVIEW);
//	glLoadIdentity();
//
//	//flip OF style
//	if (vFlip) glScalef(1, -1, 1);
//	//glTranslatef(0, 0, 0);

	ofSetupScreenOrtho(ofGetWidth(), ofGetHeight(), (ofOrientation) ofxiPhoneGetOrientation(), true, -10, 10);
	glScalef( zoom, zoom, zoom);
	glTranslatef( offset.x + w + zoomOffset.x, offset.y + h + zoomOffset.y, 0 );	
	
	//recalc visible box
	topLeft = screenToWorld( ofVec3f() );
	bottomRight = screenToWorld( screenSize );
}


void ofxPanZoom::reset(){
	ofSetupScreen();	
}

void ofxPanZoom::lookAt( ofVec3f p ){
	offset.x = -p.x;
	offset.y = -p.y;
}


ofVec3f ofxPanZoom::screenToWorld( ofVec3f p ){
	double f = 1.0 / zoom;
	p.x =  f * p.x - f * ofGetWidth() * 0.5 - offset.x ;
	p.y =  f * p.y - f * ofGetHeight() * 0.5 - offset.y ;
	return p;
}


void ofxPanZoom::drawDebug(){

	for (int i = 0; i < MAX_TOUCHES; i++){
		if (touching[i]) glColor4f(0, 1, 0, 1);
		else glColor4f(1, 0, 0, 1);
		double w = 8;
		ofRect( i * (w + 3), 3, w, w);
	}
	
	char msg[1000];
	sprintf(msg, " zoom: %.1f \n offset: %.1f, %.1f \n ", zoom, offset.x, offset.y);
	glColor4f(1, 1, 1, 1);
	ofDrawBitmapString(msg, 3, 25);
}


void ofxPanZoom::touchDown(ofTouchEventArgs &touch){

	lastTouch[touch.id].x = touch.x;
	lastTouch[touch.id].y = touch.y;

	printf("####### touchDown %d (zoomdif: %f) %f %f \n", touch.id, zoomDiff , touch.x, touch.y);
	
	switch ( touch.numTouches ) {

		case 1:			
			break;

		case 2:			
			zoomDiff = lastTouch[0].distance( lastTouch[1] );
			//printf(" !!!!!!!!!!!!!!!   touchDown 2 touches zoomDiff: %f\n", zoomDiff);
			break;

		default:
			break;
	}
	
	touching[touch.id] = true;
}


void ofxPanZoom::touchMoved(ofTouchEventArgs &touch){
	
	ofVec3f p, now;
	double d;
	
	//printf("####### touchMoved %d (zoomdif: %f) \n", touch.id, zoomDiff);
	switch ( touch.numTouches ) {

		case 1:
			// 1 finger >> pan
			p = lastTouch[touch.id] - ofVec3f(touch.x,touch.y) ;
			offset = offset - p * (1.0 / zoom);
			applyConstrains();
			break;

		case 2:
			
			//pan with 2 fingers ?
			//p = lastTouch[touch.id] - ofVec3f(touch.x,touch.y) ;
			//offset = offset - p * (1.0 / zoom);			
			
			// 2 fingers >> zoom
			d = lastTouch[0].distance( lastTouch[1] );
				if (d > MIN_FINGER_DISTANCE ){
				
				//printf(" zoomDiff: %f  d:%f  > zoom: %f\n", zoomDiff, d, zoom);
				if ( zoomDiff > 0 ){
					zoom *= ( d / zoomDiff ) ;
					zoom = ofClamp( zoom, minZoom, maxZoom );
					float tx = ( lastTouch[0].x + lastTouch[1].x ) * 0.5f ;
					float ty = ( lastTouch[0].y + lastTouch[1].y ) * 0.5f ;
					tx -= ofGetWidth() * 0.5;
					ty -= ofGetHeight() * 0.5;
					//printf(" tx: %f   ty: %f  d / zoomDiff: %f \n", tx, ty, d / zoomDiff);
					if (zoom > minZoom && zoom < maxZoom){
						offset.x += tx * ( 1.0f - d / zoomDiff ) / zoom ;
						offset.y += ty * ( 1.0f - d / zoomDiff ) / zoom;
					}
					//printf(" zoom after %f \n", zoom);
				}

				zoomDiff = d;
				applyConstrains();
			}
			break;
	
		default:
			break;
	}
	
	lastTouch[touch.id].x = touch.x;
	lastTouch[touch.id].y = touch.y;
}


void ofxPanZoom::touchUp(ofTouchEventArgs &touch){

	touching[touch.id] = false;
	lastTouch[touch.id].x = touch.x;
	lastTouch[touch.id].y = touch.y;
	if (touch.id == 0 || touch.id == 1)
		zoomDiff = -1;
}


void ofxPanZoom::touchDoubleTap(ofTouchEventArgs &touch){

}

void ofxPanZoom::setViewportConstrain(ofVec3f topLeftConstrain_, ofVec3f bottomRightConstrain_ ){
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

		if ( offset.x < topLeftConstrain.x + xx){ 
			offset.x = topLeftConstrain.x + xx;
			//printf("ox < topleft = %f\n", offset.x);
		}
		if( offset.y < topLeftConstrain.y + yy ){
			offset.y = topLeftConstrain.y + yy;
			//printf("oy < topleft = %f\n", offset.y);
		}
		
		if ( offset.x > bottomRightConstrain.x - xx){
			offset.x = bottomRightConstrain.x - xx;
			printf("ox < bottomRight = %f\n", offset.x);
		}
		if (offset.y > bottomRightConstrain.y - yy){
			offset.y = bottomRightConstrain.y - yy;
			printf("oy < bottomRight = %f\n", offset.y);
		}
	}
}
