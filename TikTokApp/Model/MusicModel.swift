//
//  MusicModel.swift
//  TikTokApp
//
//  Created by HechiZan on 2021/08/26.
//

import Foundation
import SwiftyJSON
import Alamofire

protocol MusicProtocol {
    
    func catchData(count:Int)
}

class MusicModel {
    
    //    //アーティスト名
    //    var artistName:String?
    //    //曲名
    //    var trackCensoredName:String?
    //    //音源URL
    //    var preViewURL:String?
    //    //ジャケ写
    //    var artworkUrl100:String?
    
    var artistNameArray = [String]()
    var trackCensoredNameArray = [String]()
    var preViewURLArray = [String]()
    var artworkUrl100Array = [String]()
    
    var musicDelegate:MusicProtocol?
    
    
    //JSON解析
    
    func setData(resultCount:Int,encodeUrlString:String) {
        
        //通信
        AF.request(encodeUrlString, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
            
            self.artistNameArray.removeAll()
            self.trackCensoredNameArray.removeAll()
            self.preViewURLArray.removeAll()
            self.artworkUrl100Array.removeAll()
            
            print(response)
            
            switch response.result{
            
            case .success:
                
                do {
                    let json:JSON = try JSON(data: response.data!)
                    
                    for i in 0...resultCount - 1{
                        
                        print(i)
                        
                        if json["results"][i]["artistName"].string == nil{
                            
                            print("ヒットしませんでした")
                            return
                        }
                        
                        
                        self.artistNameArray.append(json["results"][i]["artistName"].string!)
                        self.trackCensoredNameArray.append(json["results"][i]["trackCensoredName"].string!)
                        self.preViewURLArray.append(json["results"][i]["previewUrl"].string!)
                        self.artworkUrl100Array.append(json["results"][i]["artworkUrl100"].string!)
                        
                    }
                    
                    //全てのデータが取得完了している状態
                    self.musicDelegate?.catchData(count: 1)
                    
                } catch {
                    
                }
                
                break
                
            case .failure(_): break
                
            }
        }
    }
}
