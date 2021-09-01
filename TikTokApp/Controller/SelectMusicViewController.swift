//
//  SelectMusicViewController.swift
//  TikTokApp
//
//  Created by HechiZan on 2021/08/26.
//

import UIKit
import SDWebImage
import AVFoundation
import SwiftVideoGenerator

class SelectMusicViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,MusicProtocol {

 

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var player:AVAudioPlayer?
    var videoPath = String()
    var passedURL:URL?
    
    var musicModel = MusicModel()
    
    //遷移元から処理を受け取るクロージャーのプロパティを用意
    var resultHandler:((String,String,String)->Void)?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 130
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return musicModel.artistNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.isHighlighted = false
        let artWorkImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let musicNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        let artistNameLabel = cell.contentView.viewWithTag(3) as! UILabel
        
        artWorkImageView.sd_setImage(with: URL(string: musicModel.artworkUrl100Array[indexPath.row]), completed: nil)
        musicNameLabel.text = musicModel.trackCensoredNameArray[indexPath.row]
        artistNameLabel.text = musicModel.artistNameArray[indexPath.row]
        
        //コードでボタンの実装
        let favButton = UIButton(frame: CGRect(x: 318, y: 41, width: 40, height: 33))
        favButton.setImage(UIImage(named: "fav"), for: .normal)
        favButton.addTarget(self, action: #selector(favButtonTap(_:)), for: .touchUpInside)
        favButton.tag = indexPath.row
        cell.contentView.addSubview(favButton)
        
        let playButton = UIButton(frame: CGRect(x: 20, y: 15, width: 100, height: 100))
        playButton.setImage(UIImage(named: "play"), for: .normal)
        playButton.addTarget(self, action: #selector(playButtonTap(_:)), for: .touchUpInside)
        playButton.tag = indexPath.row
        cell.contentView.addSubview(playButton)
        
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        refleshData()
        textField.resignFirstResponder()
        
        return true
        
    }
    
    
    @objc func favButtonTap(_ sender:UIButton){
        
        //音楽が流れていたら止める
        if player?.isPlaying == true{
            
            player?.stop()
        }
        
        //動画と音声を合成する（時間がかかる）
        
        //ロード中の画面を出す
        LoadingView.lockView()
        
        VideoGenerator.fileName = "newAudioMoview"
        VideoGenerator.current.mergeVideoWithAudio(videoUrl: passedURL!, audioUrl: URL(string: self.musicModel.preViewURLArray[sender.tag])!)  { (results) in
            
            LoadingView.unlockView()
            
            switch results{
            
            case .success(let url):
                
                self.videoPath = url.absoluteString
                if let handler = self.resultHandler{
                    
                    handler(self.videoPath,self.musicModel.artistNameArray[sender.tag],self.musicModel.trackCensoredNameArray[sender.tag])
                }
                
                self.dismiss(animated: true, completion: nil)
                
            
            case .failure(let error):
                
                print(error)
            }
        }
        //合成ができたら値を渡しながら遷移する
        
    }
    
    @objc func playButtonTap(_ sender:UIButton){
        print(sender.tag)
        
            //音楽を止める
        if player?.isPlaying == true{
            
            player?.stop()
        }
        
        let url = URL(string: musicModel.preViewURLArray[sender.tag])
        downLoadMusicURL(url: url!)
        
    }
    
    func downLoadMusicURL(url:URL){
        
        var downLoadTask:URLSessionDownloadTask?
        downLoadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (url, response, error) in
            
            self.play(url: url!)
            
            
        })
        
        downLoadTask?.resume()
        
        
    }
    
    
    func play(url:URL){
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.volume = 1.0
            player?.play()
            
        } catch let error as NSError {
            
            print(error.debugDescription)
        }
        
    }
    
    func catchData(count: Int) {
        
        if count == 1{
            
            tableView.reloadData()
        }
    }
    
    
    
    func refleshData(){
    
        if searchTextField.text?.isEmpty != nil{
            
            let urlString = "https://itunes.apple.com/search?term=\(String(describing:searchTextField.text!))&entity=song&country=jp"
            //pcの言語にエンコードする
            let encodeUrlString:String = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            musicModel.musicDelegate = self
            musicModel.setData(resultCount: 50, encodeUrlString: encodeUrlString)
            
            searchTextField.resignFirstResponder()
        }
        
        
    }
    
    @IBAction func searchAction(_ sender: Any) {
        
        refleshData()
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
