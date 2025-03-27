#import "BetterVlcPlayerPlugin.h"
#if __has_include(<flutter_better_vlc_player/flutter_better_vlc_player-Swift.h>)
#import <flutter_better_vlc_player/flutter_better_vlc_player-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_better_vlc_player-Swift.h"
#endif

@implementation BetterVlcPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [VlcPlayerPlugin registerWithRegistrar:registrar];
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
}

@end
