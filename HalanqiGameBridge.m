#import "HalanqiGameBridge.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

static NSMutableDictionary<NSString *, NSHashTable *> *HLInstances;
static NSMutableSet<NSString *> *HLInstalled;
static NSLock *HLLock;
static NSMutableDictionary<NSString *, NSValue *> *HLOriginalInits;

static id HLInit(id self, SEL _cmd) {
    Class cls = object_getClass(self);
    NSString *name = NSStringFromClass(cls);
    [HLLock lock];
    IMP original = [HLOriginalInits[name] pointerValue];
    [HLLock unlock];
    if (!original) return self;
    id (*fn)(id, SEL) = (id (*)(id, SEL))original;
    id obj = fn(self, _cmd);
    if (obj) {
        [HLLock lock];
        NSHashTable *table = HLInstances[name];
        if (!table) { table = [NSHashTable weakObjectsHashTable]; HLInstances[name] = table; }
        [table addObject:obj];
        [HLLock unlock];
    }
    return obj;
}

static void HLInstallInitCapture(Class cls) {
    if (!cls) return;
    NSString *name = NSStringFromClass(cls);
    [HLLock lock];
    if ([HLInstalled containsObject:name]) { [HLLock unlock]; return; }
    [HLInstalled addObject:name];
    [HLLock unlock];

    Method initM = class_getInstanceMethod(cls, @selector(init));
    if (initM) {
        IMP old = method_getImplementation(initM);
        if (old) {
            [HLLock lock];
            HLOriginalInits[name] = [NSValue valueWithPointer:old];
            [HLLock unlock];
            class_replaceMethod(cls, @selector(init), (IMP)HLInit, method_getTypeEncoding(initM));
        }
    }
}

@implementation HalanqiGameBridge
+ (instancetype)shared {
    static HalanqiGameBridge *x;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        x = [HalanqiGameBridge new];
        HLInstances = [NSMutableDictionary dictionary];
        HLInstalled = [NSMutableSet set];
        HLOriginalInits = [NSMutableDictionary dictionary];
        HLLock = [NSLock new];
    });
    return x;
}

- (void)startRuntimeCapture {
    // Capture real instances created after the tweak loads. The IPA provides
    // class/selector metadata; instances themselves only exist at runtime.
    NSArray *names = @[
        @"BaseArenaView", @"ControlsWidget", @"JoystickInput",
        @"JoystickView", @"LineDrawer", @"StaticPlayButtonContainer"
    ];
    for (NSString *name in names) {
        Class cls = NSClassFromString(name);
        if (cls) HLInstallInitCapture(cls);
    }
}

- (BOOL)isClassAvailable:(NSString *)className {
    return NSClassFromString(className) != Nil;
}

- (BOOL)invokeZeroArg:(NSString *)selector onClassNamed:(NSString *)className {
    if (!selector.length || !className.length) return NO;
    Class wanted = NSClassFromString(className);
    if (!wanted) return NO;

    [HLLock lock];
    NSArray *objects = [HLInstances[className].allObjects copy];
    [HLLock unlock];

    SEL sel = NSSelectorFromString(selector);
    BOOL invoked = NO;
    for (id obj in objects) {
        if (!obj || ![obj respondsToSelector:sel]) continue;
        NSMethodSignature *sig = [obj methodSignatureForSelector:sel];
        if (!sig || sig.numberOfArguments != 2) continue;
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        inv.target = obj;
        inv.selector = sel;
        @try {
            [inv invoke];
            invoked = YES;
            break;
        } @catch (__unused NSException *e) {
            // Do not let an unsupported runtime object kill the game.
        }
    }
    return invoked;
}

- (NSString *)runtimeStatus {
    NSMutableArray *parts = [NSMutableArray array];
    for (NSString *name in @[@"BaseArenaView", @"ControlsWidget", @"JoystickInput", @"JoystickView", @"LineDrawer"]) {
        Class cls = NSClassFromString(name);
        if (!cls) { [parts addObject:[NSString stringWithFormat:@"%@=missing", name]]; continue; }
        [HLLock lock];
        NSUInteger count = HLInstances[name].allObjects.count;
        [HLLock unlock];
        [parts addObject:[NSString stringWithFormat:@"%@=%lu", name, (unsigned long)count]];
    }
    return [parts componentsJoinedByString:@" | "];
}
@end
