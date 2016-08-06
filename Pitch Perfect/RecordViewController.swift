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
    
    @IBOutlet weak var statusLabel: UILabel!

    var isRecording: Bool = false

    /// If there is the user has a recording that he can use
    var didRecord: Bool = false

    /// Calculated property that returns the image that should be used for the record button
    var recordButtonImage: UIImage {
        return ((isRecording == true) ? UIImage(named: "Stop") : UIImage(named: "Microphone"))!.imageWithRenderingMode(.AlwaysTemplate)
    }

    /// Calculated property that returns the text that should be used for the label
    var labelText: String {

        if (isRecording) {
            return "Recording in progress..."
        } else {
            if (didRecord) {
                return "Successfully recorded audio."
            }
        }

        return ""
    }

    var shouldHideDoneButton: Bool {
        return isRecording == true
    }

    // MARK: Audio properties
    
    /// The audio session
    var recordSession: AVAudioSession!
    
    /// The audio recorder
    var audioRecorder: AVAudioRecorder!

    /// URL of the audio file
    var audioFileUrl: NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init audio recording things
        recordSession = AVAudioSession.sharedInstance()
        
        // Hide the record button, until we have permission
        recordButton.hidden = true
        
        getRecordingPermission()

        drawUI()
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

    func drawUI() {
        dispatch_async(dispatch_get_main_queue(), {
            self.recordButton.setImage(self.recordButtonImage, forState: .Normal)
            self.doneButton.hidden = self.shouldHideDoneButton
            self.statusLabel.text = self.labelText
        })
    }

    /// Handles the pressing of the record button
    @IBAction func buttonPress(sender: AnyObject) {
        if audioRecorder == nil {
            startRecording()
        } else {
            stopRecording(true)
        }
    }
    
    /// Starts recording
    func startRecording() {
        
        audioFileUrl = getFilePath()
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: audioFileUrl, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            isRecording = true
        } catch {
            stopRecording(false)
        }

        drawUI()
    }

    /** 
        Stops recording
        
        - Parameters:
            - success: Wether or not recording was successful
    */
    func stopRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        isRecording = false
        didRecord = true
        drawUI()
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PlayViewController {
            vc.audioFileUrl = self.audioFileUrl
        }
    }
}