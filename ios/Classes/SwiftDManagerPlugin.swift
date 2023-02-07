import Flutter
import UIKit
import CoreData
import AVKit

public class SwiftDManagerPlugin: NSObject, FlutterPlugin {
  public static var shared : SwiftDManagerPlugin!

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "d_manager", binaryMessenger: registrar.messenger())
    let instance = SwiftDManagerPlugin()
    registrar.addApplicationDelegate(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)
    shared = instance
  }


    public func getAppDelegateContext() -> NSManagedObjectContext?{
        let appDelegate = UIApplication.shared.delegate as? SwiftDManagerPluginDelegate
        return appDelegate?.getContext()
    }


    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let controller: UIViewController =
        (UIApplication.shared.delegate?.window??.rootViewController)!;
        switch(call.method){
        case "get_list":
            self.getList(result: result)
            break;
        case "start":
            self.start(result: result, call: call)
            break;
        case "pause":
            self.pause(result: result, call: call)
            break;
        case "resume":
            self.resume(result: result, call: call)
            break;
        case "cancel":
            self.cancel(result: result, call: call)
            break;
        case "delete":
            self.delete(result: result, call: call)
            break;
        case "retry":
            self.retry(result: result, call: call)
            break;
        case "delete_local":
            self.deleteLocal(result: result, call: call)
            break;
        case "open_file":
            self.openFile(result: result, call: call,controller: controller)
            break;
        default:
            print("method wasn't found : ",call.method);
            result("method wasn't found : "+call.method)
        }
    }

    func getList(result: @escaping FlutterResult){
        let allItems = CacheManager.shared.allItems() ?? [[String: Any]]()
        result(self.json(from:allItems as Any))
    }


    func start(result: @escaping FlutterResult,call: FlutterMethodCall){
        guard let args = call.arguments else {
            return
        }
        if let myArgs = args as? [String: Any],
           let id : String = myArgs["id"] as? String,
           let url : String = myArgs["link"] as? String,
           let fileName : String = myArgs["fileName"] as? String,
           let whereToSave : String = myArgs["savedDir"] as? String{
            if self.getActiveCount() <= 5 {
                CacheManager.shared.download(id: id, url: url, fileName: fileName,whereToSave: whereToSave)
                result(true)
            } else {
                result(false)
            }

        } else {
            print("iOS could not extract flutter arguments in method: (startDownload)")
            result(false)
        }
        result(false)
    }


    func pause(result: @escaping FlutterResult,call: FlutterMethodCall){
        guard let args = call.arguments else {
            return
        }
        if let myArgs = args as? [String: Any],
           let id : String = myArgs["id"] as? String
        {
            CacheManager.shared.pause(id: id)
            result(true)
        } else {
            print("iOS could not extract flutter arguments in method: (pauseDownloadItem)")
            result(false)
        }
    }

    func resume(result: @escaping FlutterResult,call: FlutterMethodCall){
        guard let args = call.arguments else {
            return
        }
        if let myArgs = args as? [String: Any],
           let id : String = myArgs["id"] as? String,
           let whereToSave : String = myArgs["savedDir"] as? String{
            if self.getActiveCount() <= 5 {
                CacheManager.shared.resume(id: id,whereToSave: whereToSave)
                result(true)
            } else {
                result(false)
            }

        } else {
            print("iOS could not extract flutter arguments in method: (resumeDownloadItem)")
            result(false)
        }
    }

    func cancel(result: @escaping FlutterResult,call: FlutterMethodCall){
        guard let args = call.arguments else {
            return
        }
        if let myArgs = args as? [String: Any],
           let id : String = myArgs["id"] as? String
        {
            CacheManager.shared.stop(id: id)
            result(true)
        } else {
            print("iOS could not extract flutter arguments in method: (cancelDownloadItem)")
            result(false)
        }
    }

    func delete(result: @escaping FlutterResult,call: FlutterMethodCall){
        guard let args = call.arguments else {
            return
        }
        if let myArgs = args as? [String: Any],
           let id : String = myArgs["id"] as? String
        {
            CacheManager.shared.delete(id: id)
            result(true)
        } else {
            print("iOS could not extract flutter arguments in method: (deleteDownloadItem)")
            result(false)
        }
        result(false)
    }

    func retry(result: @escaping FlutterResult,call: FlutterMethodCall){
        guard let args = call.arguments else {
            return
        }
        if let myArgs = args as? [String: Any],
           let id : String = myArgs["id"] as? String,
           let whereToSave : String = myArgs["savedDir"] as? String
        {
            if self.getActiveCount() <= 5 {
                CacheManager.shared.retry(id: id, whereToSave: whereToSave)
                result(true)
            } else {
                result(false)
            }
            result(true)
        } else {
            print("iOS could not extract flutter arguments in method: (retryDownloadItem)")
            result(false)
        }
        result(false)
    }

    func deleteLocal(result: @escaping FlutterResult,call: FlutterMethodCall){
        guard let args = call.arguments else {
            return
        }
        if let myArgs = args as? [String: Any],
           let id : String = myArgs["id"] as? String
        {
            if let download = CacheManager.shared.getDownloadItem(id: id){
                if let strVideoURL = download.localFile {
                    print(strVideoURL)
                    let videoURL = strVideoURL.localURL
                    _ = self.deleteLocalFilePath(filePath: videoURL)
                }
            }
        }
        result(true)
    }

    func openFile(result: @escaping FlutterResult,call: FlutterMethodCall,controller : UIViewController){
        guard let args = call.arguments else {
            return
        }
        if let myArgs = args as? [String: Any],
           let id : String = myArgs["id"] as? String
        {
            if let download = CacheManager.shared.getDownloadItem(id: id){
                if let strVideoURL = download.localFile {
                    print(strVideoURL)
                    let videoURL = strVideoURL.localURL
                    let OfflinePlayer = AVPlayer(url: videoURL!)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = OfflinePlayer
                    controller.present(playerViewController, animated: true) {
                        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: [])
                        playerViewController.player!.play()
                        UIApplication.shared.isIdleTimerDisabled = true
                    }
                } else {
                    print("No Local file found")
                }
            }else{
                print("No download file found")
            }
            result(true)
        } else {
            print("iOS could not extract flutter arguments in method: (startOfflineVideo)")
            result(false)
        }
        result(false)
    }

    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }

    func saveContext () {
        guard let context = getAppDelegateContext() else { return }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func getActiveCount() -> Int{
        let allItems = CacheManager.shared.allDownloadItems() ?? [Download]()
        var activeCount = 0
        for item in allItems {
            if item.status == CacheManager.DownloadStatus.active.rawValue {
                activeCount = activeCount + 1
            }
        }
        return activeCount
    }

    func deleteLocalFilePath(filePath : URL?)->Bool{
        do {
            try FileManager.default.removeItem(at: filePath!)
            print("deleteLocalVideo File deleted")
            return true
        }
        catch {
            print("deleteLocalVideoError")
        }
        return false
    }

    public func initiate(){
        CacheManager.shared.setupDownloadQueue()
        let allItems = CacheManager.shared.allDownloadItems() ?? [Download]()
        for item in allItems {
            if item.status == CacheManager.DownloadStatus.active.rawValue {
                guard let itemId = item.id else {
                    continue
                }
                CacheManager.shared.pause(id: itemId)
            }

            if item.status == nil {
                guard let itemId = item.id else {
                    continue
                }
                CacheManager.shared.pause(id: itemId)       
            }
        }
    }

    public func clearAll() {
      let allItems = CacheManager.shared.allDownloadItems() ?? [Download]()
      for item in allItems {
          if item.status == CacheManager.DownloadStatus.active.rawValue {
              guard let itemId = item.id else {
                  continue
              }
              CacheManager.shared.pause(id: itemId)
          }
      }
    }
}

public protocol SwiftDManagerPluginDelegate {
    func getContext()-> NSManagedObjectContext?
}
