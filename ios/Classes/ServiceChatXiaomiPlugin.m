#import "ServiceChatXiaomiPlugin.h"
#if __has_include(<service_chat_xiaomi/service_chat_xiaomi-Swift.h>)
#import <service_chat_xiaomi/service_chat_xiaomi-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "service_chat_xiaomi-Swift.h"
#endif

@implementation ServiceChatXiaomiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftServiceChatXiaomiPlugin registerWithRegistrar:registrar];
}
@end
