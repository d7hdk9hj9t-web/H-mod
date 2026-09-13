#import <Foundation/Foundation.h>

@interface HalanqiGameBridge : NSObject
+ (instancetype)shared;
- (void)startRuntimeCapture;
- (BOOL)invokeZeroArg:(NSString *)selector onClassNamed:(NSString *)className;
- (BOOL)isClassAvailable:(NSString *)className;
- (NSString *)runtimeStatus;
@end
