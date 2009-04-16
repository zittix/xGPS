//
//  Benchmark.m
//  xGPS
//
//  Created by Mathieu on 16.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Benchmark.h"
#include <time.h>
static clock_t lastControl=0;
@implementation Benchmark
+(void)controlPoint:(NSString*)name {
	if(lastControl==0) 
		lastControl=clock();
	else {
		clock_t diff=clock()-lastControl;
		lastControl=clock();
		if(name!=nil)
		NSLog(@"--BENCHMARK-%@: %f ms",name,(double)diff/CLOCKS_PER_SEC*1000.0f);
	}
}
@end
