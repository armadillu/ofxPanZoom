#include "ofApp.h"

int canvasW = 9000;	//these define where the camera can pan to
int canvasH = 9000;

void ofApp::setup(){	

	ofBackground(0);
	ofEnableAlphaBlending();
	ofSetCircleResolution(32);
	
	cam.setZoom(1.0f);
	cam.setMinZoom(0.7f);
	cam.setMaxZoom(20.0f);
	cam.setScreenSize( ofGetWidth(), ofGetHeight() ); //tell the system how large is out screen
	float gap = 100;
	cam.setViewportConstrain( ofVec3f(-gap - canvasW/2, -gap - canvasH/2), ofVec3f(canvasW/2 + gap, canvasH/2 + gap)); //limit browseable area, in world units
	cam.lookAt( ofVec2f(0,0) );
	grid.create(canvasW, canvasH, 50);
}


void ofApp::update(){

	vector<Win7TouchQueue::WinTouch> touches = tq.update();
	processTouches(touches);

	touchAnims.update(0.016f);
	cam.update(0.016f);

	float amp = 900;
	float freq = 0.2;
	ball.x = ofNoise(freq * ofGetElapsedTimef()) * amp * cos( ofGetElapsedTimef() * freq );
	ball.y = ofNoise(0, freq * ofGetElapsedTimef()) * amp * sin( ofGetElapsedTimef() * freq );
}


void ofApp::draw(){
		
	cam.apply(); //put all our drawing under the ofxPanZoom effect
	
		//draw grid
		grid.draw();
		touchAnims.draw();
	
		//draw space constrains		
		glColor4f(1, 1, 1, 0.1);
		ofRect(-canvasW/2, -canvasH/2, canvasW, canvasH);
		
		glColor4f(1, 0, 0, 1);
		ofNoFill();
		ofSetLineWidth(2);
		ofRect(-canvasW/2, -canvasH/2, canvasW, canvasH);
		ofFill();
		ofSetLineWidth(1);
	
		ofSetColor(128, 0, 0);
		ofCircle(ball, 50);
	
	cam.reset();	//back to normal ofSetupScreen() projection

	ofSetColor(255);
	//now draw on top of our ball in "screen" coordinates
	ofVec2f screenBall = cam.worldToScreen(ball);
	ofDrawBitmapString( "world:  " + ofToString(ball) + "\n" +
						"screen: " + ofToString(screenBall),
					    screenBall + ofVec2f(60 * cam.getZoom(), 0)
					   );

	cam.drawDebug(); //see info on ofxPanZoom status
	
}


void ofApp::processTouches(vector<Win7TouchQueue::WinTouch> & t){

	for(int i = 0 ; i < t.size(); i++){
		ofTouchEventArgs touch;
		touch.id = t[i].ID;
		touch.x = t[i].pos.x;
		touch.y = t[i].pos.y;;

		switch (t[i].action) {
		case Win7TouchQueue::TOUCH_ADD:{
			cam.touchDown(touch); //fw event to cam
			ofVec3f p =  cam.screenToWorld( ofVec3f( touch.x, touch.y) );	//convert touch (in screen units) to world units
			touchAnims.addTouch( p.x, p.y ); 
									   }break;

		case Win7TouchQueue::TOUCH_UPDATE:
			cam.touchMoved(touch); //fw event to cam
			break;

		case Win7TouchQueue::TOUCH_REMOVE:
			cam.touchUp(touch);	//fw event to cam
			break;

		default:
			break;
		}
	}
}

void ofApp::touchDown(int x, int y, int id){

	//cout << "touchDown " << x << ", " << y << "  ID: " << id << endl;
	tq.addTouchAdded(id, ofVec2f(x,y));
}

void ofApp::touchMoved(int x, int y, int id){
	//cout << "touchMoved " << x << ", " << y << "  ID: " << id << endl;
	tq.addTouchUpdated(id, ofVec2f(x,y));
}


void ofApp::touchUp(int x, int y, int id){
	//cout << "touchUp " << x << ", " << y << "  ID: " << id << endl;
	tq.addTouchRemoved(id, ofVec2f(x,y));
}


// void ofApp::touchDoubleTap(ofTouchEventArgs &touch){
// 	cam.touchDoubleTap(touch); //fw event to cam
// 	cam.setZoom(1.0f);	//reset zoom
// 	cam.lookAt( ofVec2f(canvasW/2, canvasH/2) ); //reset position
// }
// 
