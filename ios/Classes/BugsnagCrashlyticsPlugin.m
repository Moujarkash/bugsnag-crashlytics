#import "BugsnagCrashlyticsPlugin.h"
#if __has_include(<bugsnag_crashlytics/bugsnag_crashlytics-Swift.h>)
#import <bugsnag_crashlytics/bugsnag_crashlytics-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "bugsnag_crashlytics-Swift.h"
#endif

@implementation BugsnagCrashlyticsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBugsnagCrashlyticsPlugin registerWithRegistrar:registrar];
}
@end
