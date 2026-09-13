#import <UIKit/UIKit.h>
#import "HALANQI/HalanqiMenu.h"
#import "HALANQI/HalanqiGameBridge.h"

%ctor {
    @autoreleasepool {
        [[HalanqiGameBridge shared] startRuntimeCapture];
        [[HalanqiMenu shared] start];
    }
}
