import UIKit
import Flutter
import Foundation
import CoreData
import d_manager


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, SwiftDManagerPluginDelegate {

    private let appManager = AppManager()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        SwiftDManagerPlugin.shared.initiate()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        SwiftDManagerPlugin.shared.clearAll()
    }
    
    func getAppManager() -> AppManagerDelegate {
        return appManager
    }
}
