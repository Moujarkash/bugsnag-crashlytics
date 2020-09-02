import Flutter
import UIKit
import Bugsnag

public class SwiftBugsnagCrashlyticsPlugin: NSObject, FlutterPlugin {
    var bugsnagStarted = false
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "bugsnag_crashlytics", binaryMessenger: registrar.messenger())
    let instance = SwiftBugsnagCrashlyticsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "Crashlytics#setApiKey") {
        let arguments = call.arguments as? NSDictionary
        let apiKey = arguments!["api_key"] as? String
        if (apiKey != nil) {
            let config = BugsnagConfiguration()
            config.apiKey = apiKey;
            Bugsnag.start(with: config)
            bugsnagStarted = true
      }
    } else if (call.method == "Crashlytics#report") {
        if (bugsnagStarted) {
            let arguments = call.arguments as? NSDictionary
            let info = arguments!["information"] as? String
            
            let exception = NSException(name:NSExceptionName(rawValue: "Bugsnag Exception"), reason: info)
            Bugsnag.notify(exception)
        }
    }
  }
}
