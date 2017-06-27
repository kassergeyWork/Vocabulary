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
    private let urlString: String
    private let url: URL
    var wordCards: [NSManagedObject] = []
    let entityName: String = "WordCard"
    var amountOfCards: Int{
        get{
            return self.wordCards.count
        }
    }
    public func getWordCard(index: Int) -> String{
        return (self.wordCards[index].value(forKeyPath: "wordOrigin") as? String)! + " - " + (self.wordCards[index].value(forKeyPath: "wordTranslation") as? String)!
    }
    init() {
        self.urlString = "http://localhost:3000/vocab"
        self.url = URL(string: urlString)!
    }
    
    public func getWords(callback:@escaping ()->Void) {
        guard let managedContext = self.getManagedContext() else{
            return
        }
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: entityName)
        do {
            self.wordCards = try managedContext.fetch(fetchRequest)
            if(wordCards.count != 0){
                return
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        DispatchQueue.global(qos: .userInitiated).async { // 1
            let task = URLSession.shared.dataTask(with: self.url) { data, response, error in
                if(self.isFundamentalNetErr(data: data, error: error)){
                    return
                }
                let data = data!
                let json = try! JSONSerialization.jsonObject(with: data, options: [])
                for anItem in json as! [Dictionary<String, AnyObject>] { // or [[String:AnyObject]]
                    let wordOrigin = anItem["wordOrigin"] as!  String
                    let wordTranslation = anItem["wordTranslation"] as! String
                    let id = anItem["_id"] as! String
                    self.save(wordOrigin: wordOrigin, wordTranslation: wordTranslation, id: id)
                }
                DispatchQueue.main.async { // 2
                    callback()
                }
            }
            task.resume()
        }
    }
    public func updateCoreDataWithServerVersion(callback:@escaping ()->Void){
        guard let managedContext = self.getManagedContext() else{
            return
        }
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
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
                self.save(wordOrigin: wordOrigin, wordTranslation: wordTranslation, id: jsonArr["_id"] as! String)
                callback();
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
    private func save(wordOrigin: String, wordTranslation: String, id: String) {
        guard let managedContext = self.getManagedContext() else{
            return
        }
        let entity =
            NSEntityDescription.entity(forEntityName: entityName,
                                       in: managedContext)!
        
        let wordCard = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
        wordCard.setValue(wordOrigin, forKeyPath: "wordOrigin")
        wordCard.setValue(wordTranslation, forKeyPath: "wordTranslation")
        wordCard.setValue(id, forKeyPath: "id")
        do {
            try managedContext.save()
            self.wordCards.append(wordCard)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    public func deleteWord(_ id: Int, callback:@escaping ()->Void){
        let idOfWord = self.wordCards[id].value(forKeyPath: "id") as? String
        var request = URLRequest(url: URL(string: self.urlString+"/"+idOfWord!)!)
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
            else{
                guard let managedContext = self.getManagedContext() else{
                    return
                }
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: self.entityName)
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
    private func getManagedContext() -> NSManagedObjectContext?{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        return appDelegate.persistentContainer.viewContext
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
