import UIKit
import Flutter
import Foundation
import CoreData
import d_manager


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, SwiftDManagerPluginDelegate {
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

    lazy var managedObjectModel: NSManagedObjectModel = {
        let appKitBundle = Bundle(identifier: "org.cocoapods.d-manager")

        let modelURL = appKitBundle!.url(forResource: "Cache", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Cache", managedObjectModel: managedObjectModel)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func getContext() -> NSManagedObjectContext? {
        return self.persistentContainer.viewContext
    }
}
