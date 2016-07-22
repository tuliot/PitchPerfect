//
//  Modulator.swift
//  Pitch Perfect
//
//  Created by Tulio Troncoso on 7/9/16.
//
//

import Foundation

protocol Modulator {
    
    /// Name of effect
    var name: String { get }
    
    /// Rate of sound
    var rate: Float? { get }
    
    /// Pitch of sound
    var pitch: Float? { get }
    
    /// Echo
    var echo: Bool? { get }
    
    /// Reverb
    var reverb: Bool? { get }
}