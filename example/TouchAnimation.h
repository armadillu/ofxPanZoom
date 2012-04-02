/*
 *  TouchAnimation.h
 *  emptyExample
 *
 *  Created by Oriol Ferrer Mesià on 28/03/12.
 *  Copyright 2012 uri.cat. All rights reserved.
 *
 */

#include "ofMain.h"
#include <vector>

#define TOUCH_ANIM_DURATION	0.75f
#define TOUCH_ANIM_RADIUS	75.0f

class TouchAnimation{

public:
	
	typedef struct touch{
		ofVec2f pos;
		float time;
	};
	
	vector<touch> touches;
	
	void update(float dt);
	void addTouch(float x, float y);
	void draw();
	
};
