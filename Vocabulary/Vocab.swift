//
//  VocabRestful.swift
//  Vocabulary
//
//  Created by Гость on 21.06.17.
//  Copyright © 2017 guestOrg. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Vocab {
    var wordCards: [Dictionary<String, String>] = []
    var wordCardsManagedObjects: [NSManagedObject] = []
    public var vocabRepository: VocabRepository
    public var vocabRestful: VocabRestful
    var amountOfCards: Int{
        get{
            return self.wordCards.count
        }
    }
    public func getWordCard(index: Int) -> String{
        return (self.wordCards[index]["wordOrigin"])! + " - " + (self.wordCards[index]["wordTranslation"])!
    }
    init() {
        self.vocabRestful = VocabRestful("http://localhost:3000/vocab")
        self.vocabRepository = VocabRepository()
    }
    
    private func convertManagedObjectToDictionary(){
        for anItem in wordCardsManagedObjects{
            var wordCard = Dictionary<String, String>()
            wordCard["wordOrigin"] = anItem.value(forKeyPath: "wordOrigin") as? String
            wordCard["wordTranslation"] = anItem.value(forKeyPath: "wordTranslation") as? String
            wordCard["id"] = anItem.value(forKeyPath: "id") as? String
            wordCards.append(wordCard)
        }
    }
    
    public func getWords(callback:@escaping ()->Void) {
        guard let managedContext = self.vocabRepository.getManagedContext() else{
            return
        }
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: vocabRepository.entityName)
        do {
            self.wordCardsManagedObjects = try managedContext.fetch(fetchRequest)
            if(wordCardsManagedObjects.count != 0){
                self.convertManagedObjectToDictionary()
                return
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        DispatchQueue.global(qos: .userInitiated).async { // 1
            let task = URLSession.shared.dataTask(with: self.vocabRestful.url) { data, response, error in
                if(self.vocabRestful.isFundamentalNetErr(data: data, error: error)){
                    return
                }
                let data = data!
                let json = try! JSONSerialization.jsonObject(with: data, options: [])
                for anItem in json as! [Dictionary<String, AnyObject>] { // or [[String:AnyObject]]
                    let wordOrigin = anItem["wordOrigin"] as!  String
                    let wordTranslation = anItem["wordTranslation"] as! String
                    let id = anItem["_id"] as! String
                    self.vocabRepository.save(wordOrigin: wordOrigin, wordTranslation: wordTranslation, id: id, callback: self.addWordCard)
                }
                DispatchQueue.main.async { // 2
                    callback()
                }
            }
            task.resume()
        }
    }
    private func addWordCard(_ wordCard: Dictionary<String, String>){
            self.wordCards.append(wordCard)
            print(wordCards)
    }
    public func updateCoreDataWithServerVersion(callback:@escaping ()->Void){
        guard let managedContext = self.vocabRepository.getManagedContext() else{
            return
        }
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: vocabRepository.entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
            try managedContext.execute(request)
            self.wordCards.removeAll()
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return
        }
        getWords(callback: callback)
    }
    public func addWord(_ wordOrigin: String, wordTranslation: String, callback:@escaping ()->Void){
        vocabRestful.addWordAndReturnId(wordOrigin, wordTranslation: wordTranslation, finish: {id in
            self.vocabRepository.save(wordOrigin: wordOrigin, wordTranslation: wordTranslation, id: id, callback: self.addWordCard)
            callback();
        })
    }
    public func deleteWord(_ id: Int, callback:@escaping ()->Void){
        let idOfWord = self.wordCardsManagedObjects[id].value(forKeyPath: "id") as? String
        var request = URLRequest(url: URL(string: self.vocabRestful.urlString+"/"+idOfWord!)!)
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if(self.vocabRestful.isFundamentalNetErr(data: data, error: error)){
                return
            }
            let data = data!
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            else{
                guard let managedContext = self.vocabRepository.getManagedContext() else{
                    return
                }
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: self.vocabRepository.entityName)
                fetchRequest.predicate = NSPredicate.init(format: "id = %@", idOfWord!)
                if let result = try? managedContext.fetch(fetchRequest) {
                    for object in result {
                        managedContext.delete(object)
                    }
                }
                do {
                    try managedContext.save()
                    self.wordCards.remove(at: id)
                } catch {
                    print ("There was an error")
                }
                callback();
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
}
