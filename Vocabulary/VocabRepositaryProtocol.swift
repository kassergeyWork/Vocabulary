//
//  VocabRepositary.swift
//  Vocabulary
//
//  Created by Гость on 30.06.17.
//  Copyright © 2017 guestOrg. All rights reserved.
//

import Foundation

protocol VocabRepositary {
    func addWord(wordOrigin: String, wordTranslation: String)
    func removeByOrigin(origin: String)
    func getWords()
    var wordCards : [Dictionary<String, String>] { get }
    func isRepositoryEmpty() -> Bool
    func saveWordCardsArrayOfDictionaryStrStr(_ wordCards: [Dictionary<String, String>])
    func clearRepositary()
    func setMediator(mediator: VocabMediatorProtocol)
}
