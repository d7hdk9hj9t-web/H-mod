#import "HalanqiMenu.h"
#import "HalanqiGameBridge.h"

@interface HalanqiMenu ()
@property(nonatomic,strong) UIWindow *window;
@property(nonatomic,strong) UIButton *floatButton;
@property(nonatomic,strong) UIView *panel;
@property(nonatomic,strong) UILabel *status;
@end

@implementation HalanqiMenu

+ (instancetype)shared {
    static HalanqiMenu *x;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        x = [HalanqiMenu new];
    });
    return x;
}

- (UIWindow *)activeWindow {
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {

            if (![scene isKindOfClass:[UIWindowScene class]]) {
                continue;
            }

            UIWindowScene *windowScene = (UIWindowScene *)scene;

            if (windowScene.activationState == UISceneActivationStateUnattached) {
                continue;
            }

            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    return window;
                }
            }

            for (UIWindow *window in windowScene.windows) {
                if (!window.hidden &&
                    window.alpha > 0.0 &&
                    window.windowLevel == UIWindowLevelNormal) {
                    return window;
                }
            }
        }
    }

    return nil;
}

- (void)start {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *host = [self activeWindow];

        if (!host) {
            dispatch_after(
                dispatch_time(
                    DISPATCH_TIME_NOW,
                    (int64_t)(1 * NSEC_PER_SEC)
                ),
                dispatch_get_main_queue(), ^{
                    [self start];
                }
            );
            return;
        }

        self.window = host;
        [self installFloatButton];
    });
}

- (void)installFloatButton {
    if (self.floatButton.superview) {
        return;
    }

    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];

    b.frame = CGRectMake(18, 120, 54, 54);
    b.layer.cornerRadius = 27;
    b.backgroundColor =
        [UIColor colorWithWhite:0.04 alpha:0.94];

    b.layer.borderWidth = 1.5;
    b.layer.borderColor =
        [UIColor colorWithWhite:0.8 alpha:0.7].CGColor;

    [b setTitle:@"H" forState:UIControlStateNormal];

    b.titleLabel.font =
        [UIFont boldSystemFontOfSize:24];

    [b setTitleColor:UIColor.whiteColor
            forState:UIControlStateNormal];

    [b addTarget:self
          action:@selector(toggle)
        forControlEvents:UIControlEventTouchUpInside];

    [self.window addSubview:b];

    self.floatButton = b;
}

- (void)toggle {
    if (!self.panel) {
        [self buildPanel];
    }

    self.panel.hidden = !self.panel.hidden;

    [self refreshStatus];
}

- (UIButton *)button:(NSString *)title
              action:(SEL)sel
                   y:(CGFloat)y {

    UIButton *b =
        [UIButton buttonWithType:UIButtonTypeSystem];

    b.frame = CGRectMake(14, y, 152, 40);

    b.layer.cornerRadius = 10;

    b.backgroundColor =
        [UIColor colorWithWhite:0.12 alpha:0.96];

    [b setTitle:title
        forState:UIControlStateNormal];

    [b setTitleColor:UIColor.whiteColor
            forState:UIControlStateNormal];

    b.titleLabel.font =
        [UIFont boldSystemFontOfSize:13];

    [b addTarget:self
          action:sel
        forControlEvents:UIControlEventTouchUpInside];

    return b;
}

- (void)buildPanel {

    UIView *p =
        [[UIView alloc] initWithFrame:
            CGRectMake(84, 90, 350, 430)];

    p.backgroundColor =
        [UIColor colorWithWhite:0.035 alpha:0.97];

    p.layer.cornerRadius = 18;

    p.layer.borderWidth = 1;

    p.layer.borderColor =
        [UIColor colorWithWhite:0.7 alpha:0.35].CGColor;

    UILabel *h =
        [[UILabel alloc]
            initWithFrame:CGRectMake(16, 10, 310, 34)];

    h.text = @"HALANQI  •  REAL MENU v2";

    h.textColor = UIColor.whiteColor;

    h.font =
        [UIFont boldSystemFontOfSize:17];

    [p addSubview:h];

    NSArray *items = @[
        @[@"Zoom", @"doZoom"],
        @[@"Split", @"doSplit"],
        @[@"Feed", @"doFeed"],
        @[@"Macro", @"doMacro"],
        @[@"Double Split", @"doDouble"],
        @[@"Triple Split", @"doTriple"],
        @[@"Master Split", @"doMaster"],
        @[@"Line Split", @"doLine"]
    ];

    CGFloat y = 55;

    for (NSArray *it in items) {

        SEL s =
            NSSelectorFromString(it[1]);

        UIButton *b =
            [self button:it[0]
                  action:s
                       y:y];

        [p addSubview:b];

        y += 45;

        if (y > 410) {
            break;
        }
    }

    self.status =
        [[UILabel alloc]
            initWithFrame:CGRectMake(180, 58, 155, 300)];

    self.status.numberOfLines = 0;

    self.status.font =
        [UIFont systemFontOfSize:11];

    self.status.textColor =
        [UIColor colorWithWhite:0.85 alpha:1];

    [p addSubview:self.status];

    UIButton *close =
        [self button:@"Close"
              action:@selector(toggle)
                   y:370];

    close.frame =
        CGRectMake(180, 370, 155, 40);

    [p addSubview:close];

    [self.window addSubview:p];

    self.panel = p;

    [self refreshStatus];
}

- (void)refreshStatus {

    self.status.text =
        [NSString stringWithFormat:
            @"Runtime capture\n\n"
             "%@\n\n"
             "Verified direct calls:\n"
             "• BaseArenaView → zoom\n"
             "• ControlsWidget → splitPlayer\n"
             "• ControlsWidget → shootMass\n\n"
             "Other compound actions remain gated "
             "until their runtime ABI is verified.\n\n"
             "Bots: EXCLUDED",
            [[HalanqiGameBridge shared] runtimeStatus]];
}

- (void)notify:(NSString *)msg {

    self.status.text =
        [NSString stringWithFormat:
            @"%@\n\n%@",
            msg,
            [[HalanqiGameBridge shared] runtimeStatus]];
}

- (void)doZoom {

    BOOL ok =
        [[HalanqiGameBridge shared]
            invokeZeroArg:@"zoom"
            onClassNamed:@"BaseArenaView"];

    [self notify:
        ok
        ? @"Zoom: invoked on live BaseArenaView"
        : @"Zoom: waiting for live BaseArenaView"];
}

- (void)doSplit {

    BOOL ok =
        [[HalanqiGameBridge shared]
            invokeZeroArg:@"splitPlayer"
            onClassNamed:@"ControlsWidget"];

    [self notify:
        ok
        ? @"Split: invoked on live ControlsWidget"
        : @"Split: waiting for live ControlsWidget"];
}

- (void)doFeed {

    BOOL ok =
        [[HalanqiGameBridge shared]
            invokeZeroArg:@"shootMass"
            onClassNamed:@"ControlsWidget"];

    [self notify:
        ok
        ? @"Feed: invoked on live ControlsWidget"
        : @"Feed: waiting for live ControlsWidget"];
}

- (void)doMacro {
    [self notify:
        @"Macro: runtime ABI not yet verified — gated safely"];
}

- (void)doDouble {
    [self notify:
        @"Double Split: composite action gated until runtime ABI is verified"];
}

- (void)doTriple {
    [self notify:
        @"Triple Split: composite action gated until runtime ABI is verified"];
}

- (void)doMaster {
    [self notify:
        @"Master Split: composite action gated until runtime ABI is verified"];
}

- (void)doLine {
    [self notify:
        @"Line Split: composite action gated until runtime ABI is verified"];
}

@end
