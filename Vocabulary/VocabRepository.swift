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
    
    init() {
    }
    
    func save(wordOrigin: String, wordTranslation: String, id: String, callback:@escaping (_ wordCard: Dictionary<String, String>)->Void) {
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
            var wordCardC = Dictionary<String, String>()
            wordCardC["wordOrigin"] = wordCard.value(forKeyPath: "wordOrigin") as? String
            wordCardC["wordTranslation"] = wordCard.value(forKeyPath: "wordTranslation") as? String
            wordCardC["id"] = wordCard.value(forKeyPath: "id") as? String
            callback(wordCardC)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func getManagedContext() -> NSManagedObjectContext?{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
}
