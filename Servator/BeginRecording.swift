//
//  BeginRecording.swift
//  Servator
//
//  Created by Matt Gleason on 1/4/21.
//

import UIKit
import AVFoundation

class BeginRecording: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @IBOutlet weak var stopViewButton: UIView!
    @IBOutlet weak var playViewButton: UIView!
    @IBOutlet weak var recordViewButton: UIView!
    @IBOutlet weak var allRecordingViewButton: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topView: UIView!
    
    
    
    @IBOutlet weak var topText: UILabel!
    
    var audioPlayer : AVAudioPlayer?
    var audioRecorder : AVAudioRecorder?
    var recordingSession: AVAudioSession?
    
    var audioURL: URL?


    override func viewDidLoad() {
        super.viewDidLoad()
        createLayout()
        addGradient()
        

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            guard let availableInputs = session.availableInputs,
                  let builtInMicInput = availableInputs.first(where: { $0.portType == .builtInMic }) else {
                    print("The device must have a built-in microphone.")
                    return
                }
                
                // Make the built-in microphone input the preferred input.
            do {
                try session.setPreferredInput(builtInMicInput)
            } catch {
                print("Unable to set the built-in mic as the preferred input.")
            }
            try session.setActive(true)
            session.requestRecordPermission({ [weak self] allowed in
                guard let self = self else { return }
                if allowed == false {
                    self.settingsAlert()
                }
            })
            createButtons()
            startRecording()
            
        } catch {
            debugPrint("error setting up AVAudioSession")
        }

            
    }
    
    func createButtons() {
        let stopGesture = UITapGestureRecognizer(target: self, action:  #selector(self.stopAudio))
        stopViewButton.addGestureRecognizer(stopGesture)
        
        let playGesture = UITapGestureRecognizer(target: self, action:  #selector(self.playAudio))
        playViewButton.addGestureRecognizer(playGesture)
        
        let recordGesture = UITapGestureRecognizer(target: self, action:  #selector(self.recordAudio))
        recordViewButton.addGestureRecognizer(recordGesture)
        
        let recordingsGesture = UITapGestureRecognizer(target: self, action:  #selector(self.goToAllRecordings))
        allRecordingViewButton.addGestureRecognizer(recordingsGesture)
    }
    
    func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.topView.bounds
        gradientLayer.colors = [#colorLiteral(red: 0.4962245968, green: 0.4269699434, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0.645699501, green: 0.5257949233, blue: 0.9328801036, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.topView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func createLayout() {
        let properties = [stopViewButton, recordViewButton, playViewButton, allRecordingViewButton, containerView]
        for property in properties {
            property?.isUserInteractionEnabled = true
            property?.layer.cornerRadius = 4
            property?.layer.shadowColor = UIColor.black.cgColor
            property?.layer.shadowOpacity = 0.3
            property?.layer.shadowOffset = .zero
            property?.layer.shadowRadius = 4
        }
        
        playViewButton.isHidden = true
        recordViewButton.isHidden = true
        stopViewButton.frame = CGRect(x: 8, y: 23, width: 280, height: 359)  // to change
    }
    
    func settingsAlert() {
        let alert = UIAlertController(title: "Microphone access required to get the audio of your surroundings", message: "Please allow microphone access", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: {action in

                    // open the app permission in Settings app
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

                
        alert.addAction(cancelAction)
        alert.addAction(settingsAction)
              
        alert.preferredAction = settingsAction

        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc func recordAudio(_ sender: UITapGestureRecognizer) {
        playViewButton.isUserInteractionEnabled = false
        stopViewButton.isUserInteractionEnabled = true
        topText.text = "Your Surroundings\nAre Now Being\nRecorded"
        
        startRecording()
        
    }
    
    func startRecording() {
        print("Started Recording")
        let dateName = getDate()
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(dateName).m4a")
        
        let recordingSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVLinearPCMIsNonInterleaved: false,
            AVSampleRateKey: 44_100.0,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: recordingSettings)
            audioURL = audioFilename
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
        } catch {
            audioRecorder = nil
            debugPrint("Problem recording audio: \(error.localizedDescription)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func findPath(file: String) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            if let pathComponent = url.appendingPathComponent(file) {
                let filePath = pathComponent.path
                let fileManager = FileManager.default
                return fileManager.fileExists(atPath: filePath)
            } else {
                return true
            }
    }

    @objc func stopAudio(_ sender: UITapGestureRecognizer) {
        if playViewButton.isHidden {
            stopViewButton.frame = CGRect(x: 8, y: 23, width: 280, height: 83)
            
            playViewButton.isHidden = false
            recordViewButton.isHidden = false
        }
        
        topText.text = "Recording has\nbeen Stopped"
        
        stopViewButton.isUserInteractionEnabled = false
        playViewButton.isUserInteractionEnabled = true
        recordViewButton.isUserInteractionEnabled = true

        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
            print("Stopped Recording")
        } else {
            audioPlayer?.stop()
            print("Stopped audio")
        }
    }

    @objc func playAudio(_ sender: UITapGestureRecognizer) {
        if audioRecorder?.isRecording == false {
            stopViewButton.isUserInteractionEnabled = true
            recordViewButton.isUserInteractionEnabled = false

            do {
                try audioPlayer = AVAudioPlayer(contentsOf:
                        (audioRecorder?.url)!)
                audioPlayer!.delegate = self
                audioPlayer!.prepareToPlay()
                audioPlayer!.volume = 1.0
                audioPlayer!.play()
                print("Began playing back audio")
            } catch let error as NSError {
                print("audioPlayer error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func goToAllRecordings(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "toRecordingsTable", sender: self)
    }
    
    func getDate() -> String {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        let date = formatter.string(from: currentDate)
        
        return date
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordViewButton.isUserInteractionEnabled = true
        stopViewButton.isUserInteractionEnabled = false
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio Play Decode Error")
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio Record Encode Error")
    }

}
