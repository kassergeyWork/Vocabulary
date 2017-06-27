//
//  VocabRestful.swift
//  Vocabulary
//
//  Created by Гость on 27.06.17.
//  Copyright © 2017 guestOrg. All rights reserved.
//

import Foundation

class VocabRestful{
    let urlString: String
    let url: URL
    
    init(_ urlString: String){
        self.urlString = urlString
        self.url = URL(string: urlString)!
    }
    func isFundamentalNetErr(data: Data?, error: Error?) -> Bool{
        guard error == nil else {
            print(error!)
            return true
        }
        guard data != nil else {
            print("Data is empty")
            return true
        }
        return false
    }
}
