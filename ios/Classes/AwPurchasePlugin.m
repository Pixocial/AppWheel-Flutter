#import "AwPurchasePlugin.h"
#if __has_include(<aw_purchase/aw_purchase-Swift.h>)
#import <aw_purchase/aw_purchase-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "aw_purchase-Swift.h"
#endif

@implementation AwPurchasePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAwPurchasePlugin registerWithRegistrar:registrar];
}
- (void)init {

}

@end
