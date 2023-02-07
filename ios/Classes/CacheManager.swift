import UIKit
import Alamofire
import CoreData

extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
}

extension String{
    var url: URL? {
        get{
            return URL(string: self)
        }
    }
    
    var localURL: URL? {
        get{
            guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil}
            return documentsURL.appendingPathComponent(self)
        }
    }
}

class CacheManager: NSObject {
    
    enum DownloadStatus: String {
        case active, failed, completed, paused, stoped
    }
    
    private let queue = OperationQueue()
    
    private var downloadRequestes = [String:DownloadRequest]()
    private var cache = NSCache<NSString, NSData>()
    
    
    class var shared: CacheManager{
        struct Static{
            static let instance = CacheManager()
        }
        return Static.instance
    }
    
    private lazy var backgroundManager: Alamofire.SessionManager = {
        let bundleIdentifier = "org.cocoapods.d-manager"
        return Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: bundleIdentifier + ".background"))
    }()
    
    var backgroundCompletionHandler: (() -> Void)? {
        get {
            return backgroundManager.backgroundCompletionHandler
        }
        set {
            backgroundManager.backgroundCompletionHandler = newValue
        }
    }
    
    func setupDownloadQueue(){
        queue.maxConcurrentOperationCount = 1
    }
    
    func checkDownloadCount(id: String) {
        print("Download Queue Count is : \(queue.operationCount)")
    }
    
    func download(id: String, url: String,fileName: String? = nil, whereToSave: String){
        let appDelegate = SwiftDManagerPlugin.shared!
        guard let context = appDelegate.getAppDelegateContext()  else {return}
        
        let download = Download(context: context)
        if let url = URL(string: url){
            download.title = fileName ?? UUID.init().uuidString
            download.id = id
            download.url = url.absoluteString
            download.createdAt = Date()
            appDelegate.saveContext()
            let operation = BlockOperation(block: {
                DispatchQueue.main.async {
                    self.startDownload(download, whereToSave: whereToSave)
                }
            })
            queue.addOperation(operation)
            if queue.operationCount > 1{
                operation.addDependency(queue.operations[queue.operationCount - 2])
            }
        } else {
            // TODO callback to flutter with invalide url error
        }
    }
    
    func downloadItemDetails(id: String) -> [String: Any?]?{
        return generateJsonFromDownload(getDownloadItem(id: id))
    }
    
    func allItems() -> [[String: Any?]]? {
        let appDelegate = SwiftDManagerPlugin.shared!
        guard let context = SwiftDManagerPlugin.shared.getAppDelegateContext()  else { return nil}
        let fetchRequest = NSFetchRequest<Download>(entityName: Configs.CoreData.downloadEntityName)
        let sort = NSSortDescriptor(key: #keyPath(Download.createdAt), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        var results = [[String: Any?]]()
        do{
            let downloads = try context.fetch(fetchRequest)
            for download in downloads{
                guard let downloadJsonData = generateJsonFromDownload(download) else { continue }
                results.append(downloadJsonData)
            }
            return results
        } catch {
            print("Could get downloads with error  \(error)")
            return nil
        }
    }
    
    func allDownloadItems() -> [Download]?{
        let appDelegate = SwiftDManagerPlugin.shared!
        guard let context = appDelegate.getAppDelegateContext()  else { return nil}
        let fetchRequest = NSFetchRequest<Download>(entityName: Configs.CoreData.downloadEntityName)
        let sort = NSSortDescriptor(key: #keyPath(Download.createdAt), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        var results = [Download]()
        do{
            let downloads = try context.fetch(fetchRequest)
            for download in downloads{
                results.append(download)
            }
            return results
        }catch{
            // TODO callback to flutter with error
            print("could get downloads with error  \(error)")
            return nil
        }
    }
    
    func pause(id: String){
        let appDelegate = SwiftDManagerPlugin.shared!
        if let download = getDownloadItem(id: id){
            if let downloadRequest = downloadRequestes[id]{
                if let resumeData = downloadRequest.resumeData{
                    self.cache.setObject(resumeData as NSData, forKey: id as NSString)
                    download.status = DownloadStatus.paused.rawValue
                    downloadRequest.suspend()
                }else{
                    print("No Resume")
                    // TODO callback to flutter with error no resume data, download will start from the begining when resumed
                }
                download.status = DownloadStatus.paused.rawValue
                downloadRequest.suspend()
            }else{
                print("No Resume")
                download.status = DownloadStatus.paused.rawValue
                appDelegate.saveContext()
                // TODO callback to flutter with error no download request found cannt pause
            }
        }else{
            print("Not Found")
            // TODO callback to flutter with error no download found
        }
        appDelegate.saveContext()
    }
    
    func resume(id: String, pathExtension: String? = nil, whereToSave: String){
        let appDelegate = SwiftDManagerPlugin.shared!
        if let download = getDownloadItem(id: id){
            if let downloadRequeste = downloadRequestes[id]{
                downloadRequeste.resume()
                download.status = DownloadStatus.active.rawValue
                appDelegate.saveContext()
            }else{
                if let resumeData = cache.object(forKey: id as NSString){
                    resumeDownload(download, resumeData: resumeData as Data, whereToSave: whereToSave)
                }else{
                    startDownload(download, whereToSave: whereToSave)
                    // TODO callback to flutter with error no resume data retry please
                }
            }
        }else{
            // TODO callback to flutter with error no download found
        }
    }
    
    func stop (id: String){
        let appDelegate = SwiftDManagerPlugin.shared!
        if let download = getDownloadItem(id: id){
            if let downloadRequest = downloadRequestes[id]{
                print("Enter stopped success")
                download.status = DownloadStatus.stoped.rawValue
                appDelegate.saveContext()
                downloadRequest.cancel()
            }else{
                print("Enter stopped not found")
                download.status = DownloadStatus.stoped.rawValue
                appDelegate.saveContext()
                // TODO callback to flutter with error no download request found cannt pause
            }
        }else{
            print("Enter stopped error")
            // TODO callback to flutter with error no download found
        }
        appDelegate.saveContext()
    }
    
    func retry (id: String, pathExtension: String? = nil, whereToSave: String){
        if let download = getDownloadItem(id: id){
            startDownload(download, whereToSave: whereToSave)
        }else{
            // TODO callback to flutter with error no download found
        }
    }
    
    
    func delete (id: String){
        let appDelegate = SwiftDManagerPlugin.shared!
        if let download = getDownloadItem(id: id){
            guard let context = appDelegate.getAppDelegateContext()  else { return }
            context.delete(download)
            appDelegate.saveContext()
        }else{
            print("TODO callback to flutter with error no download found")
            // TODO callback to flutter with error no download found
        }
    }
    
    
    private func startDownload(_ download: Download, whereToSave: String){
        print("whereToSave", whereToSave)
        let appDelegate = SwiftDManagerPlugin.shared!
        let destination: DownloadRequest.DownloadFileDestination = { temporaryURL, _ in
            _ = URL.createFolder(folderName: whereToSave)!
            let fileName: String
            fileName = whereToSave + "/" + (download.title ?? UUID.init().uuidString)
            print("file path is \(fileName)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                download.localFile = fileName
                download.status = DownloadStatus.completed.rawValue
                appDelegate.saveContext()
            }
            return (fileName.localURL!, [.removePreviousFile])
        }
        download.status = DownloadStatus.active.rawValue
        appDelegate.saveContext()
        let downloadRequest = backgroundManager.download(download.url!, to: destination).downloadProgress { (progress) in
            download.progress = progress.fractionCompleted
            appDelegate.saveContext()
        }.response {(response) in
            if let error = response.error{
                print("DownloadError",error)
                if let resumeData = response.resumeData {
                    download.status = DownloadStatus.stoped.rawValue
                    self.cache.setObject(resumeData as NSData, forKey: download.id! as NSString)
                    appDelegate.saveContext()
                } else {
                    download.status = DownloadStatus.failed.rawValue
                    appDelegate.saveContext()
                }
            } else {
                print("DownloadError","OK")
            }
        }
        downloadRequestes[download.id!] = downloadRequest
    }
    
    private func resumeDownload(_ download: Download, resumeData: Data, whereToSave: String){
        let appDelegate = SwiftDManagerPlugin.shared!
        
        let destination: DownloadRequest.DownloadFileDestination = { temporaryURL, _ in
            _ = URL.createFolder(folderName: whereToSave)!
            let fileName: String
            fileName = whereToSave + "/" + (download.title ?? UUID.init().uuidString)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                download.localFile = fileName
                download.status = DownloadStatus.completed.rawValue
                appDelegate.saveContext()
            }
            return (fileName.localURL!, [.removePreviousFile])
        }
        download.status = DownloadStatus.active.rawValue
        appDelegate.saveContext()
        let downloadRequest = backgroundManager.download(resumingWith: resumeData, to: destination)
            .downloadProgress { (progress) in
                download.progress = progress.fractionCompleted
                appDelegate.saveContext()
            }.response {(response) in
                if let error = response.error{
                    print("Error in resuming");
                    print(error)
                    if let resumeData = response.resumeData {
                        download.status = DownloadStatus.paused.rawValue
                        self.cache.setObject(resumeData as NSData, forKey: download.id! as NSString)
                        appDelegate.saveContext()
                    }else{
                        download.status = DownloadStatus.failed.rawValue
                        appDelegate.saveContext()
                    }
                }else{
                    print("Error with delete")
                    download.status = DownloadStatus.failed.rawValue
                    appDelegate.saveContext()
                    // TODO callback to flutter with response.error
                    //self.delete(id: download.id!)
                }
            }
        downloadRequestes[download.id!] = downloadRequest
    }
    
    
    
    private func generateJsonFromDownload(_ download: Download?) -> [String: Any?]?{
        guard let download = download else { return nil}
        return ["id": download.id, "title": download.title, "url": download.url, "progress": download.progress,"status": download.status]
    }
    
    func getDownloadItem(id: String) -> Download?{
        let appDelegate = SwiftDManagerPlugin.shared!
        guard let context = appDelegate.getAppDelegateContext()  else { return nil}
        let fetchRequest = NSFetchRequest<Download>(entityName: Configs.CoreData.downloadEntityName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        do{
            return try context.fetch(fetchRequest).first
        }catch{
            // TODO callback to flutter with error
            print("could get downloads with error  \(error)")
            return nil
        }
    }
}
