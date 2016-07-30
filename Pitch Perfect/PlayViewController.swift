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
    
    var audioFile: AVAudioFile!
    
    var recordedAudioURL: NSURL!
    
    var audioPlayerNode: AVAudioPlayerNode!
    
    var stopTimer: NSTimer!
    
    /// The audio player
    var recording: AVAudioPlayer!

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
    
    @IBOutlet weak var collectionView: UICollectionView!

    /// The reuse id of the addmodulator cell
    var kAddModulatorCellReuseId = "addModulatorCell"

    /// The reuse id of the modulator cell
    var kModulatorCellReuseId = "modulatorCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordedAudioURL = getFilePath()
        setupAudio()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    // MARK: Audio Functions

    func setupAudio() {
        // initialize (recording) audio file
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL)
        } catch {
            //            showAlert(Alerts.AudioFileError, message: String(error))
        }
        print("Audio has been setup")
    }

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

            var delayInSeconds: Double = 0

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
//        showAlert(Alerts.AudioEngineError, message: String(error))
            return
        }

        // play the recording!
        audioPlayerNode.play()
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
    }


}

extension PlayViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modulators.count + 1 // The +1 accounts for the 'add modulator' cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if (indexPath.item == modulators.count) {
            return
        }

        let modulator = modulators[indexPath.item]

        // Only play the sound if there isnt a sound playing right now.
        if stopTimer == nil  || !stopTimer.valid{
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
            cell.nameLabel.text = modulator.name

            return cell;
        }
        
    }
    
}