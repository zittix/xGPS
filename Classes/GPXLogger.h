//
//  GPXLogger.h
//  xGPS
//
//  Created by Mathieu on 10/30/08.
//  Copyright 2008 Xwaves. All rights reserved.
//
void stopGPXLogEngine();
void startGPXLogEngine();
void logGPXPoint(float lat, float lon, float alt, float speed, int fix, int sat);
const char* getGPXFilename();