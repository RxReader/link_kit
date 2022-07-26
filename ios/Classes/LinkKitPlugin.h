#import <Flutter/Flutter.h>

@interface LinkKitPlugin : NSObject<FlutterPlugin>
@end

@interface LinkKitLinkClickEventHandler : NSObject<FlutterStreamHandler>

- (void)addEvent: (NSString *)event;

@end
