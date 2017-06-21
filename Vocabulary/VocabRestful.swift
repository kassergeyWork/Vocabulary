//
//  VocabRestful.swift
//  Vocabulary
//
//  Created by Гость on 21.06.17.
//  Copyright © 2017 guestOrg. All rights reserved.
//

import Foundation
import UIKit

class VocabRestful {
    let urlString: String
    let url: URL
    public var wordCards: [String] = []
    public var wordCardsIds: [String] = []
    init(_ urlString: String) {
        self.urlString = urlString
        self.url = URL(string: urlString)!
    }
    
    public func updateListOfWordCards(callback:@escaping ()->Void) {
        DispatchQueue.global(qos: .userInitiated).async { // 1
            let task = URLSession.shared.dataTask(with: self.url) { data, response, error in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                
                let json = try! JSONSerialization.jsonObject(with: data, options: [])
                for anItem in json as! [Dictionary<String, AnyObject>] { // or [[String:AnyObject]]
                    let wordOrigin = anItem["wordOrigin"] as!  String
                    let wordTranslation = anItem["wordTranslation"] as! String
                    let id = anItem["_id"] as! String
                    self.wordCards.append(wordOrigin+" - "+wordTranslation)
                    self.wordCardsIds.append(id)
                }
                DispatchQueue.main.async { // 2
                    callback()
                }
            }
            task.resume()
        }
    }
    public func addWord(_ wordOrigin: String, wordTranslation: String, callback:@escaping ()->Void){
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"
        let postString = "wordOrigin="+wordOrigin+"&wordTranslation="+wordTranslation
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {// check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            else{
                self.wordCards.append(wordOrigin+" - "+wordTranslation)
                let json = try! JSONSerialization.jsonObject(with: data, options: [])
                let jsonArr = json as! Dictionary<String, AnyObject>
                self.wordCardsIds.append(jsonArr["_id"] as! String)
                callback();
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
        }
        task.resume()
    }
    public func deleteWord(_ id: Int, callback:@escaping ()->Void){
                                        var request = URLRequest(url: URL(string: self.urlString+"/"+self.wordCardsIds[id])!)
                                        request.httpMethod = "DELETE"
                                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                                            guard let data = data, error == nil else {// check for fundamental networking error
                                                print("error=\(error)")
                                                return
                                            }
                                            
                                            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                                                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                                                print("response = \(response)")
                                            }
                                            else{
                                                self.wordCardsIds.remove(at: id)
                                                self.wordCards.remove(at: id)
                                                callback();
                                            }
                                            
                                            let responseString = String(data: data, encoding: .utf8)
                                            print("responseString = \(responseString)")
                                        }
                                        task.resume()
        
    }
}
