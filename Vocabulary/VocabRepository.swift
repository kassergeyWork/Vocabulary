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
    
    func save(wordOrigin: String, wordTranslation: String, id: String, callback:@escaping (_ wordCard: NSManagedObject)->Void) {
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
            callback(wordCard)
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
