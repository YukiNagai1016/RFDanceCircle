//
//  Users.swift
//  RFDanceCircle
//
//  Created by 優樹永井 on 2021/02/06.
//

import Foundation
import UIKit

class Users: NSObject {

    var userName: String
    var mail: String
    var attribute: String
    var point: Int
    var uid: String
    
    init(userName: String, mail: String, attribute: String, point: Int, uid: String) {
        self.userName = userName
        self.mail = mail
        self.attribute = attribute
        self.point = point
        self.uid = uid
    }
}
