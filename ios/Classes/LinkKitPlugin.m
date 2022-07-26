#import "LinkKitPlugin.h"

@implementation LinkKitPlugin {
    LinkKitLinkClickEventHandler *_linkClickEventHandler;
    NSString *_initialLink;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
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
        _linkClickEventHandler = linkClickEventHandler;
        _initialLink = nil;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getInitialLink" isEqualToString:call.method]) {
        result(_initialLink);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (NSString *)getFLKURLScheme {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSArray *types = [infoDic objectForKey:@"CFBundleURLTypes"];
    for (NSDictionary *type in types) {
        if ([@"flk" isEqualToString:[type objectForKey:@"CFBundleURLName"]]) {
            NSString *scheme = [type objectForKey:@"CFBundleURLSchemes"][0];
            if (scheme != nil && scheme != NULL && ![scheme isKindOfClass:[NSNull class]] && scheme.length > 0) {
                return scheme;
            }
        }
    }
    @throw [[NSException alloc] initWithName:@"UnsupportedError" reason:@"未配置 flk scheme" userInfo:nil];
}

- (BOOL) isFLKURL:(NSURL *) url {
    NSString *scheme = [self getFLKURLScheme];
    return [scheme isEqualToString:url.scheme];
}

#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSURL *url = (NSURL *)launchOptions[UIApplicationLaunchOptionsURLKey];
    if (url != nil && url != NULL && ![url isEqual:[NSNull null]]) {
        if ([self isFLKURL:url]) {
            _initialLink = url.absoluteString;
            return YES;
        }
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self handleLinkClickEvent:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [self handleLinkClickEvent:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self handleLinkClickEvent:url];
}

- (BOOL)handleLinkClickEvent:(NSURL *)url {
    if (url != nil && url != NULL && ![url isEqual:[NSNull null]]) {
        if ([self isFLKURL:url]) {
            if (_linkClickEventHandler != nil) {
                [_linkClickEventHandler addEvent:url.absoluteString];
            }
            return YES;
        }
    }
    return NO;
}

@end

@implementation LinkKitLinkClickEventHandler {
    FlutterEventSink _events;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    if (_events != nil) {
        return nil;
    }
    _events = events;
    return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    if (_events == nil) {
        return nil;
    }
    _events = nil;
    return nil;
}

- (void)addEvent: (NSString *)event {
    if (_events != nil) {
        _events(event);
    }
}

@end
