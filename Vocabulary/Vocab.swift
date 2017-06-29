//
//  VocabRestful.swift
//  Vocabulary
//
//  Created by Гость on 21.06.17.
//  Copyright © 2017 guestOrg. All rights reserved.
//

import Foundation

class Vocab : VocabMediatorProtocol {
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
    
    public func initMediators(){
        self.vocabRestful.vocabMediator = self;
        self.vocabRepository.vocabMediator = self;
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
    public func synchronizeLocalToServer(callback:@escaping ()->Void){
        vocabRepository.clearRepositary()
        self.wordCards.removeAll()
        getWords(callback: callback)
    }
    public func addWord(_ wordOrigin: String, wordTranslation: String, callback:@escaping ()->Void){
        vocabRestful.addWord(wordOrigin, wordTranslation: wordTranslation)
        vocabRepository.save(wordOrigin: wordOrigin, wordTranslation: wordTranslation)
        var wordCardC = Dictionary<String, String>()
        wordCardC["wordOrigin"] = wordOrigin
        wordCardC["wordTranslation"] = wordTranslation
        self.addWordCard(wordCardC)
        callback();
    }
    public func deleteWord(_ id: Int, callback:@escaping ()->Void){
        let idOfWord = self.wordCards[id]["id"]
        self.vocabRestful.removeByOrigin(origin: idOfWord!)
        self.vocabRepository.removeByOrigin(origin: idOfWord!)
        self.wordCards.remove(at: id)
        callback()
    }
    
    //MARK: VocabMediatorProtocol
    func onDelete(id: String){
        
    }
    func onLoads(){
        
    }
    func onAdd(id: String){
        
    }
}
