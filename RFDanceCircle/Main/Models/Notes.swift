//
//  Notes.swift
//  RFDanceCircle
//
//  Created by 優樹永井 on 2021/02/06.
//

import Foundation
import UIKit

class Notes: NSObject {

    var date: String = ""
    var note: String = ""
    
    init(date: String, note: String) {
        self.date = date
        self.note = note
    }
}
