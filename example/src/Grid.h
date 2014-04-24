/*
 *  Grid.h
 *  iPhoneEmptyExample
 *
 *  Created by Oriol Ferrer Mesià on 6/28/10.
 *  Copyright 2010 uri.cat. All rights reserved.
 *
 */

#pragma once


#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"


class Grid {
	
	public:
		void create();
		void draw();

	float linePointsV[1004];
	float linePointsH[1004];
	GLubyte colors[1004 * 2];
	int	numPoints;
};