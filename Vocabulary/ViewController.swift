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
    var wordCards: [String] = []
    var wordCardsIds: [String] = []
    let urlString = "http://localhost:3000/vocab"
    let url = URL(string: "http://localhost:3000/vocab")

    func updateListOfWordCards(){
        DispatchQueue.global(qos: .userInitiated).async { // 1
            let task = URLSession.shared.dataTask(with: self.url!) { data, response, error in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                
                let json = try! JSONSerialization.jsonObject(with: data, options: [])
                for anItem in json as! [Dictionary<String, AnyObject>] { // or [[String:AnyObject]]
                    let wordOrigin = anItem["wordOrigin"] as!  String
                    let wordTranslation = anItem["wordTranslation"] as! String
                    let id = anItem["_id"] as! String
                    self.wordCards.append(wordOrigin+" - "+wordTranslation)
                    self.wordCardsIds.append(id)
                }
                DispatchQueue.main.async { // 2
                    self.talbeView.reloadData()
                }
            }
            task.resume()
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
        let wordOrigin = self.tbWordOrigin.text!
        let wordTranslation = self.tbWordTranslation.text!
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "wordOrigin="+wordOrigin+"&wordTranslation="+wordTranslation
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {// check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
            self.wordCards.append(wordOrigin+" - "+wordTranslation)
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            let jsonArr = json as! Dictionary<String, AnyObject>
            self.wordCardsIds.append(jsonArr["_id"] as! String)
            self.talbeView.reloadData()
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return wordCards.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "Cell",
                                              for: indexPath)
            cell.textLabel?.text = wordCards[indexPath.row]
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let selectedEl = indexPath[1]
        let alert = UIAlertController(title: "Deleting wordcard",
                                      message: "Do you really want to delete wordcard?",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Yes",
                                       style: .default) {
                                        [unowned self] action in
                                        var request = URLRequest(url: URL(string: self.urlString+"/"+self.wordCardsIds[selectedEl])!)
                                        request.httpMethod = "DELETE"
                                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                                            guard let data = data, error == nil else {// check for fundamental networking error
                                                print("error=\(error)")
                                                return
                                            }
                                            
                                            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                                                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                                                print("response = \(response)")
                                            }
                                            else{
                                                self.wordCardsIds.remove(at: selectedEl)
                                                self.wordCards.remove(at: selectedEl)
                                                self.talbeView.reloadData()
                                            }
                                            
                                            let responseString = String(data: data, encoding: .utf8)
                                            print("responseString = \(responseString)")
                                        }
                                        task.resume()
                                        
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
