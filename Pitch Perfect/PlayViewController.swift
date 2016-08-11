//
//  PlayViewController.swift
//  Pitch Perfect
//
//  Created by Tulio Troncoso on 7/9/16.
//
//

import UIKit
import AVFoundation

class PlayViewController: UIViewController {

    // MARK: Properties

    var audioEngine: AVAudioEngine!

    /// Button that pauses/resumes playback
    @IBOutlet weak var pauseButton: UIButton!

    /// Constraint that denotes spacing between the top of the pause button and the bottom of the screen
    @IBOutlet weak var pauseButtonConstraintTopToBottom: NSLayoutConstraint!

    /// Calculated property that returns the constant to use for the pauseButtonConstraintTopToBottom
    var pauseButtonContraintTopToBottomConstant: CGFloat {
        return ((isPlaying || isPaused) ? 70 : 0)
    }

    /// Bool that dictates wether or not playback is paused. Note: this will be false if the audio is stopped. Stopped != Paused
    var isPaused: Bool = false

    /// Audio file of the sound that the user recorded
    var audioFile: AVAudioFile!

    /// URL of the audio file
    var audioFileUrl: NSURL!

    /// This is the node that plays the sound
    var audioPlayerNode: AVAudioPlayerNode!

    /// This is a timer that starts immediately after a sound finishes playing. No other sounds will play while this timer is valid. It invalidates itself after one second
    var stopTimer: NSTimer!

    /// Modulator to use for the sound to play
    var currentModulator: Modulator!

    /// Calculated property that returns wether or not modulators should be enabled
    var shouldEnableModulators: Bool {
        if isPlaying && !isPaused{
            return false
        }
        return true
    }

    // TODO: Find a better solution for handling features
    /// This is a feature flag for enabling/disabling custom modulator creation
    var canCreateCustomModulators = false

    var isPlaying: Bool = false

    /// Calculated property that returns the image that should be used for the record button
    var pauseButtonImage: UIImage {
        return ((isPaused == true) ? UIImage(named: "Resume") : UIImage(named: "Pause"))!.imageWithRenderingMode(.AlwaysTemplate)
    }

    /// These are the sound modulators. They will populate the collectionview.
    var modulators: [Modulator] = [
        Normal(),
        Slow(),
        Fast(),
        Chipmunk(),
        Vader(),
        Echo(),
        Reverb(),
    ]

    var shouldShowPauseButton: Bool {
        return isPlaying
    }

    /// Collectionview that holds the modulators
    @IBOutlet weak var collectionView: UICollectionView!

    /// The reuse id of the addmodulator cell
    var kAddModulatorCellReuseId = "addModulatorCell"

    /// The reuse id of the modulator cell
    var kModulatorCellReuseId = "modulatorCell"


    // MARK: Functions


    override func viewDidLoad() {
        super.viewDidLoad()

        // If we don't have a file url, then we don't have audio to play
        guard ( audioFileUrl != nil ) else {

            showAlert(self, title: "Whoops", message: Alerts.AudioFileError)
            navigationController?.popViewControllerAnimated(true)
            return
        }

        do {
            audioFile = try AVAudioFile(forReading: audioFileUrl)
        } catch {
            showAlert(self, title: "Whoops", message: Alerts.AudioFileError)
        }
        print("Audio has been setup")

        pauseButton.imageView?.contentMode = .ScaleToFill
        pauseButton.setImage(pauseButtonImage, forState: .Normal)

        // Set the current modulator to some default value
        currentModulator = Normal()
    }

    override func viewWillDisappear(animated: Bool) {
        stopAudio()
    }

    // MARK: Audio Functions

