package mod.flutter.plugins.bugsnag.crashlytics.bugsnag_crashlytics

import android.content.Context
import androidx.annotation.NonNull
import com.bugsnag.android.Bugsnag
import com.bugsnag.android.Configuration

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.lang.Exception

/** BugsnagCrashlyticsPlugin */
class BugsnagCrashlyticsPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var context : Context
  private var bugsnagStarted = false

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext

    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "bugsnag_crashlytics")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "Crashlytics#setApiKey") {

      val apiKey = call.argument<String>("api_key")
      if(apiKey != null) {
        val config = Configuration.load(context)
        config.apiKey = apiKey
        val appVersion = call.argument<String>("appVersion")
        if(appVersion != null) {
          config.appVersion = appVersion
        }
        val releaseStage = call.argument<String>("releaseStage")
        if(releaseStage != null) {
          config.releaseStage = releaseStage
        }
        Bugsnag.start(context, config)
        bugsnagStarted = true

        result.success(null);
      }
      else {
        result.error("api_key problem", null, null);
      }

    } else if (call.method == "Crashlytics#report") {
      if(bugsnagStarted) {
        Bugsnag.notify(Exception(call.argument<String>("information")))
      }
      else {
        result.error("Bugsnag not started", null, null)
      }
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
