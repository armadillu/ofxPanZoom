/*
 *  Grid.cpp
 *  iPhoneEmptyExample
 *
 *  Created by Oriol Ferrer Mesià on 6/28/10.
 *  Copyright 2010 uri.cat. All rights reserved.
 *
 */

#include "Grid.h"


void Grid::create(int w, int h, int step){

	mesh.clear();

	float gridH = w / float(step);
	float numLinesH = h / gridH;
	mesh.setMode(OF_PRIMITIVE_LINES);
	
	ofColor col;

	for(int i = 0; i < numLinesH; i++){
		mesh.addVertex( ofVec2f(-w/2,  -h/2 + gridH * i) );
		mesh.addVertex( ofVec2f(w/2,  -h/2 + gridH * i) );
		
		if ((i)%5 == 0)
			col.r = col.g = col.b = 40;
		else
			col.r = col.g = col.b = 10;
		mesh.addColor(col);
		mesh.addColor(col);
	}

	float numLinesW = w / float(gridH);

	for(int i = 0; i < numLinesW; i++){
		mesh.addVertex( ofVec2f( -w/2 + gridH * i, -h/2 ) );
		mesh.addVertex( ofVec2f( -w/2 + gridH * i, h/2) );

		if ((i)%5 == 0)
			col.r = col.g = col.b = 40;
		else
			col.r = col.g = col.b = 10;
		mesh.addColor(col);
		mesh.addColor(col);
	}

}


void Grid::draw(){

	mesh.draw();

	glColor4ub(80, 80, 80, 255);
	ofLine(0, -60, 0, 60);
	ofLine( -60, 0, 60,0);

}

