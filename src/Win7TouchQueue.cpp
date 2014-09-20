#include "Win7TouchQueue.h"


Win7TouchQueue::Win7TouchQueue(void){
}


Win7TouchQueue::~Win7TouchQueue(void){
}



vector<Win7TouchQueue::WinTouch> Win7TouchQueue::update(){
	mutex.lock();
	vector<WinTouch> q = queue;
	queue.clear();
	mutex.unlock();
	return q;
}


void Win7TouchQueue::addTouchAdded(int ID, ofVec2f p){
	mutex.lock();
	touchDowns[ID] = 1;
	touchIdMap[ID] = touchDowns.size()-1;
	WinTouch t = WinTouch(TOUCH_ADD, touchIdMap[ID], p);
	queue.push_back(t);
	mutex.unlock();
}

void Win7TouchQueue::addTouchUpdated(int ID, ofVec2f p){
	mutex.lock();
	WinTouch t = WinTouch(TOUCH_UPDATE, touchIdMap[ID], p);
	queue.push_back(t);
	mutex.unlock();
}

void Win7TouchQueue::addTouchRemoved(int ID, ofVec2f p){
	mutex.lock();
	touchDowns[ID] = 0;
	touchDowns.erase(touchDowns.find(ID));
	WinTouch t = WinTouch(TOUCH_REMOVE, touchIdMap[ID], p);
	queue.push_back(t);
	mutex.unlock();
}

