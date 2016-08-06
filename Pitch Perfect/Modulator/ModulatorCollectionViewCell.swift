//
//  ModulatorCollectionViewCell.swift
//  Pitch Perfect
//
//  Created by Tulio Troncoso on 7/9/16.
//
//

import UIKit

class ModulatorCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = self.bounds.height / 2
        
    }

    /**
     Applies the modulator's name and image, if available

     - parameter modulator: modulator to apply
     */
    func applyModulator(modulator: Modulator) {

        // If the modulator has an image, use it
        if let image = modulator.image {
            self.imageView.image = image.imageWithRenderingMode(.AlwaysTemplate)
            nameLabel.text = ""
        } else {
            // Otherwise, use the name
            nameLabel.text = modulator.name
        }

    }

    /**
     Sets the enabled state of this cell.

     - parameter enabled: true if cell should be enabled, false otherwise
     */
    func setEnabled(enabled: Bool) {
        self.userInteractionEnabled = enabled

        let opacity: Float = ((enabled) ? 0.5 : 1.0)

        UIView.animateWithDuration(0.3) { 
            self.layer.opacity = opacity
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
}
