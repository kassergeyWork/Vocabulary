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
                let wordCard = ["wordOrigin" : anItem["wordOrigin"] as! String, "wordTranslation" : anItem["wordTranslation"] as! String, "id" :  anItem["_id"] as! String]
                wordCardsRet.append(wordCard)
            }
            return wordCardsRet
        }
    }
    
    var vocabMediator: VocabMediatorProtocol!
    
    func getWords(){
        let task = URLSession.shared.dataTask(with: self.url) { data, response, error in
            if(self.isFundamentalNetErr(data: data, error: error)){
                return
            }
            let data = data!
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            self.wordCardsDict = json as! [Dictionary<String, AnyObject>]
            self.vocabMediator?.onLoads(wordCards: self.wordCards)
        }
        task.resume()
    }
    func addWord(_ wordOrigin: String, wordTranslation: String){
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
            }
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
    func removeByOrigin(origin: String) {
        var request = URLRequest(url: URL(string: self.urlString+"/getWord")!)
        request.httpMethod = "POST"
        let postString = "wordOrigin="+origin
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
                let id = jsonArr["_id"] as! String
                var request1 = URLRequest(url: URL(string: self.urlString+"/"+id)!)
                request1.httpMethod = "DELETE"
                let task1 = URLSession.shared.dataTask(with: request1) { data, response, error in
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
                task1.resume()
            }
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
        
    }
    private func isFundamentalNetErr(data: Data?, error: Error?) -> Bool{
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