    /**
     Plays the recorded sound with the selected modulator
     */
    func playSound() {
        let modulator = currentModulator

        // The following if... takes care of the case where the user had paused the audio, and now wants to continue playing it with the same modulator
        if self.audioEngine == nil || !self.audioEngine.running{
            // initialize audio engine components
            audioEngine = AVAudioEngine()

            // node for playing audio
            audioPlayerNode = AVAudioPlayerNode()
            audioEngine.attachNode(audioPlayerNode)

            // node for adjusting rate/pitch
            let changeRatePitchNode = AVAudioUnitTimePitch()
            if let pitch = modulator.pitch {
                changeRatePitchNode.pitch = pitch
            }
            if let rate = modulator.rate {
                changeRatePitchNode.rate = rate
            }
            audioEngine.attachNode(changeRatePitchNode)

            // node for echo
            let echoNode = AVAudioUnitDistortion()
            echoNode.loadFactoryPreset(.MultiEcho1)
            audioEngine.attachNode(echoNode)

            // node for reverb
            let reverbNode = AVAudioUnitReverb()
            reverbNode.loadFactoryPreset(.Cathedral)
            reverbNode.wetDryMix = 50
            audioEngine.attachNode(reverbNode)

            // connect nodes
            if modulator.echo == true && modulator.reverb == true {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
            } else if modulator.echo == true {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
            } else if modulator.reverb == true {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
            } else {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
            }

            audioPlayerNode.stop()
        }

        // Schedule to play and start the engine!
        audioPlayerNode.scheduleFile(audioFile, atTime: nil) {

            // If the sound is paused, then we don't want to schedule a timer. This is because then the timer will fire and call stopAudio() and kill the sound
            guard (!self.isPaused) else {
                return
            }

            var delayInSeconds: Double = 1

            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTimeForNodeTime(lastRenderTime) {
 
                if let rate = modulator.rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }

            // Schedule a stop timer for when audio finishes playing
            self.stopTimer = NSTimer(timeInterval: delayInSeconds, target: self, selector: #selector(PlayViewController.stopAudio), userInfo: nil, repeats: false)
            NSRunLoop.mainRunLoop().addTimer(self.stopTimer!, forMode: NSDefaultRunLoopMode)
        }

        if !audioEngine.running {
            do {
                try audioEngine.start()
            } catch {
                showAlert(self, title: Alerts.AudioEngineError, message: String(error))
                return
            }
        }

        // Play the recording!
        audioPlayerNode.play()
        isPlaying = true
        isPaused = false
        drawUI()
    }


    /**
     Connects a list of audio nodes to the audio engine

     - parameter nodes: AVAudioNode nodes
     */
    func connectAudioNodes(nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }

    /**
     Stops the current sound and kills the audio engine
     */
    func stopAudio() {

        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }

        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }

        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
        isPlaying = false;
        drawUI()
    }


    /**
     Handler for when the Pause/Resume button is clicked

     - parameter sender: sender
     */
    @IBAction func pauseButtonClicked(sender: AnyObject) {
        if (!isPaused) {
            isPaused = true
            audioPlayerNode.pause()
        } else {
            // The order of the following calls is important, do not alter them
            playSound()
            isPaused = false
        }
        drawUI()
    }



    func drawUI() {
        // Apply enabled/disabled state to cells
        setModulatorsEnabled(shouldEnableModulators)
        pauseButtonConstraintTopToBottom.constant = pauseButtonContraintTopToBottomConstant
        pauseButton.setImage(pauseButtonImage, forState: .Normal)
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }

    /**
     Enable/Disable modulators

     - parameter enabled: boolean
     */
    func setModulatorsEnabled(enabled: Bool) {
        let cells = self.collectionView.visibleCells()

        cells.forEach { (cell) in
            let modulatorCell = cell as! ModulatorCollectionViewCell
            modulatorCell.setEnabled(enabled)
        }
    }
    
}

extension PlayViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        var count = modulators.count

        // If custom modulators can be created, account for the 'Add Modulators' button
        count = count + ((canCreateCustomModulators == true) ? 1 : 0)

        return count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        /* 
            Remember that 4 modulators will return a count of 4, but since we start counting from item zero, indexPath.item will never be equal to modulators.count, but rather (modulators.count-1). When canCreateCustomModulators is true, it is not a modulator, but the numberOfItemsInSection will get incremented to account for the addModulator button. Thus increasing the max indexPath.item to (modulators.count-1)+1
         */

        // This won't run unless the canCreateCustomModulators is set, in which case the Add Modulator button will always be the last one, thus getting caught by this. 
        if (indexPath.item == modulators.count) {
            return
        }

        let modulator = modulators[indexPath.item]

        // Only play the sound if there isnt a sound playing right now.
        if !isPlaying || isPaused {

            if (modulator != currentModulator) {
                stopAudio()
            }

            currentModulator = modulator
            playSound()
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        if (indexPath.item == modulators.count) {
            // This cell is the addModulator cell
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kAddModulatorCellReuseId, forIndexPath: indexPath)

            cell.layer.borderWidth = 1.5
            cell.layer.borderColor = UIColor.blackColor().CGColor
            cell.layer.cornerRadius = cell.bounds.height / 2
            return cell;

        } else {
            // This cell is a modulator cell
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kModulatorCellReuseId, forIndexPath: indexPath) as! ModulatorCollectionViewCell
            let modulator = modulators[indexPath.item]
            cell.applyModulator(modulator)
            cell.setEnabled(shouldEnableModulators, animated: false)
            return cell;
        }
        
    }
    
}