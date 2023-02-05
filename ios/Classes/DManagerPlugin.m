#import "DManagerPlugin.h"
#if __has_include(<d_manager/d_manager-Swift.h>)
#import <d_manager/d_manager-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "d_manager-Swift.h"
#endif

@implementation DManagerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDManagerPlugin registerWithRegistrar:registrar];
}
@end
