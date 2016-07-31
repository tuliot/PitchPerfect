//
//  Reverb.swift
//  Pitch Perfect
//
//  Created by Tulio Troncoso on 7/9/16.
//
//

import Foundation
import UIKit

struct Reverb: Modulator {
    
    /// Name of effect
    var name = "Reverb"
    
    /// Rate of sound
    var rate: Float? = nil
    
    /// Pitch of sound
    var pitch: Float? = nil
    
    /// Echo
    var echo: Bool? = false
    
    /// Reverb
    var reverb: Bool? = true

    /// Image 
    var image: UIImage? {
        return UIImage(named: "reverb")
    }
}
