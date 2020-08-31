import Flutter
import UIKit

public class SwiftBugsnagCrashlyticsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "bugsnag_crashlytics", binaryMessenger: registrar.messenger())
    let instance = SwiftBugsnagCrashlyticsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
