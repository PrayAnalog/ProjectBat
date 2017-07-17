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
    var photo: UIImage?
    var win: String
    var lose: String
    var alive: Bool
    
    init?(name: String, photo: UIImage?, win: String, lose: String, alive: Bool) {
        self.name = name
        self.photo = photo
        self.win = win
        self.lose = lose
        self.alive = alive
    }
}
