//
//  TimeLineTableViewCell.swift
//  RFDanceCircle
//
//  Created by 優樹永井 on 2021/02/06.
//

import UIKit

class TimeLineTableViewCell: UITableViewCell {

    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var sortLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var uidLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        userImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
