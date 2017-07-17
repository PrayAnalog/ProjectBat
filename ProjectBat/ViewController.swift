//
//  ViewController.swift
//  ProjectBat
//
//  Created by prayanalog on 2017. 7. 14..
//  Copyright © 2017년 prayanalog. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var loginStateLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var userTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTableView.delegate = self
        userTableView.dataSource = self
        
        loadSampleUsers()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        KOSessionTask.accessTokenInfoTask(completionHandler: { (result, error) in
            if error == nil {
                print("logged in state")
                print(result!.id)
                self.loginButton.isHidden = true
            } else {
                print("not logged in state")
                self.loginStateLabel.isHidden = true
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginKakao(_ sender: UIButton) {
        let session = KOSession.shared()
        // 로그인 세션이 생성 되었으면
        if let s = session {
            print(KOSessionState.open.rawValue)
            // 이전 열린 세션은 닫고
            if s.isOpen() {
                s.close()
            }
            s.open(completionHandler: { (error) in
                // 에러가 없으면
                if error == nil {
                    print("No error")
                    // 로그인 성공
                    if s.isOpen() {
                        print("Success")
                        self.loginButton.isHidden = true
                        self.loginStateLabel.isHidden = false
                        
                    }
                    
                    // 로그인 실패
                    else {
                        print("Fail")
                    }
                }
                
                // 로그인 에러
                else {
                    print("Error login: \(error!)")
                }
            })
        }
        // 로그인 세션 생성 실패
        else {
            print("Something wrong")

        }
    }
    
    var users = [User]()
    
    private func getUserInformation() {
        // send api call
        // make user class
        
        // insert them into users list
    }
    
    private func loadSampleUsers() {
        let photo0 = UIImage(named: "meal0")
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        
        guard let user0 = User(name: "Caprese Salad", photo: photo0, win: "3", lose:"4", alive: true) else { fatalError("Unable to instantiate meal0") }
        guard let user1 = User(name: "Chicken and Potatoes", photo: photo1, win: "6", lose:"2", alive: true) else { fatalError("Unable to instantiate meal1") }
        guard let user2 = User(name: "Pasta with Meatballs", photo: photo2, win: "9", lose:"1", alive: false) else { fatalError("Unable to instantiate meal2") }
        
        users += [ user0, user1, user2 ]
        
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UserTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserTableViewCell else { fatalError ( "The dequeued cell is not an instance of UserTableViewCell." ) }
        
        let user = users[indexPath.row]
        
        cell.userGameStartButton.tag = indexPath.row
        cell.userGameStartButton!.addTarget(self, action: #selector(self.connected(sender:)), for: .touchUpInside)
        
        cell.userNameLabel.text = user.name
        cell.userWinLabel.text = user.win
        cell.userLoseLabel.text = user.lose
        cell.userImageView.image = user.photo
        if (user.alive) {
            cell.userGameStartButton.setTitle("Start", for: .normal)
        } else {
            cell.userGameStartButton.setTitle("Offline", for: .disabled)
        }
        //        cell.GameStartbutton.title = user.alive
        
        return cell
    }
    
    func connected(sender: UIButton) {
        print(users[sender.tag].name)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "gameScreen") as! GameViewController
        self.present(vc, animated: true, completion: nil)
        
        // send request for something
    }
    

    

}

