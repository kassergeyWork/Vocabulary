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
}
