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
    if call.method == "Crashlytics#setApiKey", let arguments = call.arguments as? NSDictionary {
      guard let apiKey = arguments["api_key"] as? String else {
        result(FlutterError(code: "api_key problem", message: nil, details: nil))
        return
      }
      let config = BugsnagConfiguration();
      config.apiKey = apiKey;
      if let releaseStage = arguments["releaseStage"] as? String {
       config.releaseStage = releaseStage
      }
      if let appVersion = arguments["appVersion"] as? String {
       config.appVersion = appVersion
      }
      Bugsnag.start(with: config)
      bugsnagStarted = true
      result(nil)
    } else if (call.method == "Crashlytics#report") {
        if (bugsnagStarted) {
            let arguments = call.arguments as? NSDictionary
            let info = arguments!["information"] as? String
            
            let exception = NSException(name:NSExceptionName(rawValue: "Bugsnag Exception"), reason: info)
            Bugsnag.notify(exception)
        }
        else {
            result(FlutterError(code: "Bugsnag not started", message: nil, details: nil))
        }
    }
    else {
        result(FlutterMethodNotImplemented)
    }
  }
}
