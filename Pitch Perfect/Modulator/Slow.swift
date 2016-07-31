//
//  Slow.swift
//  Pitch Perfect
//
//  Created by Tulio Troncoso on 7/9/16.
//
//

import Foundation
import UIKit

struct Slow: Modulator {
    
    /// Name of effect
    var name = "Slow"
    
    /// Rate of sound
    var rate: Float? = 0.5
    
    /// Pitch of sound
    var pitch: Float? = nil
    
    /// Echo
    var echo: Bool? = false
    
    /// Reverb
    var reverb: Bool? = false

    /// Image of a snail
    var image: UIImage? {
        return UIImage(named: "slow")
    }
}