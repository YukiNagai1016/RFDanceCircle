//
//  MovieViewController.swift
//  RFDanceCircle
//
//  Created by 優樹永井 on 2021/02/06.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Photos
import MobileCoreServices
import AVKit
import AVFoundation

class MovieViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let storage = Storage.storage()
    var movieURL: NSURL? = nil
    
    @IBOutlet var movieView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization {status in
                if status != .authorized {
                    print("not authorized")
                    //...ユーザにPhotoLibraryへのアクセス承認を促すメッセージの表示等を行う
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func reload() {
        let movieRef = storage.reference(withPath: "movie.mp4")
        movieRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                //let movieString = String(data: data!, encoding: String.Encoding.utf8)
                let movieURL = URL(dataRepresentation: data!, relativeTo: nil)
                print("ああああ")
                
                let video = AVPlayer(url: movieURL!)
                let videoPlayer = AVPlayerViewController()
                
                videoPlayer.player = video
                self.present(videoPlayer, animated: true, completion:
                    {
                        video.play()
                })
            }
        }
    }
    
    @IBAction func add() {
        showAddAlertController()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let url = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
            self.encodeVideo(videoURL: url as URL)
            movieURL = url
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func encodeVideo(videoURL: URL){
        let avAsset = AVURLAsset(url: videoURL)
        let startDate = Date()
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)
        
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocPath = NSURL(fileURLWithPath: docDir).appendingPathComponent("temp.mp4")?.absoluteString
        
        let docDir2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        
        let filePath = docDir2.appendingPathComponent("rendered-Video.mp4")
        deleteFile(filePath!)
        
        if FileManager.default.fileExists(atPath: myDocPath!){
            do{
                try FileManager.default.removeItem(atPath: myDocPath!)
            }catch let error{
                print(error)
            }
        }
        
        exportSession?.outputURL = filePath
        exportSession?.outputFileType = AVFileType.mp4
        exportSession?.shouldOptimizeForNetworkUse = true
        
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRange(start: start, duration: avAsset.duration)
        exportSession?.timeRange = range
        
        exportSession!.exportAsynchronously{() -> Void in
            switch exportSession!.status{
            case .failed:
                print("\(exportSession!.error!)")
            case .cancelled:
                print("Export cancelled")
            case .completed:
                let endDate = Date()
                let time = endDate.timeIntervalSince(startDate)
                print(time)
                print("Successful")
                print(exportSession?.outputURL ?? "")
                let profileMovieRef = self.storage.reference().child("movie.mp4")
                profileMovieRef.putFile(from: exportSession!.outputURL!, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print("エラー：\(error!)")
                    } else {
                        profileMovieRef.downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                print("エラー：\(error!)")
                                return
                                
                            }
                        }
                    }
                }
                )
            default:
                break
            }
            
        }
    }
    
    func deleteFile(_ filePath:URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else{
            return
        }
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func showAddAlertController() {
        let alertController = UIAlertController(title: "選択してください", message: "動画を追加します", preferredStyle: .actionSheet)
        
        let movieButton = UIAlertAction(title: "動画を選択", style: .default) { (action: UIAlertAction!) in
            let sourceType:UIImagePickerController.SourceType = .photoLibrary
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                
                let controller = UIImagePickerController()
                controller.sourceType = sourceType
                controller.mediaTypes=[kUTTypeMovie as String] // 動画のみ
                controller.delegate = self
                controller.allowsEditing = true
                controller.videoMaximumDuration = 10 // 10秒で動画を切り取る
                controller.videoQuality = UIImagePickerController.QualityType.typeMedium
                
                self.present(controller, animated: true, completion: nil)
            }
        }
        
        let cancelButton = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertController.addAction(movieButton)
        alertController.addAction(cancelButton)
        
        //alertControllerを表示させる
        self.present(alertController, animated: true, completion: nil)
    }
}
