//
//  Echo.swift
//  Pitch Perfect
//
//  Created by Tulio Troncoso on 7/9/16.
//
//

import Foundation
import UIKit

struct Echo: Modulator {
    
    /// Name of effect
    var name = "Echo"
    
    /// Rate of sound
    var rate: Float? = nil
    
    /// Pitch of sound
    var pitch: Float? = nil
    
    /// Echo
    var echo: Bool? = true
    
    /// Reverb
    var reverb: Bool? = false
}
