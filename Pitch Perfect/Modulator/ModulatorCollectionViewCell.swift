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
        self.nameLabel.textColor = UIColor.whiteColor()
        self.layer.cornerRadius = self.bounds.height / 2
    }

    @IBOutlet weak var nameLabel: UILabel!
    
}
