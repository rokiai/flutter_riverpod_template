import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    AppPlatformHostApiSetup.setUp(
      binaryMessenger: engineBridge.applicationRegistrar.messenger(),
      api: PlatformHostApiHandler()
    )
  }
}

private final class PlatformHostApiHandler: AppPlatformHostApi {
  func getPlatformVersion() throws -> String? {
    "iOS \(UIDevice.current.systemVersion)"
  }
}
