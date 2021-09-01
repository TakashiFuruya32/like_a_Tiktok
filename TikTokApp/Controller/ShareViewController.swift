//
//  ShareViewController.swift
//  TikTokApp
//
//  Created by HechiZan on 2021/08/26.
//

import UIKit
import AVKit
import Photos


class ShareViewController: UIViewController {

    var captionString = String()
    var passedURL = String()
    var player:AVPlayer?
    var playerController:AVPlayerViewController?
    
    @IBOutlet weak var textView: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        notification.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //完成されたURLを再生
        setUPVideoPlayer(url: URL(string: passedURL)!)
        
    }
    
    func setUPVideoPlayer(url:URL){
           
           
           self.view.backgroundColor = UIColor.black
           playerController?.removeFromParent()
           player = AVPlayer(url: url)
           self.player?.volume = 1
          
           playerController = AVPlayerViewController()
           playerController!.view.frame = CGRect(x: 29, y: 88, width: 317, height: 455)
           playerController?.videoGravity = .resizeAspectFill
           playerController!.showsPlaybackControls = false
           playerController!.player = player!
           self.addChild(playerController!)
           self.view.addSubview(playerController!.view)
           

           NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)

           
           player?.play()

       }
    
    @objc func playerItemDidReachEnd(_ notification:Notification){
        
        //空判定
        if self.player != nil{
            
            self.player?.seek(to: CMTime.zero)
            self.player?.volume = 1
            self.player?.play()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        textView.resignFirstResponder()
    }
    
    
    
    
    @IBAction func savePhotoLibrary(_ sender: Any) {
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(string: self.passedURL)!)
        } completionHandler: { (result, error) in
            
            if error != nil{
                
                print(error.debugDescription)
                return
            }
            
            if result{
                
                print("動画を保存しました")
                
            }
        }

    }
    
    @IBAction func back(_ sender: Any) {
        
        player?.pause()
        player = nil
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func share(_ sender: Any) {
        
        
        //アクティビティビューに掲載
        let activityItems = [URL(string: passedURL) as Any,"\(textView.text!)\n\(captionString)\n#UdemyTikTokios14"] as [Any]
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityController.popoverPresentationController?.sourceView = self.view
        activityController.popoverPresentationController?.sourceRect = self.view.frame
        self.present(activityController, animated: true, completion: nil)
    }
    
    
    
    @objc func keyboardWillShow(notification: Notification?) {
           let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
           let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
           UIView.animate(withDuration: duration!) {
             self.view.transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
           }
         }
           
         
         @objc func keyboardWillHide(notification: Notification?) {
           let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
           UIView.animate(withDuration: duration!) {
             self.view.transform = CGAffineTransform.identity
           }
         }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
