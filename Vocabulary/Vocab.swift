//
//  VocabRestful.swift
//  Vocabulary
//
//  Created by Гость on 21.06.17.
//  Copyright © 2017 guestOrg. All rights reserved.
//

import Foundation

class Vocab {
    var wordCards: [Dictionary<String, String>] = []
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
    
    public func getWords(callback:@escaping ()->Void) {
        if(vocabRepository.isRepositoryEmpty()){
            vocabRestful.getWords {
                self.vocabRepository.saveWordCardsArrayOfDictionaryStrStr(self.vocabRestful.wordCards)
                self.wordCards = self.vocabRestful.wordCards
                callback()
            }
        } else {
            vocabRepository.getWords {
                self.wordCards = self.vocabRepository.wordCards
                callback()
            }
        }
    }
    private func addWordCard(_ wordCard: Dictionary<String, String>){
            self.wordCards.append(wordCard)
    }
    public func updateCoreDataWithServerVersion(callback:@escaping ()->Void){
        vocabRepository.clearRepositary()
        self.wordCards.removeAll()
        getWords(callback: callback)
    }
    public func addWord(_ wordOrigin: String, wordTranslation: String, callback:@escaping ()->Void){
        vocabRestful.addWord(wordOrigin, wordTranslation: wordTranslation, finish: {id in
            self.vocabRepository.save(wordOrigin: wordOrigin, wordTranslation: wordTranslation, id: id)
            var wordCardC = Dictionary<String, String>()
            wordCardC["wordOrigin"] = wordOrigin
            wordCardC["wordTranslation"] = wordTranslation
            wordCardC["id"] = id
            self.addWordCard(wordCardC)
            callback();
        })
    }
    public func deleteWord(_ id: Int, callback:@escaping ()->Void){
        let idOfWord = self.wordCards[id]["id"]
        self.vocabRestful.deleteWord(id: idOfWord!)
        self.vocabRepository.removeById(id: idOfWord!)
        self.wordCards.remove(at: id)
        callback()
    }
}
