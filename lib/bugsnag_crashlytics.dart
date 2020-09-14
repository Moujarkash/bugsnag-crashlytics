import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stack_trace/stack_trace.dart';

class BugsnagCrashlytics {
  static final BugsnagCrashlytics instance = BugsnagCrashlytics();

  static const MethodChannel _channel =
      const MethodChannel('bugsnag_crashlytics');

  Future<void> register(
    String androidApiKey,
    String iosApiKey, {
    String releaseStage,
    String appVersion,
    bool persistUser,
  }) async {
    var apiKey;

    if (Platform.isIOS)
      apiKey = iosApiKey;
    else if (Platform.isAndroid)
      apiKey = androidApiKey;
    else
      throw Exception("Not supported platform");

    final config = <String, dynamic>{'api_key': apiKey};
    addIfNotNull(String fieldName, dynamic value) {
      if (value != null) config.putIfAbsent(fieldName, () => value);
    }

    addIfNotNull('releaseStage', releaseStage);
    addIfNotNull('appVersion', appVersion);

    addIfNotNull('persistUser', persistUser);

    await _channel.invokeMethod('Crashlytics#setApiKey', config);
  }

  Future<void> addUserData({
    String userId,
    String userEmail,
    String userName,
  }) async {
    HashMap userData = HashMap<String, String>();

    userData.putIfAbsent('user_id', () => userId);
    userData.putIfAbsent('user_email', () => userEmail);
    userData.putIfAbsent('user_name', () => userName);

    await _channel.invokeMethod('Crashlytics#setUserData', userData);
  }

  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    print('Flutter error caught by Crashlytics plugin:');
    // Since multiple errors can be caught during a single session, we set
    // forceReport=true.
    FlutterError.dumpErrorToConsole(details, forceReport: true);

    _recordError(details.exceptionAsString(), details.stack,
        context: details.context,
        information: details.informationCollector == null
            ? null
            : details.informationCollector());
  }

  Future<void> _recordError(dynamic exception, StackTrace stack,
      {dynamic context, Iterable<DiagnosticsNode> information}) async {
    final String _information = (information == null || information.isEmpty)
        ? ''
        : (StringBuffer()..writeAll(information, '\n')).toString();

    // If available, give context to the exception.
    if (context != null) print('The following exception was thrown $context:');

    // Need to print the exception to explain why the exception was thrown.
    print(exception);

    // Print information provided by the Flutter framework about the exception.
    if (_information.isNotEmpty) print('\n$_information');

    // Not using Trace.format here to stick to the default stack trace format
    // that Flutter developers are used to seeing.
    if (stack != null) print('\n$stack');

    // The stack trace can be null. To avoid the following exception:
    // Invalid argument(s): Cannot create a Trace from null.
    // We can check for null and provide an empty stack trace.
    stack ??= StackTrace.current ?? StackTrace.fromString('');

    // Report error.
    final List<String> stackTraceLines =
        Trace.format(stack).trimRight().split('\n');
    final List<Map<String, String>> stackTraceElements =
        getStackTraceElements(stackTraceLines);

    // The context is a string that "should be in a form that will make sense in
    // English when following the word 'thrown'" according to the documentation for
    // [FlutterErrorDetails.context]. It is displayed to the user on Crashlytics
    // as the "reason", which is forced by iOS, with the "thrown" prefix added.
    final String result = await _channel
        .invokeMethod<String>('Crashlytics#report', <String, dynamic>{
      'exception': "${exception.toString()}",
      'context': '$context',
      'information': _information,
      'stackTraceElements': stackTraceElements
    });

    // Print result.
    print('bugsnag_crashlytics: $result');
  }

  Future<void> recordError(dynamic exception, StackTrace stack,
      {dynamic context}) async {
    print('Error caught by Crashlytics plugin <recordError>:');

    _recordError(exception, stack, context: context);
  }

  List<Map<String, String>> getStackTraceElements(List<String> lines) {
    final List<Map<String, String>> elements = <Map<String, String>>[];
    for (String line in lines) {
      final List<String> lineParts = line.split(RegExp('\\s+'));
      try {
        final String fileName = lineParts[0];
        final String lineNumber = lineParts[1].contains(":")
            ? lineParts[1].substring(0, lineParts[1].indexOf(":")).trim()
            : lineParts[1];

        final Map<String, String> element = <String, String>{
          'file': fileName,
          'line': lineNumber,
        };

        // The next section would throw an exception in some cases if there was no stop here.
        if (lineParts.length < 3) {
          elements.add(element);
          continue;
        }

        if (lineParts[2].contains(".")) {
          final String className =
              lineParts[2].substring(0, lineParts[2].indexOf(".")).trim();
          final String methodName =
              lineParts[2].substring(lineParts[2].indexOf(".") + 1).trim();

          element['class'] = className;
          element['method'] = methodName;
        } else {
          element['method'] = lineParts[2];
        }

        elements.add(element);
      } catch (e) {
        print(e.toString());
      }
    }
    return elements;
  }
}
