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

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
}
