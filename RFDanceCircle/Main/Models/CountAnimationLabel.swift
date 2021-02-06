//
//  CountAnimationLabel.swift
//  RFDanceCircle
//
//  Created by 優樹永井 on 2021/02/06.
//

import Foundation
import UIKit

class CountAnimationLabel: UILabel {
    
    var startTime: CFTimeInterval!
    
    var fromValue: Int!
    var toValue: Int!
    var duration: TimeInterval!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialSetup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialSetup()
    }
    
    init() {
        super.init(frame: .zero)
        
        initialSetup()
    }
    
    private func initialSetup() {
        textAlignment = .right
    }
    
    func animate(from fromValue: Int, to toValue: Int, duration: TimeInterval) {
        text = "\(fromValue)"
        
        self.startTime = CACurrentMediaTime()
        
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        
        let link = CADisplayLink(target: self, selector: #selector(updateValue))
        link.add(to: .current, forMode: .common)
    }
    
    @objc func updateValue(link: CADisplayLink) {
        let dt = (link.timestamp - self.startTime) / duration
        if dt >= 1.0 {
            text = "\(toValue!)"
            link.invalidate()
            return
        }
        let current = Int(Double(toValue - fromValue) * dt) + fromValue
        text = "\(current)"
        
        //print("\(link.timestamp), \(link.targetTimestamp)")
    }
}
