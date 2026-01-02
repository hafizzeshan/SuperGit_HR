import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
        // GMSServices.provideAPIKey("AIzaSyDt_ZObtNis4synWYHW4n8s_7FOj3RjEYI")
        // GMSServices.provideAPIKey("AIzaSyA_y2gPOwCncoKN-MMK2zigootcYNpWZcg")
        GMSServices.provideAPIKey("AIzaSyC2iouyORolERruvkX8jyXeHWIGgYr9vPQ")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
