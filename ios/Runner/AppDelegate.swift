import Flutter
import GoogleMaps
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !mapsApiKey.isEmpty {
      GMSServices.provideAPIKey(mapsApiKey)
    }

    // Call super first so FlutterAppDelegate can wire plugin proxies, then
    // register for APNs so FCM can obtain a token for background/terminated pushes.
    let ok = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()
    return ok
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Forward to FlutterAppDelegate / Firebase swizzling.
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    let hex = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    NSLog("[Aajhee] APNs device token registered (%lu bytes): %@…",
          UInt(deviceToken.count), String(hex.prefix(16)))
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    NSLog("[Aajhee] APNs registration FAILED: %@", error.localizedDescription)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Dart print() is easy to miss in release device consoles; mirror push
    // diagnostics to NSLog so `devicectl … --console` and Xcode show them.
    let channel = FlutterMethodChannel(
      name: "aajhee/push_debug",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "log", let message = call.arguments as? String {
        NSLog("%@", message)
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
