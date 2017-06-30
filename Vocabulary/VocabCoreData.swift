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


class VocabCoreData : VocabRepository{
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
    
    var vocabMediator: VocabMediatorProtocol!
    
    func isRepositoryEmpty() -> Bool {
        guard let managedContext = self.getManagedContext() else{
            return true
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
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
    
    func getWords(){
        guard let managedContext = self.getManagedContext() else{
            return
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        do {
            wordCardsManagedObject = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        vocabMediator?.onLoads(wordCards: self.wordCards)
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
            self.addWord(wordOrigin: wordOrigin, wordTranslation: wordTranslation)
        }
    }
    
    func addWord(wordOrigin: String, wordTranslation: String) {
        guard let managedContext = self.getManagedContext() else{
            return
        }
        let entity = NSEntityDescription.entity(forEntityName: entityName,
                                       in: managedContext)!
        
        let wordCard = NSManagedObject(entity: entity, insertInto: managedContext)
        wordCard.setValue(wordOrigin, forKeyPath: "wordOrigin")
        wordCard.setValue(wordTranslation, forKeyPath: "wordTranslation")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func removeByOrigin(origin: String) {
        guard let managedContext = self.getManagedContext() else{
            return
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: self.entityName)
        fetchRequest.predicate = NSPredicate.init(format: "wordOrigin = %@", origin)
        if let result = try? managedContext.fetch(fetchRequest) {
            for object in result {
                managedContext.delete(object)
            }
        }
        do {
            try managedContext.save()
            vocabMediator?.onDelete(origin: origin)
        } catch {
            print ("There was an error")
        }
    }
    private func getManagedContext() -> NSManagedObjectContext?{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
}
