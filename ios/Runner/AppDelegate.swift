import Flutter
import UIKit

/// Flutter 在 iOS 上的应用入口；隐式引擎初始化后再注册插件与 Pigeon HostApi。
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Scene 切到隐式引擎后注册插件与 HostApi，避免 Dart 首帧调用时通道未就绪。
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    AppPlatformHostApiSetup.setUp(
      binaryMessenger: engineBridge.applicationRegistrar.messenger(),
      api: PlatformHostApiHandler()
    )
  }
}

/// `AppPlatformHostApi` 的 iOS 实现，系统版本直接读 `UIDevice`。
private final class PlatformHostApiHandler: AppPlatformHostApi {
  func getPlatformVersion() throws -> String? {
    "iOS \(UIDevice.current.systemVersion)"
  }
}
