//
//  ViewController.swift
//  ProjectBat
//
//  Created by prayanalog on 2017. 7. 14..
//  Copyright © 2017년 prayanalog. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let socket = SocketIOClient(socketURL: URL(string: "http://52.79.188.97:3000/dev")!, config: [.log(true), .compress])

    @IBOutlet weak var loginStateLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var userTableView: UITableView!
    
    var users = [User]()
    var reqName : String = ""
    var phoneNumber: String = ""
    var tier : Int = 0
    
    var myPhoneNumber: String = ""
    
    struct customData : SocketData {
        let name: String
        let phoneNumber: String
        
        func socketRepresentation() -> SocketData {
            return ["name": name, "phoneNumber": phoneNumber]
        }
    }
    
    struct customData1 : SocketData {
        let requester: String
        
        func socketRepresentation() -> SocketData {
            return ["requester": requester]
        }
    }
    
    struct customData2 : SocketData {
        let to: String
        
        func socketRepresentation() -> SocketData {
            return ["to": to]
        }
    }
    
    
    private func loadUsers(data: [NSDictionary], id: String) {
        self.users = [User]()
        let item = data[0]
        let sortedKeys = (item.allKeys as! [String]).sorted(by: <) // ["a", "b"]
        for key in sortedKeys {
            print(key)
            print(item.object(forKey: key)!)
            if (key == id) {
                continue
            }
            
            guard let user0 = User(name: item.object(forKey: key) as! String, photo: nil, win: "1", lose:"2", phoneNumber: key, alive: true) else { fatalError("Unable to instantiate meal0") }
            
            users += [ user0 ]
            print(users.count)
            
            self.userTableView.reloadData()
        }
        
        
    }
    
    
    private func addHandlers(id: String, name: String) {
        self.myPhoneNumber = id
        
        socket.on("onlineList") {data, ack in
            self.loadUsers(data: data as! [NSDictionary], id: id)
        }
        
        
        socket.on("connect") {data, ack in
            print("id is ", id)
            self.socket.emit("sendPhoneNumber", customData(name: name, phoneNumber: id))
        }
        
        
        socket.on("reqGame") { data, ack in
            self.reqName = (data[0] as! NSDictionary).object(forKey: "name") as! String
            self.phoneNumber = (data[0] as! NSDictionary).object(forKey: "phoneNumber") as! String
            self.tier = (data[0] as! NSDictionary).object(forKey: "tier") as! Int
            
            
            print(self.reqName)
            print(self.phoneNumber)
            print(self.tier)
            
            
            
            let alert = UIAlertController(title: "Request Game", message: "\(self.reqName) request a game", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "거절", style: UIAlertActionStyle.default, handler: nil))
            
            
            self.socket.on("stopReqGame") { data, ack in
                print("startTurn here")
                let stopReqPhoneNumber = (data[0] as! NSDictionary).object(forKey: "phoneNumber") as! String
                if (self.phoneNumber == stopReqPhoneNumber) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
            
            self.socket.on("startTurn") { data, ack in
                alert.dismiss(animated: true, completion: nil)
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "gameScreen") as! GameViewController
                
                
                let phoneNumber = (data[0] as! NSDictionary).object(forKey: "enemyPhoneNumber") as! String
                let myPhoneNumber = self.myPhoneNumber
                
                self.present(vc, animated: true, completion: {
                    print(myPhoneNumber)
                    print((data[0] as! NSDictionary).object(forKey: "black") as! String)
                    if ((data[0] as! NSDictionary).object(forKey: "black") as! String) != myPhoneNumber {
                        
                        vc.userColor = UIColor.white
                        vc.enemyColor = UIColor.black
                    } else {
                        vc.userColor = UIColor.black
                        vc.enemyColor = UIColor.white
                    }
                    
                    if ((data[0] as! NSDictionary).object(forKey: "turn") as! Int) == 0 {
                        vc.myOrder = false
                    }
                    vc.requester = phoneNumber
                    vc.isRequester = "false"
                    vc.myPhoneNumber = myPhoneNumber
                    vc.enemyPhoneNumber = phoneNumber
                    vc.socket = self.socket
                    vc.initRockImageView()
                    
                    vc.socket.on("swap") {data, ack in
                        print("why here?")
                        //                    if ((data[0] as! NSDictionary).object(forKey: "remainChangeTurn") as! Int) == 6 {
                        let tempColor = vc.userColor
                        vc.userColor = vc.enemyColor
                        vc.enemyColor = tempColor
                        print("swap message")
                        //                    }
                    }
                    
                    vc.socket.on("nextTurn") {data, ack in
                        let turn = (data[0] as! NSDictionary).object(forKey: "turn") as! Int
                        if (turn == 0) {
                            return
                        }
                        let row = (data[0] as! NSDictionary).object(forKey: "prev_row") as! String
                        let col = (data[0] as! NSDictionary).object(forKey: "prev_col") as! String
                        print(row, col)
                        vc.paintEnemyRock(x: Int(col)!, y: Int(row)!)
                        vc.myOrder = true
                    }
                    
                    vc.socket.on("endGame") { data, ack in
                        if ((data[0] as! NSDictionary).object(forKey: "winner") as! String) == vc.myPhoneNumber {
                            vc.gameEnd(message: "You win")
                        } else {
                            vc.gameEnd(message: "You Lose")
                        }
                    }
                })
                

            }
            
            alert.addAction(UIAlertAction(title: "수락", style: UIAlertActionStyle.default, handler: { action in
                self.socket.emit("allowGame", customData1(requester: self.phoneNumber))
            }))
            
            self.present(alert, animated: true, completion: nil)

        }
        
        socket.on("alert") {data, ack in
            print(data)
        }
