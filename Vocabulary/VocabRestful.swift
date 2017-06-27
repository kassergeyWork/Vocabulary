//
//  VocabRestful.swift
//  Vocabulary
//
//  Created by Гость on 27.06.17.
//  Copyright © 2017 guestOrg. All rights reserved.
//

import Foundation

class VocabRestful{
    let urlString: String
    let url: URL
    private var wordCardsDict: [Dictionary<String, AnyObject>] = []
    
    init(_ urlString: String){
        self.urlString = urlString
        self.url = URL(string: urlString)!
    }
    var wordCards : [Dictionary<String, String>] {
        get{
            var wordCardsRet: [Dictionary<String, String>] = []
            for anItem in wordCardsDict{
                var wordCard = Dictionary<String, String>()
                wordCard["wordOrigin"] = anItem["wordOrigin"] as? String
                wordCard["wordTranslation"] = anItem["wordTranslation"] as? String
                wordCard["id"] = anItem["_id"] as? String
                wordCardsRet.append(wordCard)
            }
            return wordCardsRet
        }
    }
    func getWords(callback:@escaping ()->Void){
        let task = URLSession.shared.dataTask(with: self.url) { data, response, error in
            if(self.isFundamentalNetErr(data: data, error: error)){
                return
            }
            let data = data!
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            self.wordCardsDict = json as! [Dictionary<String, AnyObject>]
            callback()
        }
        task.resume()
    }
    func addWord(_ wordOrigin: String, wordTranslation: String, finish:@escaping (_ id: String)->Void){
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"
        let postString = "wordOrigin="+wordOrigin+"&wordTranslation="+wordTranslation
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if(self.isFundamentalNetErr(data: data, error: error)){
                return
            }
            
            let data = data!
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            else{
                let json = try! JSONSerialization.jsonObject(with: data, options: [])
                let jsonArr = json as! Dictionary<String, AnyObject>
                finish(jsonArr["_id"] as! String)
            }
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
    func deleteWord(id: String) {
        var request = URLRequest(url: URL(string: self.urlString+"/"+id)!)
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if(self.isFundamentalNetErr(data: data, error: error)){
                return
            }
            let data = data!
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
        
    }
    func isFundamentalNetErr(data: Data?, error: Error?) -> Bool{
        guard error == nil else {
            print(error!)
            return true
        }
        guard data != nil else {
            print("Data is empty")
            return true
        }
        return false
    }
}
