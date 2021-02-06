//
//  Points.swift
//  RFDanceCircle
//
//  Created by 優樹永井 on 2021/02/06.
//

import Foundation
import UIKit

class Points: NSObject {

    var user: String = ""
    var date: String = ""
    
    init(user: String, date: String) {
        self.user = user
        self.date = date
    }
}
