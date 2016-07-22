//
//  ViewController.swift
//  Pitch Perfect
//
//  Created by Tulio Troncoso on 7/9/16.
//
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: properties
    /// Button that starts/stops the voice recording
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    
    // MARK: Audio properties
    
    /// The audio session
    var recordSession: AVAudioSession!
    
    /// The audio recorder
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init audio recording things
        recordSession = AVAudioSession.sharedInstance()
        
        // Hide the record button, until we have permission
        recordButton.hidden = true
        
        getRecordingPermission()
        
        // Hide the done button, since we dont want it to appear until after recording
        doneButton.hidden = true
    }
    
    /**
        Figures out if this app has permission to record
        
        - Returns: true if recording is allowed, false otherwise
     */
    func getRecordingPermission() -> Bool {
        do {
            try recordSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordSession.setActive(true)
            recordSession.requestRecordPermission() { (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        self.recordButton.hidden = false
                    }
                }
            }
        } catch {
            return false
        }
        
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Handles the pressing of the record button
     */
    @IBAction func buttonPress(sender: AnyObject) {
        if audioRecorder == nil {
            startRecording()
        } else {
            stopRecording(true)
        }
    }
    
    /// Starts recording
    func startRecording() {
        
        let filePathUrl = getFilePath()
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: filePathUrl, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setTitle("Stop recording", forState: .Normal)
        } catch {
            stopRecording(false)
        }
    }
    
    /** 
        Stops recording
        
        - Parameters:
            - success: Wether or not recording was successful
    */
    func stopRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.setTitle("Re-record", forState: .Normal)
            doneButton.hidden = false
        } else {
            recordButton.setTitle("Record", forState: .Normal)
        }
    }
   
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopRecording(false)
        }
    }
    
    /**
        Gets the file path to save the audio recording to
     
        - Returns: an NSURL with the filepath
    */
    func getFilePath() -> NSURL {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        let recordingName = "recording.m4a"
        let pathArray = [documentsDirectory, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        return filePath!
    }
}