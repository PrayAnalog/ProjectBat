//
//  GameViewController.swift
//  ProjectBat
//
//  Created by prayanalog on 2017. 7. 17..
//  Copyright © 2017년 prayanalog. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var gameEndView: UIView!
    @IBOutlet weak var gameResultLabel: UILabel!
    
    @IBOutlet weak var rock0ImageView: UIImageView!
    @IBOutlet weak var rock1ImageView: UIImageView!
    @IBOutlet weak var rock2ImageView: UIImageView!
    @IBOutlet weak var rock3ImageView: UIImageView!
    @IBOutlet weak var rock4ImageView: UIImageView!
    public var rock5Image: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initRockImageView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showMoreActions(_:)))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
        
        
        // Do any additional setup after loading the view.
    }
    
    func initRockImageView() {
        if (userColor == UIColor.black) {
            rock0ImageView.image = UIImage(named: "go_black")
            rock1ImageView.image = UIImage(named: "go_black")
            rock2ImageView.image = UIImage(named: "go_black")
            rock3ImageView.image = UIImage(named: "go_white")
            rock4ImageView.image = UIImage(named: "go_white")
            rock5Image = UIImage(named: "go_white")!
        }
        else {
            rock0ImageView.image = UIImage(named: "go_white")
            rock1ImageView.image = UIImage(named: "go_white")
            rock2ImageView.image = UIImage(named: "go_white")
            rock3ImageView.image = UIImage(named: "go_black")
            rock4ImageView.image = UIImage(named: "go_black")
            rock5Image = UIImage(named: "go_black")!
        }
    }
    
    func RockImageViewMove() {
        var tempImage: UIImage!
        tempImage = rock0ImageView.image
        rock0ImageView.image = rock1ImageView.image
        rock1ImageView.image = rock2ImageView.image
        rock2ImageView.image = rock3ImageView.image
        rock3ImageView.image = rock4ImageView.image
        rock4ImageView.image = rock5Image
        rock5Image = tempImage
        
    }
    
    // width = 30, 346, 18 columns
    // height = 207, 525, 18 rows
    let x0 : Float = 30.0
    let x18 : Float = 346
    let y0 : Float = 207
    let y18 : Float = 525
    let length : Float = 17.55
    
    var userColor : UIColor = UIColor.black
    var enemyColor : UIColor = UIColor.white
    var tempPositionX : Int = -1
    var tempPositionY : Int = -1
    var myOrder : Bool = true
    var rockExist : [(Int, Int)] = []
    var DynamicTempView = UIView(frame: CGRect(x: -1, y: -1, width: 12.0, height: 12.0))
    
    
    // 0,0 ~ 18,18
    // 17.55
    

    func showMoreActions(_ touch: UITapGestureRecognizer) {
        if (!myOrder) {
            return
        }
        
        let touchPoint = touch.location(in: self.view)
        let cgX : CGFloat = touchPoint.x
        let cgY : CGFloat = touchPoint.y
        let x = Float(cgX)
        let y = Float(cgY)
        
        var rockX:Int
        var rockY:Int
        
        print(x, y)
        if (x < x0 || x > x18 || y < y0 || y > y18) {
            return
        }
        
        rockX = Int((x - x0 + 6) / length)
        rockY = Int((y - y0 + 6) / length)
        let tempTuple = (rockX, rockY)
        if (rockExist.contains(where: {$0 == tempTuple})) {
            return
        }
        
        DynamicTempView.layer.cornerRadius = 6
        DynamicTempView.layer.borderWidth = 0
        if (userColor == UIColor.black) {
            DynamicTempView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        } else {
            DynamicTempView.backgroundColor = UIColor(white: 1.0, alpha: 0.4)
        }
        
        
        print(rockX, rockY)
        
        let positionX : CGFloat = CGFloat(rockX) * CGFloat(length) + CGFloat(x0) - 7.0
        let positionY : CGFloat = CGFloat(rockY) * CGFloat(length) + CGFloat(y0) - 7.0
        
        if (tempPositionX == rockX && tempPositionY == rockY) {
            let DynamicView = UIView(frame: CGRect(x: positionX, y: positionY, width: 12.0, height: 12.0))
            
            DynamicView.backgroundColor = userColor
            DynamicView.layer.cornerRadius = 6
            DynamicView.layer.borderWidth = 0
            self.view.addSubview(DynamicView)
            self.RockImageViewMove()
            rockExist.append((rockX, rockY))
            DynamicTempView.removeFromSuperview()
        } else {
            tempPositionX = rockX
            tempPositionY = rockY
            DynamicTempView.frame.origin.x = positionX
            DynamicTempView.frame.origin.y = positionY
            self.view.addSubview(DynamicTempView)
        }
        
    }
    
    func paintEnemyRock(x: Int, y: Int) {
        if (tempPositionX == x && tempPositionY == y) {
            DynamicTempView.removeFromSuperview()
        }
        
        let positionX = CGFloat(x) * CGFloat(length) + CGFloat(x0) - 7.0
        let positionY = CGFloat(y) * CGFloat(length) + CGFloat(x0) - 7.0
        
        let DynamicView = UIView(frame: CGRect(x: positionX, y: positionY, width: 12.0, height: 12.0))
        
        DynamicView.backgroundColor = enemyColor
        DynamicView.layer.cornerRadius = 6
        DynamicView.layer.borderWidth = 0
        self.view.addSubview(DynamicView)
        
    }
    
    @IBAction func stopGame(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func endGame(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func gameEnd() {
        gameEndView.layer.anchorPointZ = -1.0
        gameEndView.isHidden = false
        gameResultLabel.text = "You Win"
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}