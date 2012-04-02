#include "testApp.h"

int limitX = 1000;
int limitY = 1500;

void testApp::setup(){	
	// register touch events
	ofRegisterTouchEvents(this);
	ofxiPhoneSetOrientation( (ofOrientation)ofxiPhoneGetOrientation() );	
	// initialize the accelerometer
	ofxAccelerometer.setup();	
	//iPhoneAlerts will be sent to this.
	ofxiPhoneAlerts.addListener(this);
	
	ofBackground(0);
	ofEnableAlphaBlending();
	
	cam.setZoom(1.0f);
	cam.setMinZoom(0.5f);
	cam.setMaxZoom(5.0f);
	cam.setScreenSize( ofGetWidth(), ofGetHeight() );
	cam.setViewportConstrain( ofVec3f(-limitX, -limitY), ofVec3f(limitX, limitY)); //limit browseable area, in world units
	
	grid.create();
}


void testApp::update(){
	touchAnims.update(0.016f);
}


void testApp::draw(){
		
	cam.apply(); //put all our drawing under the ofxPanZoom effect
	
		//draw grid
		grid.draw();
		touchAnims.draw();
	
		//draw constrains		
		int s = 25;
		glColor4f(1, 0, 0, 1);
		ofRect(-limitX , -limitY , 2 * limitX, s);
		ofRect(limitX - s , -limitY , s, 2 * limitY);
		ofRect(-limitX , limitY - s , s, -2 * limitY);	
		ofRect(limitX , limitY - s, -2 * limitX, s);		
		glColor4f(1, 1, 1, 1);
	
	cam.reset();	//back to normal ofSetupScreen() projection
	
	cam.drawDebug(); //see info on ofxPanZoom status
	
	glColor4f(1,1,1,1);
	ofDrawBitmapString("fps: " + ofToString( ofGetFrameRate() ),  10, ofGetHeight() - 10 );	
}


void testApp::touchDown(ofTouchEventArgs &touch){

	cam.touchDown(touch); //fw event to cam
	
	ofVec3f p =  cam.screenToWorld( ofVec3f( touch.x, touch.y) );	//convert touch to world units
	touchAnims.addTouch( p.x, p.y);
}


void testApp::touchMoved(ofTouchEventArgs &touch){
	cam.touchMoved(touch); //fw event to cam
}


void testApp::touchUp(ofTouchEventArgs &touch){
	cam.touchUp(touch);	//fw event to cam
}


void testApp::touchDoubleTap(ofTouchEventArgs &touch){
	cam.touchDoubleTap(touch); //fw event to cam
	cam.setZoom(1.0f);	//reset zoom
	cam.lookAt( ofVec3f() ); //reset position
}


void testApp::touchCancelled(ofTouchEventArgs& args){

}


void testApp::deviceOrientationChanged(int newOrientation){
	ofxiPhoneSetOrientation( (ofOrientation)newOrientation);
	cam.setScreenSize(ofGetWidth(), ofGetHeight());
};
