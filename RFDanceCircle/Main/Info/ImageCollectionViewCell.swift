//  RFDanceCircle
//
//  Created by 優樹永井 on 2021/02/06.
//

import UIKit
import Gemini

final class ImageCollectionViewCell: GeminiCell {
    @IBOutlet private weak var blackShadowView: UIView!
    @IBOutlet private weak var sampleImageView: UIImageView!

    override var shadowView: UIView? {
        return blackShadowView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
    }

    func configure(with image: UIImage) {
        sampleImageView.image = image
    }
}
