//
//  Normal.swift
//  Pitch Perfect
//
//  Created by Tulio Troncoso on 7/9/16.
//
//

import Foundation
import UIKit

struct Normal: Modulator {

    /// Name of effect
    var name = "Normal"

    /// Rate of sound
    var rate: Float? = nil

    /// Pitch of sound
    var pitch: Float? = nil

    /// Echo
    var echo: Bool? = nil

    /// Reverb
    var reverb: Bool? = nil
}
