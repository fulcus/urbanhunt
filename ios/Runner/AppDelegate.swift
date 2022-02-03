import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
        let nsDictionary = NSDictionary(contentsOfFile: path)

        if let apiKey = nsDictionary?["API_KEY"] as? String {
            print("AppDelegate: API_KEY found")
            GMSServices.provideAPIKey(apiKey)
        }

    // TODO: Replace this with an API key that has Google Maps for iOS enabled
    // See https://developers.google.com/maps/documentation/ios-sdk/get-api-key
    GMSServices.provideAPIKey(apiKey)
    GeneratedPluginRegistrant.register(with: self)
    //FirebaseApp.configure() // found in firebase sdk setup
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
