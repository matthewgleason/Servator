//
//  RecordingCellView.swift
//  Servator
//
//  Created by Matt Gleason on 1/11/21.
//

import Foundation
import UIKit
import AVFoundation

protocol RecordingCellViewDelegate: AnyObject {
    func didTapButton(with url: URL, avPlayer: AVAudioPlayer, cell: RecordingCellView)
    
    func didSlide(with url: URL, value: TimeInterval, player: AVAudioPlayer)
}

class RecordingCellView: UITableViewCell {
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    
    weak var delegate: RecordingCellViewDelegate?
    
    static let identifier = "RecordingCellView"
    
    var cellURL: URL?
    var slideValue: Float?
    var avPlayer: AVAudioPlayer?
    var cell: RecordingCellView?
    
    static func nib() -> UINib {
        return UINib(nibName: "RecordingCellView", bundle: Bundle(for: RecordingCellView.self))
    }
    
    @IBAction func didTapButton() {
        delegate?.didTapButton(with: cellURL!, avPlayer: self.avPlayer!, cell: self.cell!)
    }
    
    @IBAction func didSlide() {
        slideValue = slider.value
        delegate?.didSlide(with: cellURL!, value: TimeInterval(slider.value), player: avPlayer!)
        
    }
    
    func configureButton(with title: String) {
        playPauseButton.setTitle(title, for: .normal)
    }
    
    func configureSlider(with max: Float, curr: Float) {
        slider.maximumValue = max
        slider.value = curr
    }
    
    func configureLabel(with url: URL) {
        let dataURL = url
        cellURL = url
        let uneditted = dataURL.lastPathComponent
        let title = uneditted.dropLast(4)
        label?.text = String(title)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func createPlayer() {
        var player: AVAudioPlayer?
        do {
            player = try AVAudioPlayer(contentsOf: cellURL!)
            self.avPlayer = player
            
        } catch {
            print("Error creating audioPlayer in tableview")
        }
    }
    
    @objc func updateTime(_ timer: Timer) {
        slider.value = Float(avPlayer!.currentTime)
        let currentTime1 = Int((avPlayer?.currentTime)!)
        let minutes = currentTime1/60
        let seconds = currentTime1 - minutes * 60
        self.currentTimeLabel.text = NSString(format: "%02d:%02d", minutes, seconds) as String
        if currentTime1 == Int(avPlayer!.duration) {
            playPauseButton.setTitle("Play", for: .normal)
        }
    }
    
    
    
}

