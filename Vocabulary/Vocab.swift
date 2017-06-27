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
                self.vocabRepository.saveWordCardsArrayOfDictionaryStrStr(self.vocabRestful.wordCards, callback: self.addWordCard)
                DispatchQueue.main.async { // 2
                    callback()
                }
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
            self.vocabRepository.save(wordOrigin: wordOrigin, wordTranslation: wordTranslation, id: id, callback: self.addWordCard)
            callback();
        })
    }
    public func deleteWord(_ id: Int, callback:@escaping ()->Void){
        let idOfWord = self.wordCards[id]["id"]
        var request = URLRequest(url: URL(string: self.vocabRestful.urlString+"/"+idOfWord!)!)
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if(self.vocabRestful.isFundamentalNetErr(data: data, error: error)){
                return
            }
            let data = data!
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            else{
                self.vocabRepository.removeById(id: idOfWord!)
                self.wordCards.remove(at: id)
                callback();
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
}
