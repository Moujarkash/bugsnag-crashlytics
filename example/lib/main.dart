import 'package:flutter/material.dart';
import 'dart:async';

import 'package:bugsnag_crashlytics/bugsnag_crashlytics.dart';

void main() {
  BugsnagCrashlytics.instance.register('API_KEY');

  FlutterError.onError = BugsnagCrashlytics.instance.recordFlutterError;

  runZoned(() {
    runApp(MyApp());
  }, onError: BugsnagCrashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Hello Bugsnag"),);
  }
}

