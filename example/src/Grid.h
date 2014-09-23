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


class Grid {
	
	public:
		void create(int w, int h, int step);
		void draw();

	ofVboMesh mesh;
};