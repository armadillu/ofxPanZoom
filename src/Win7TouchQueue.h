#pragma once
#include "ofMain.h"


class Win7TouchQueue{

public:

	enum TouchAction{ TOUCH_ADD, TOUCH_UPDATE, TOUCH_REMOVE };

	struct WinTouch{
		TouchAction action;
		int ID;
		ofVec2f pos;
		WinTouch(TouchAction a, int ID_, ofVec2f p){
			action = a; ID = ID_; pos = p;
		}
	};
	

	Win7TouchQueue(void);
	~Win7TouchQueue(void);

	vector<WinTouch> update();
	void lock();

	//
	void addTouchAdded(int ID, ofVec2f p);
	void addTouchUpdated(int ID, ofVec2f p);
	void addTouchRemoved(int ID, ofVec2f p);

	ofMutex mutex;
	vector<WinTouch> queue;
	map<int, int> touchDowns;
	map<int, int> touchIdMap;


};

