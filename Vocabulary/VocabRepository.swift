//
//  VocabRepository.swift
//  Vocabulary
//
//  Created by Гость on 27.06.17.
//  Copyright © 2017 guestOrg. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class VocabRepository{
    let entityName: String = "WordCard"
    private var wordCardsManagedObject: [NSManagedObject] = []
    var wordCards : [Dictionary<String, String>] {
        get{
            var wordCardsRet: [Dictionary<String, String>] = []
            for anItem in wordCardsManagedObject{
                var wordCard = Dictionary<String, String>()
                wordCard["wordOrigin"] = anItem.value(forKeyPath: "wordOrigin") as? String
                wordCard["wordTranslation"] = anItem.value(forKeyPath: "wordTranslation") as? String
                wordCard["id"] = anItem.value(forKeyPath: "id") as? String
                wordCardsRet.append(wordCard)
            }
            return wordCardsRet
        }
    }
    
    func isRepositoryEmpty() -> Bool {
        guard let managedContext = self.getManagedContext() else{
            return true
        }
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: entityName)
        do {
            self.wordCardsManagedObject = try managedContext.fetch(fetchRequest)
            if(wordCardsManagedObject.count == 0){
                return true
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return false
    }
    
    func getWords(callback:@escaping ()->Void){
        guard let managedContext = self.getManagedContext() else{
            return
        }
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: entityName)
        do {
            wordCardsManagedObject = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        callback()
    }
    
    func clearRepositary() {
        guard let managedContext = self.getManagedContext() else{
            return
        }
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
            try managedContext.execute(request)
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return
        }
    }
    
    func saveWordCardsArrayOfDictionaryStrStr(_ wordCards: [Dictionary<String, String>]){
        for anItem in wordCards {
            let wordOrigin = anItem["wordOrigin"]!
            let wordTranslation = anItem["wordTranslation"]!
            let id = anItem["id"]!
            self.save(wordOrigin: wordOrigin, wordTranslation: wordTranslation, id: id)
        }
    }
    
    func save(wordOrigin: String, wordTranslation: String, id: String) {
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
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func removeById(id: String) {
                guard let managedContext = self.getManagedContext() else{
                    return
                }
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: self.entityName)
                fetchRequest.predicate = NSPredicate.init(format: "id = %@", id)
                if let result = try? managedContext.fetch(fetchRequest) {
                    for object in result {
                        managedContext.delete(object)
                    }
                }
                do {
                    try managedContext.save()
                } catch {
                    print ("There was an error")
                }
    }
    func getManagedContext() -> NSManagedObjectContext?{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
}
