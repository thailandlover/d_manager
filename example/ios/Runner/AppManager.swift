import Foundation
import CoreData
import d_manager

class AppManager : AppManagerDelegate {
    func getPersistentContainer() -> NSPersistentContainer {
        return persistentContainer
    }
    
    private let bundleId = "org.cocoapods.d-manager"
    private let cacheResource = "AppModel"
    private let resourceExtension = "momd"
    
    lazy var objectModel: NSManagedObjectModel = {
        let appKitBundle = Bundle(identifier: bundleId)
        let modelURL = appKitBundle!.url(forResource: cacheResource, withExtension: resourceExtension)!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: resourceExtension, managedObjectModel: objectModel)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("error \(error)")
            }
        })
        return container
    }()
}
