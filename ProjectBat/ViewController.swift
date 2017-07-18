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

    @IBOutlet weak var loginButton: UIImageView!
    
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myUserNameLabel: UILabel!
    @IBOutlet weak var myWinLabel: UILabel!
    @IBOutlet weak var myLoseLabel: UILabel!
    @IBOutlet weak var myTierLabel: UILabel!
    
    
    var users = [User]()
    var reqName : String = ""
    var phoneNumber: String = ""
    var tier : Int = 0
    
    var myPhoneNumber: String = ""
    var name: String = ""
    
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
            if (key == id) {
                let value = item.object(forKey: key) as! NSDictionary
                let name = value.object(forKey: "name") as! String
                let photo = String(value.object(forKey: "icon") as! Int)
                let win = String(value.object(forKey: "win") as! Int)
                let lose = String(value.object(forKey: "lose") as! Int)
                let tier = String(value.object(forKey: "tier") as! Int)
                
                myImageView.image = UIImage(named: photo)
                myUserNameLabel.text = name
                myWinLabel.text = win + "승"
                myLoseLabel.text = lose + "패"
                myTierLabel.text = tier + "단"
                
                continue
            }
            let value = item.object(forKey: key) as! NSDictionary
            let name = value.object(forKey: "name") as! String
            let photo = String(value.object(forKey: "icon") as! Int)
            let win = String(value.object(forKey: "win") as! Int)
            let lose = String(value.object(forKey: "lose") as! Int)
            let tier = String(value.object(forKey: "tier") as! Int)
            
            guard let user0 = User(name: name, photo: photo, win: win, lose: lose, phoneNumber: key, alive: true, tier: tier) else { fatalError("Unable to instantiate meal0") }
//            print(key)
            users += [ user0 ]
            
        }
        
        self.userTableView.reloadData()
        
    }
    
    
    private func addHandlers(id: String, name: String) {
        self.myPhoneNumber = id
        self.name = name
        
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
                        vc.turnLabel.isHidden = true
                    }
                    vc.requester = phoneNumber
                    vc.isRequester = "false"
                    vc.myPhoneNumber = myPhoneNumber
                    vc.enemyPhoneNumber = phoneNumber
                    vc.socket = self.socket
                    vc.initRockImageView()
                    
                    for user in self.users {
                        if (user.phoneNumber == phoneNumber) {
                            vc.userImageView.image = UIImage(named: user.photo)
                            vc.userNameLabel.text = user.name
                            vc.userWinLabel.text = user.win + "승"
                            vc.userLoseLabel.text = user.lose + "패"
                            vc.userTierLabel.text = user.tier + "단"
                        }
                    }
                    
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
                        vc.turnLabel.isHidden = false
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

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTableView.delegate = self
        userTableView.dataSource = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        loginButton.isUserInteractionEnabled = true
        loginButton.addGestureRecognizer(tapGestureRecognizer)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        socket.removeAllHandlers()
        
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
            }
        })

//        self.addHandlers(id: myPhoneNumber, name: name)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
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
        cell.userWinLabel.text = user.win + "승"
        cell.userLoseLabel.text = user.lose + "패"
        cell.userImageView.image = UIImage(named: user.photo)
        cell.userTierLabel.text = user.tier + "단"
        
        cell.backgroundColor = UIColor(colorLiteralRed: Float(user.photo)!/25.0, green: Float(user.photo)!/25.0, blue: Float(user.photo)!/25.0, alpha: 0.3)
        
        //        cell.GameStartbutton.title = user.alive
        
        return cell
    }
    
    func connected(sender: UIButton) {
        print(users[sender.tag].name)
        
        let user = users[sender.tag]
        
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
                    vc.turnLabel.isHidden = true
                }
                vc.requester = myPhoneNumber
                vc.isRequester = "true"
                vc.myPhoneNumber = myPhoneNumber
                vc.enemyPhoneNumber = phoneNumber
                vc.socket = self.socket
                vc.initRockImageView()
                
                vc.userImageView.image = UIImage(named: user.photo)
                vc.userNameLabel.text = user.name
                vc.userWinLabel.text = user.win + "승"
                vc.userLoseLabel.text = user.lose + "패"
                vc.userTierLabel.text = user.tier + "단"
                
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
                        return
                    }
                    let row = (data[0] as! NSDictionary).object(forKey: "prev_row") as! String
                    let col = (data[0] as! NSDictionary).object(forKey: "prev_col") as! String
                    print(row, col)
                    vc.paintEnemyRock(x: Int(col)!, y: Int(row)!)
                    vc.myOrder = true
                    vc.turnLabel.isHidden = false
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

