# bugsnag_crashlytics plugin

A Flutter plugin to use the [Bugsnag Crashlytics Service](https://docs.bugsnag.com/).

## Usage


### Use the plugin

Add the following imports to your Dart code:
```dart
import 'package:bugsnag_crashlytics/bugsnag_crashlytics.dart';
```

Setup `Crashlytics`:
```dart
void main() {
  
  // pass your key api of bugsnag to the plugin to setup
  BugsnagCrashlytics.instance.register('API_KEY');
  
  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = BugsnagCrashlytics.instance.recordFlutterError;
  
  runApp(MyApp());
}
```

Overriding `FlutterError.onError` with `BugsnagCrashlytics.instance.recordFlutterError`  will automatically catch all 
errors that are thrown from within the Flutter framework.  
If you want to catch errors that occur in `runZoned`, 
you can supply `BugsnagCrashlytics.instance.recordError` to the `onError` parameter:
```dart
runZoned<Future<void>>(() async {
    // ...
  }, onError: BugsnagCrashlytics.instance.recordError);
```

## Result

If an error is caught, you should see the following messages in your logs:
```
flutter: Flutter error caught by Crashlytics plugin:
// OR if you use recordError for runZoned:
flutter: Error caught by Crashlytics plugin <recordError>:
// Exception, context, information, and stack trace in debug mode
// OR if not in debug mode:
flutter: Error reported to Crashlytics.
```

*Note:* It may take awhile (up to 24 hours) before you will be able to see the logs appear in your Bugsnag console.


