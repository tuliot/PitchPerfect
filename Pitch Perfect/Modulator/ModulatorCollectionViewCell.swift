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
//        self.backgroundColor = UIColor.pitchAccent()
        self.nameLabel.textColor = UIColor.whiteColor()
//        self.layer.borderWidth = 1.5
//        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.cornerRadius = self.bounds.height / 2
    }

    @IBOutlet weak var nameLabel: UILabel!
    
}