//        socket.on("nextTurn") {data, ack in
//            let row = (data[0] as! NSDictionary).object(forKey: "prev_row") as! String
//            let col = (data[0] as! NSDictionary).object(forKey: "prev_col") as! String
//            print(row, col)
//         
//        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTableView.delegate = self
        userTableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
        
        KOSessionTask.meTask(completionHandler: { (profile , error) -> Void in
            if profile != nil {
                print("logged in state")
                let kakao : KOUser = profile as! KOUser
                print(kakao.id)
                let value = kakao.properties?["nickname"] as! String
                print(value)

                self.addHandlers(id: String(describing: kakao.id!), name: value)
                self.socket.connect()
//                if let value = kakao.properties["profile_image"] as? String{
//                    self.imageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: value)!)!)
//                }
//                if let value = kakao.properties["thumbnail_image"] as? String{
//                    self.image2View.image = UIImage(data: NSData(contentsOfURL: NSURL(string: value)!)!)
//                }
                
                self.loginButton.isHidden = true
            } else {
                print("not logged in state")
                self.userTableView.isHidden = true
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
                        self.userTableView.isHidden = false
                        
                        KOSessionTask.meTask(completionHandler: { (profile , error) -> Void in
                            if profile != nil {
                                print("logged in state")
                                let kakao : KOUser = profile as! KOUser
                                print(kakao.id)
                                let value = kakao.properties?["nickname"] as! String
                                print(value)
                                
                                self.addHandlers(id: String(describing: kakao.id!), name: value)
                                self.socket.connect()
                                
                                
                                self.loginButton.isHidden = true
                            } else {
                                print("not logged in state")
                                self.userTableView.isHidden = true
                                self.loginStateLabel.isHidden = true
                            }
                        })
                        
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
    
    
//    private func loadSampleUsers() {
//        let photo0 = UIImage(named: "meal0")
//        let photo1 = UIImage(named: "meal1")
//        let photo2 = UIImage(named: "meal2")
//        
//        guard let user0 = User(name: "Caprese Salad", photo: photo0, win: "3", lose:"4", phoneNumber: "123456789", alive: true) else { fatalError("Unable to instantiate meal0") }
//        guard let user1 = User(name: "Chicken and Potatoes", photo: photo1, win: "6", lose:"2", phoneNumber: "34754635", alive: true) else { fatalError("Unable to instantiate meal1") }
//        guard let user2 = User(name: "Pasta with Meatballs", photo: photo2, win: "9", lose:"1", phoneNumber: "234567685", alive: false) else { fatalError("Unable to instantiate meal2") }
//        
//        users += [ user0, user1, user2 ]
//        
//    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        
        socket.emit("reqGame", customData2(to: self.users[sender.tag].phoneNumber))
        
        let alert = UIAlertController(title: "Request Game", message: "request \(users[sender.tag].name) a game", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.default, handler: { action in
            self.socket.emit("stopReqGame", customData2(to: self.users[sender.tag].phoneNumber))
        }))
        self.present(alert, animated: true, completion: nil)

        
        socket.on("startTurn") { data, ack in
            alert.dismiss(animated: true, completion: nil)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "gameScreen") as! GameViewController
            
            let phoneNumber = self.users[sender.tag].phoneNumber
            let myPhoneNumber = self.myPhoneNumber
            self.present(vc, animated: true, completion: {
                if ((data[0] as! NSDictionary).object(forKey: "black") as! String) != self.myPhoneNumber {
                    vc.userColor = UIColor.white
                    vc.enemyColor = UIColor.black
                }
                
                if ((data[0] as! NSDictionary).object(forKey: "turn") as! Int) == 1 {
                    vc.myOrder = false
                }
                vc.requester = myPhoneNumber
                vc.isRequester = "true"
                vc.myPhoneNumber = myPhoneNumber
                vc.enemyPhoneNumber = phoneNumber
                vc.socket = self.socket
                vc.initRockImageView()
                
                vc.socket.on("swap") {data, ack in
//                    if ((data[0] as! NSDictionary).object(forKey: "remainChangeTurn") as! Int) == 6 {
                    let tempColor = vc.userColor
                    vc.userColor = vc.enemyColor
                    vc.enemyColor = tempColor
                    print("swap message")
//                    }
                }
                
                vc.socket.on("nextTurn") {data, ack in
                    
                    let turn = (data[0] as! NSDictionary).object(forKey: "turn") as! Int
                    if (turn == 1) {
//                        vc.myOrder = true
                        return
                    }
                    let row = (data[0] as! NSDictionary).object(forKey: "prev_row") as! String
                    let col = (data[0] as! NSDictionary).object(forKey: "prev_col") as! String
                    print(row, col)
                    vc.paintEnemyRock(x: Int(col)!, y: Int(row)!)
                    vc.myOrder = true
                }
                
                vc.socket.on("endGame") { data, ack in
                    if ((data[0] as! NSDictionary).object(forKey: "winner") as! String) == vc.myPhoneNumber {
                        vc.gameEnd(message: "You Win")
                    } else {
                        vc.gameEnd(message: "You Lose")
                    }
                }
                
                vc.socket.on("escapeGame") {data, ack in
                    vc.escapeGame()
                }
            })
            
        }
        
    }
    

    

}

