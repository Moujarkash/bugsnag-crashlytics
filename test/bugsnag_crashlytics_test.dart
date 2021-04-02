import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bugsnag_crashlytics/bugsnag_crashlytics.dart';

void main() {
  const MethodChannel channel = MethodChannel('bugsnag_crashlytics');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    //expect(await BugsnagCrashlytics.platformVersion, '42');
  });
}
