#include "ofMain.h"
#include "ofApp.h"

int main(){

	ofAppiOSWindow * iOSWindow = new ofAppiOSWindow();

	iOSWindow->enableRetina(); //enable retina!

	ofSetupOpenGL(iOSWindow, 480, 320, OF_FULLSCREEN);
	ofRunApp(new ofApp);
}
