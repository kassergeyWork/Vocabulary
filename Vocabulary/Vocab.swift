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
    public var vocabCoreData: VocabRepositary
    public var vocabRestful: VocabRepositary
    private var funcKostil: (()->Void)!
    var amountOfCards: Int{
        get{
            return self.wordCards.count
        }
    }
    public func getWordCard(index: Int) -> String{
        return (self.wordCards[index]["wordOrigin"])! + " - " + (self.wordCards[index]["wordTranslation"])!
    }
    
    init(callback:@escaping ()->Void) {
        self.vocabRestful = VocabRestful("http://localhost:3000/vocab")
        self.vocabCoreData = VocabCoreData()
        funcKostil = callback;
    }
    
    public func initMediators(){
        self.vocabRestful.setMediator(mediator: self)
        self.vocabCoreData.setMediator(mediator: self)
    }
    
    public func getWords() {
        if(vocabCoreData.isRepositoryEmpty()){
            vocabRestful.getWords()
        } else {
            vocabCoreData.getWords()
        }
    }
    private func addWordCard(_ wordCard: Dictionary<String, String>){
            self.wordCards.append(wordCard)
    }
    public func synchronizeLocalToServer(){
        vocabRestful.clearRepositary()
        vocabCoreData.getWords()
    }
    public func addWord(_ wordOrigin: String, wordTranslation: String){
        var wordCardC = Dictionary<String, String>()
        wordCardC["wordOrigin"] = wordOrigin
        wordCardC["wordTranslation"] = wordTranslation
        self.addWordCard(wordCardC)
        vocabRestful.addWord(wordOrigin: wordOrigin, wordTranslation: wordTranslation)
        vocabCoreData.addWord(wordOrigin: wordOrigin, wordTranslation: wordTranslation)
    }
    public func deleteWord(_ id: Int){
        let origin = self.wordCards[id]["wordOrigin"]
        self.wordCards.remove(at: id)
        self.vocabRestful.removeByOrigin(origin: origin!)
        self.vocabCoreData.removeByOrigin(origin: origin!)
    }
    
    //MARK: VocabMediatorProtocol should be implemented
    func onDelete(origin: String){
        funcKostil()
        print("word deleted "+origin)
    }
    func onLoads(wordCards: [Dictionary<String, String>]){
        self.wordCards = wordCards
        if(vocabCoreData.isRepositoryEmpty())
        {
            self.vocabCoreData.saveWordCardsArrayOfDictionaryStrStr(self.wordCards)
        }
        if(vocabRestful.isRepositoryEmpty()){
            self.vocabRestful.saveWordCardsArrayOfDictionaryStrStr(self.wordCards)
        }
        funcKostil()
    }
    func onAdd(origin: String){
        funcKostil()
    }
}
