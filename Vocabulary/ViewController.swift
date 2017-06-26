//
//  ViewController.swift
//  Vocabulary
//
//  Created by Гость on 20.06.17.
//  Copyright © 2017 guestOrg. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var talbeView: UITableView!
    @IBOutlet weak var tbWordOrigin: UITextField!
    @IBOutlet weak var tbWordTranslation: UITextField!
    let vocabRestful = VocabRestful("http://localhost:3000/vocab")
    
    func reloadDataOfTableView(){
        self.talbeView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        talbeView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.talbeView.allowsSelection = true
        self.talbeView.delegate = self
        self.talbeView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        vocabRestful.getWords(callback: reloadDataOfTableView)
    }
    @IBAction func addWord(_ sender: UIButton) {
        let wordOrigin = self.tbWordOrigin.text! as String
        let wordTranslation = self.tbWordTranslation.text! as String
        self.vocabRestful.addWord(wordOrigin, wordTranslation: wordTranslation, callback: reloadDataOfTableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vocabRestful.amountOfCards
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "Cell",
                                              for: indexPath)
            cell.textLabel?.text = self.vocabRestful.getWordCard(index: indexPath.row)
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let selectedEl = indexPath[1]
        let alert = UIAlertController(title: "Deleting wordcard",
                                      message: "Do you really want to delete wordcard \"\(self.vocabRestful.getWordCard(index: selectedEl))\"?",
            preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes",
                                      style: .default) {
                                        [unowned self] action in
                                        self.vocabRestful.deleteWord(selectedEl, callback: self.reloadDataOfTableView)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("shaked")
            self.vocabRestful.updateCoreDataWithServerVersion(callback: self.reloadDataOfTableView)
        }
    }
}
