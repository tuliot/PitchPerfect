//
//  Fast.swift
//  Pitch Perfect
//
//  Created by Tulio Troncoso on 7/9/16.
//
//

import Foundation
import UIKit

struct Fast: Modulator {
    
    /// Name of effect
    var name = "Fast"
    
    /// Rate of sound
    var rate: Float? = 1.5
    
    /// Pitch of sound
    var pitch: Float? = nil
    
    /// Echo
    var echo: Bool? = false
    
    /// Reverb
    var reverb: Bool? = false

    /// Image
    var image: UIImage? {
        return UIImage(named: "fast")
    }
}
