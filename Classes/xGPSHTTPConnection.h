//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//
#ifdef HAS_HTTPSERVER
#import <Foundation/Foundation.h>
#import "HTTPConnection.h"


@interface xGPSHTTPConnection : HTTPConnection
{
	int dataStartIndex;
	NSMutableArray* multipartData;
	BOOL postHeaderOK;
	NSString *fileSaving;
}

- (BOOL)isBrowseable:(NSString *)path;
- (NSString *)createBrowseableIndex:(NSString *)path;

@end
#endif