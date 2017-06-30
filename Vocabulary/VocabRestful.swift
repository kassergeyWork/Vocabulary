//
//  VocabRestful.swift
//  Vocabulary
//
//  Created by Гость on 27.06.17.
//  Copyright © 2017 guestOrg. All rights reserved.
//

import Foundation
import SystemConfiguration

class VocabRestful: VocabRepositary{
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
    
    private var vocabMediator: VocabMediatorProtocol!
    func setMediator(mediator: VocabMediatorProtocol) {
        self.vocabMediator = mediator
    }
    
    func getWords(){
        getWordsAndRunCallback {
            self.vocabMediator?.onLoads(wordCards: self.wordCards)
        }
    }
    private func getWordsAndRunCallback(callback:@escaping () -> Void){
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
    func addWord(wordOrigin: String, wordTranslation: String){
        let request = getRequest(url: self.url, httpMethod: "POST", postString: "wordOrigin="+wordOrigin+"&wordTranslation="+wordTranslation)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if(self.isFundamentalNetErr(data: data, error: error)){
                return
            }
            self.unwrapDataAndSendMsgToMediator(data: data, response: response!, callback: {
                self.vocabMediator?.onAdd(origin: wordOrigin)
            })
        }
        task.resume()
    }
    func removeByOrigin(origin: String) {
        let request = getRequest(url: URL(string: self.urlString+"/deleteWord")!, httpMethod: "POST",postString: "wordOrigin="+origin)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if(self.isFundamentalNetErr(data: data, error: error)){
                return
            }
            self.unwrapDataAndSendMsgToMediator(data: data, response: response!, callback: {
                self.vocabMediator?.onDelete(origin: origin)
            })
        }
        task.resume()
    }
    private func getRequest(url: URL, httpMethod: String, postString: String) -> URLRequest{
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        let postString = postString
        request.httpBody = postString.data(using: .utf8)
        return request
    }
    private func unwrapDataAndSendMsgToMediator(data: Data?, response: URLResponse, callback:@escaping () -> Void){
        let data = data!
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            print("response = \(response)")
        }
        else{
            callback()
        }
        let responseString = String(data: data, encoding: .utf8)
        print("responseString = \(responseString)")
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
    func saveWordCardsArrayOfDictionaryStrStr(_ wordCards: [Dictionary<String, String>]) {
        for wc in wordCards {
            let wordOrigin = wc["wordOrigin"]!
            let wordTranslation = wc["wordTranslation"]!
            self.addWord(wordOrigin: wordOrigin, wordTranslation: wordTranslation)
        }
    }
    func clearRepositary() {
        let request = getRequest(url: URL(string: self.urlString+"/deleteWord")!, httpMethod: "DELETE",postString: "")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if(self.isFundamentalNetErr(data: data, error: error)){
                return
            }
            self.unwrapDataAndSendMsgToMediator(data: data, response: response!, callback: { })
        }
        task.resume()
    }
    
    func isRepositoryEmpty() -> Bool {
        getWordsAndRunCallback { }
        return wordCardsDict.count==0
    }
    
}
