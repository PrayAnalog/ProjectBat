//
//  User.swift
//  ProjectBat
//
//  Created by prayanalog on 2017. 7. 17..
//  Copyright © 2017년 prayanalog. All rights reserved.
//

import UIKit

class User {
    var name: String
    var photo: String
    var win: String
    var lose: String
    var phoneNumber: String
    var alive: Bool
    var tier: String
    
    init?(name: String, photo: String, win: String, lose: String, phoneNumber:String, alive: Bool, tier: String) {
        self.name = name
        self.photo = photo
        self.win = win
        self.lose = lose
        self.phoneNumber = phoneNumber
        self.alive = alive
        self.tier = tier
    }
}
