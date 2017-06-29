//
//  VocabMediator.swift
//  Vocabulary
//
//  Created by Гость on 29.06.17.
//  Copyright © 2017 guestOrg. All rights reserved.
//

import Foundation
protocol VocabMediatorProtocol {
    func onDelete(id: String)
    func onLoads(wordCards: [Dictionary<String, String>])
    func onAdd(id: String)
}
