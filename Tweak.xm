#import <UIKit/UIKit.h>
#import "HalanqiMenu.h"
#import "HalanqiGameBridge.h"

%ctor {
    @autoreleasepool {
        [[HalanqiGameBridge shared] startRuntimeCapture];
        [[HalanqiMenu shared] start];
    }
}
