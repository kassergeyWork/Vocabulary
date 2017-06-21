//
//  ViewController.swift
//  Vocabulary
//
//  Created by Гость on 20.06.17.
//  Copyright © 2017 guestOrg. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var talbeView: UITableView!
    @IBOutlet weak var tableViewSource: UITableView!
    @IBOutlet weak var tbWordOrigin: UITextField!
    @IBOutlet weak var tbWordTranslation: UITextField!
    let vocabRestful = VocabRestful("http://localhost:3000/vocab")
    let urlString = "http://localhost:3000/vocab"
    let url = URL(string: "http://localhost:3000/vocab")

    func updateListOfWordCards(){
        vocabRestful.updateListOfWordCards{
                    self.talbeView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        talbeView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.talbeView.allowsSelection = true
        self.talbeView.delegate = self
        self.talbeView.dataSource = self
        updateListOfWordCards()
    }
    @IBAction func addWord(_ sender: UIButton) {
        let wordOrigin = self.tbWordOrigin.text! as String
        let wordTranslation = self.tbWordTranslation.text! as String
        self.vocabRestful.addWord(wordOrigin, wordTranslation: wordTranslation, callback: {()->Void in
            self.talbeView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.vocabRestful.wordCards.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "Cell",
                                              for: indexPath)
            cell.textLabel?.text = self.vocabRestful.wordCards[indexPath.row]
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let selectedEl = indexPath[1]
        let alert = UIAlertController(title: "Deleting wordcard",
                                      message: "Do you really want to delete wordcard?",
                                      preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes",
                                       style: .default) {
                                        [unowned self] action in
                                        self.vocabRestful.deleteWord(selectedEl, callback: {
                                                self.talbeView.reloadData()
                                        })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
