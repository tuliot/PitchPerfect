//
//  Alerts.swift
//  Pitch Perfect
//
//  Created by Tulio Troncoso on 8/11/16.
//
//

import Foundation
import UIKit

struct Alerts {
    static let DismissAlert = "Dismiss"
    static let RecordingDisabledTitle = "Recording Disabled"
    static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
    static let RecordingFailedTitle = "Recording Failed"
    static let RecordingFailedMessage = "Something went wrong with your recording."
    static let AudioRecorderError = "Audio Recorder Error"
    static let AudioSessionError = "Audio Session Error"
    static let AudioRecordingError = "Audio Recording Error"
    static let AudioFileError = "Audio File Error"
    static let AudioEngineError = "Audio Engine Error"
}

func showAlert(target: UIViewController, title: String, message: String, completion: (() -> Void)?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .Default, handler: nil))
    target.presentViewController(alert, animated: true, completion: nil)
}