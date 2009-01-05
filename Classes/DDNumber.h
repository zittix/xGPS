#import <Foundation/Foundation.h>
#ifdef HAS_HTTPSERVER

@interface NSNumber (DDNumber)

+ (BOOL)parseString:(NSString *)str intoSInt64:(SInt64 *)pNum;
+ (BOOL)parseString:(NSString *)str intoUInt64:(UInt64 *)pNum;

+ (BOOL)parseString:(NSString *)str intoNSInteger:(NSInteger *)pNum;
+ (BOOL)parseString:(NSString *)str intoNSUInteger:(NSUInteger *)pNum;

@end
#endif
