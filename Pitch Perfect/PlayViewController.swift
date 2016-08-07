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

    var audioEngine: AVAudioEngine!

    @IBOutlet weak var pauseButton: UIButton!

    @IBOutlet weak var pauseButtonConstraintTopToBottom: NSLayoutConstraint!

    var pauseButtonContraintTopToBottomConstant: CGFloat {
        return ((isPlaying) ? 70 : 0)
    }

    var isPaused: Bool = false

    /// Audio file of the sound that the user recorded
    var audioFile: AVAudioFile!

    /// URL of the audio file
    var audioFileUrl: NSURL!

    /// This is the node that plays the sound
    var audioPlayerNode: AVAudioPlayerNode!

    /// This is a timer that starts immediately after a sound finishes playing. No other sounds will play while this timer is valid. It invalidates itself after one second
    var stopTimer: NSTimer!

    //TODO: Find a better solution for handling features
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
    
    @IBOutlet weak var collectionView: UICollectionView!

    /// The reuse id of the addmodulator cell
    var kAddModulatorCellReuseId = "addModulatorCell"

    /// The reuse id of the modulator cell
    var kModulatorCellReuseId = "modulatorCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if audioFileUrl != nil {
            do {
                audioFile = try AVAudioFile(forReading: audioFileUrl)
            } catch {
                //TODO: Show alert here
            }
            print("Audio has been setup")
        }

        pauseButton.imageView?.contentMode = .ScaleToFill
        pauseButton.setImage(pauseButtonImage, forState: .Normal)
    }

    override func viewWillDisappear(animated: Bool) {
        stopAudio()
    }

    // MARK: Audio Functions

    /**
     Plays the recorded sound with the selected modulator

     - parameter modulator: Modulator to use to alter the sound
     */
    func playSound(modulator: Modulator) {

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

        // schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, atTime: nil) {

            var delayInSeconds: Double = 1

            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTimeForNodeTime(lastRenderTime) {

                if let rate = modulator.rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }

            // schedule a stop timer for when audio finishes playing
            self.stopTimer = NSTimer(timeInterval: delayInSeconds, target: self, selector: #selector(PlayViewController.stopAudio), userInfo: nil, repeats: false)
            NSRunLoop.mainRunLoop().addTimer(self.stopTimer!, forMode: NSDefaultRunLoopMode)
        }

        do {
            try audioEngine.start()
        } catch {
            //TODO: Show alert here
//        showAlert(Alerts.AudioEngineError, message: String(error))
            return
        }

        // play the recording!
        audioPlayerNode.play()
        isPlaying = true;
        drawUI()
    }


    // MARK: Connect List of Audio Nodes
    func connectAudioNodes(nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }

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


    @IBAction func pauseButtonClicked(sender: AnyObject) {
        if (!isPaused) {
            audioPlayerNode.pause()
            pauseButton.setImage(UIImage(named: "Resume")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        } else {
            audioPlayerNode.play()
            pauseButton.setImage(UIImage(named: "Pause")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }

        isPaused = !isPaused
    }

    func drawUI() {
        // Apply enabled/disabled state to cells
        setModulatorsEnabled(!isPlaying)
        pauseButtonConstraintTopToBottom.constant = pauseButtonContraintTopToBottomConstant

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

        if (indexPath.item == modulators.count) {
            return
        }

        let modulator = modulators[indexPath.item]

        // Only play the sound if there isnt a sound playing right now.
        if !isPlaying {
            playSound(modulator)
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
            cell.setEnabled(!isPlaying, animated: false)
            return cell;
        }
        
    }
    
}