//
//  Chipmunk.swift
//  Pitch Perfect
//
//  Created by Tulio Troncoso on 7/9/16.
//
//

import Foundation
import UIKit

struct Chipmunk: Modulator {
    
    /// Name of effect
    var name = "Chipmunk"
    
    /// Rate of sound
    var rate: Float? = nil
    
    /// Pitch of sound
    var pitch: Float? = 1000
    
    /// Echo
    var echo: Bool? = false
    
    /// Reverb
    var reverb: Bool? = false

    /// Image
    var image: UIImage? {
        return UIImage(named: "chipmunk")
    }
}
