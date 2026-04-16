import Flutter
import UIKit
import GoogleMaps
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAQY1SQeZwn5Z5EPgryh4j_M_SKadyoRBo")

    // Firebase is initialised by the Flutter firebase_core plugin via
    // the GoogleService-Info.plist — FirebaseApp.configure() is called by
    // GeneratedPluginRegistrant. No manual call needed here.

    // FCM delegate
    Messaging.messaging().delegate = self

    // Request notification permission
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .badge, .sound]
    ) { _, _ in }
    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// MARK: – MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    // Token is available; the Flutter firebase_messaging plugin surfaces this
    // to Dart via FirebaseMessaging.instance.getToken() — no extra work needed.
  }
}
