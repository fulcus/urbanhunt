import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // TODO: Replace this with an API key that has Google Maps for iOS enabled
    // See https://developers.google.com/maps/documentation/ios-sdk/get-api-key
    GMSServices.provideAPIKey("AIzaSyDkWviZPvlGK-a4JYFBTR8FDF-qa5rVvWQ")
    GeneratedPluginRegistrant.register(with: self)
    //FirebaseApp.configure() // found in firebase sdk setup
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
