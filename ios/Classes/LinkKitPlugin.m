#import "LinkKitPlugin.h"

@implementation LinkKitPlugin {
    BOOL _isRunning;
    BOOL _handleInitialFlag;
    LinkKitLinkClickEventHandler *_linkClickEventHandler;
    NSString *_initialLink;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterEventChannel *linkClickEventChannel = [FlutterEventChannel eventChannelWithName:@"v7lin.github.io/link_kit#click_event" binaryMessenger:[registrar messenger]];
    LinkKitLinkClickEventHandler *linkClickEventHandler = [[LinkKitLinkClickEventHandler alloc] init];
    [linkClickEventChannel setStreamHandler:linkClickEventHandler];
    FlutterMethodChannel *channel = [FlutterMethodChannel
        methodChannelWithName:@"v7lin.github.io/link_kit"
              binaryMessenger:[registrar messenger]];
    LinkKitPlugin *instance = [[LinkKitPlugin alloc] initWithLinkClickEventHandler:linkClickEventHandler];
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithLinkClickEventHandler:(LinkKitLinkClickEventHandler *)linkClickEventHandler {
    self = [super init];
    if (self) {
        _isRunning = NO;
        _handleInitialFlag = NO;
        _linkClickEventHandler = linkClickEventHandler;
        _initialLink = nil;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"getInitialLink" isEqualToString:call.method]) {
        if (!_handleInitialFlag) {
            _handleInitialFlag = YES;
            _isRunning = YES;
            result(_initialLink);
        } else {
            result([FlutterError errorWithCode:@"FAILED" message:nil details:nil]);
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (BOOL)isFLKDeepLink:(NSURL *)url {
    NSArray *schemes = @[ LINK_KIT_DEEP_LINK_SCHEME ];
    for (NSString *scheme in schemes) {
        if ([scheme isEqualToString:url.scheme]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSURL *url = (NSURL *)launchOptions[UIApplicationLaunchOptionsURLKey];
    if (url != nil && url != NULL && ![url isEqual:[NSNull null]]) {
        if ([self isFLKDeepLink:url]) {
            _initialLink = url.absoluteString;
            return YES;
        }
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self handleDeepLinkClickEvent:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return [self handleDeepLinkClickEvent:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self handleDeepLinkClickEvent:url];
}

- (BOOL)handleDeepLinkClickEvent:(NSURL *)url {
    if (url != nil && url != NULL && ![url isEqual:[NSNull null]]) {
        if ([self isFLKDeepLink:url]) {
            if (_linkClickEventHandler != nil) {
                [_linkClickEventHandler addEvent:url.absoluteString];
            }
            return YES;
        }
    }
    return NO;
}

#ifdef LINK_KIT_UNIVERSAL_LINK

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *_Nonnull))restorationHandler {
    return [self handleUniversalLinkClickEvent:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

- (BOOL)handleUniversalLinkClickEvent:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *_Nonnull))restorationHandler {
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;
        if ([self isFLKUniversalLink:url]) {
            if (!_isRunning) {
                _initialLink = url.absoluteString;
            } else {
                if (_linkClickEventHandler != nil) {
                    [_linkClickEventHandler addEvent:url.absoluteString];
                }
            }
            return YES;
        }
    }
    return NO;
}

- (BOOL)isFLKUniversalLink:(NSURL *)url {
    NSURL *universalLink = [NSURL URLWithString:LINK_KIT_UNIVERSAL_LINK];
    if ([url.absoluteString hasPrefix:universalLink.absoluteString]) {
        return YES;
    }
    return NO;
}

#endif

@end

@implementation LinkKitLinkClickEventHandler {
    FlutterEventSink _events;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    if (_events != nil) {
        return nil;
    }
    _events = events;
    return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
    if (_events == nil) {
        return nil;
    }
    _events = nil;
    return nil;
}

- (void)addEvent:(NSString *)event {
    if (_events != nil) {
        _events(event);
    }
}

@end
