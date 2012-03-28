/*
 *  Grid.cpp
 *  iPhoneEmptyExample
 *
 *  Created by Oriol Ferrer Mesià on 6/28/10.
 *  Copyright 2010 uri.cat. All rights reserved.
 *
 */

#include "Grid.h"


void Grid::create(){

	double s = 10000;	
	float step = 12.5;			//each square size 400

	ofVec2f worldOrigin = ofVec2f (-s/2, -s/2);
	ofVec2f worldSize = ofVec2f( s,s);

	numPoints = worldSize.x / step;
	printf("num point: %d\n", numPoints);
	
	for ( int i=0; i<= numPoints; i+=4 ){
		linePointsV[i] = worldOrigin.x + step * i;
		linePointsV[i+1] = worldOrigin.y;
		linePointsV[i+2] = worldOrigin.x + step * i;
		linePointsV[i+3] = worldOrigin.y + worldSize.y;
	}
	
	for ( int i=0; i<= numPoints; i+=4 ){
		linePointsH[i] = worldOrigin.x;
		linePointsH[i+1] = worldOrigin.y + step * i;
		linePointsH[i+2] = worldOrigin.x + worldSize.x;
		linePointsH[i+3] = worldOrigin.y + step * i;
	}
	
	for ( int i=0; i<= numPoints*2 + 4 ; i+=4 ){
		int c = 20;
		if ((i/4)%10 == 1 || (i/4)%10 == 0)
			c = 30;
		colors[i] = c;
		colors[i+1] = c;
		colors[i+2] = c;
		colors[i+3] = 128;
	}
}


void Grid::draw(){

	glDisable(GL_BLEND);
		
//	glBlendFunc(GL_SRC_COLOR, GL_SRC_COLOR)
	glEnableClientState(GL_COLOR_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, &colors[0]);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, &linePointsH[0]);
	glDrawArrays(GL_LINES, 0, numPoints/2 + 2);

	glVertexPointer(2, GL_FLOAT, 0, &linePointsV[0]);
	glDrawArrays(GL_LINES, 0, numPoints/2 + 2);


	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
	
	glEnable(GL_BLEND);
	glColor4ub(80, 80, 80, 255);
	ofLine(0, -60, 0, 60);
	ofLine( -60, 0, 60,0);

}

