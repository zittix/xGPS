//
//  Benchmark.h
//  xGPS
//
//  Created by Mathieu on 16.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#define DO_BENCHMARK
#ifdef DO_BENCHMARK
#define BENCHMARK(name) [Benchmark controlPoint:name]
#else
#define BENCHMARK(name)
#endif

@interface Benchmark : NSObject {

}
+(void)controlPoint:(NSString*)name;
@end
