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
    public var vocabCoreData: VocabCoreData
    public var vocabRestful: VocabRestful
    private var funcKostil: (()->Void)!
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
        self.vocabCoreData = VocabCoreData()
    }
    
    public func initMediators(){
        self.vocabRestful.vocabMediator = self;
        self.vocabCoreData.vocabMediator = self;
    }
    
    public func getWords(callback:@escaping ()->Void) {
        funcKostil = callback;
        if(vocabCoreData.isRepositoryEmpty()){
            vocabRestful.getWords()
        } else {
            vocabCoreData.getWords()
        }
    }
    private func addWordCard(_ wordCard: Dictionary<String, String>){
            self.wordCards.append(wordCard)
    }
    public func synchronizeLocalToServer(callback:@escaping ()->Void){
        vocabCoreData.clearRepositary()
        self.wordCards.removeAll()
        getWords(callback: callback)
    }
    public func addWord(_ wordOrigin: String, wordTranslation: String, callback:@escaping ()->Void){
        vocabRestful.addWord(wordOrigin: wordOrigin, wordTranslation: wordTranslation)
        vocabCoreData.addWord(wordOrigin: wordOrigin, wordTranslation: wordTranslation)
        var wordCardC = Dictionary<String, String>()
        wordCardC["wordOrigin"] = wordOrigin
        wordCardC["wordTranslation"] = wordTranslation
        self.addWordCard(wordCardC)
        callback();
    }
    public func deleteWord(_ id: Int, callback:@escaping ()->Void){
        let origin = self.wordCards[id]["wordOrigin"]
        self.vocabRestful.removeByOrigin(origin: origin!)
        self.vocabCoreData.removeByOrigin(origin: origin!)
        self.wordCards.remove(at: id)
        callback()
    }
    
    //MARK: VocabMediatorProtocol
    func onDelete(origin: String){
        
    }
    func onLoads(wordCards: [Dictionary<String, String>]){
        self.wordCards = wordCards
        if(vocabCoreData.isRepositoryEmpty())
        {
            self.vocabCoreData.saveWordCardsArrayOfDictionaryStrStr(self.wordCards)
        }
        funcKostil()
    }
    func onAdd(id: String){
        
    }
}
