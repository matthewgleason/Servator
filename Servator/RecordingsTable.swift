//
//  RecordingsTable.swift
//  Servator
//
//  Created by Matt Gleason on 1/9/21.
//

import UIKit
import AVFoundation

class RecordingsTable: UIViewController, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var data: [URL]?
    var audioPlayer: AVAudioPlayer?
    var url: URL?
    var slider: UISlider?
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(RecordingCellView.nib(), forCellReuseIdentifier: RecordingCellView.identifier)
        tableView.dataSource = self
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //tableView.reloadData()
        listRecordings()
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    // Change the audioPlayer's current time when the slider is changed
    /*
    @objc func sliderChanged(sender: UISlider) {
        audioPlayer?.currentTime = TimeInterval(sender.value)
    }
     */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RecordingCellView.identifier) as! RecordingCellView
        
        cell.configureLabel(with: (data?[indexPath.row])!)
        cell.delegate = self
        
        url = cell.cellURL
        
        cell.cell = cell

        // Set up the slider
        slider = cell.slider
        cell.createPlayer()
        cell.configureSlider(with: Float((cell.avPlayer?.duration)!), curr: Float((cell.avPlayer?.currentTime)!))
        let duration = Int((cell.avPlayer!.duration - (cell.avPlayer!.currentTime)))
        let minutes2 = duration/60
        let seconds2 = duration - minutes2*60
        cell.totalTimeLabel.text = NSString(format: "%02d:%02d", minutes2, seconds2) as String
        
        let currentTime1 = Int((cell.avPlayer?.currentTime)!)
        let minutes = currentTime1/60
        let seconds = currentTime1 - minutes * 60
        cell.currentTimeLabel.text = NSString(format: "%02d:%02d", minutes, seconds) as String
        
        
        
        return cell
    }
    
    func listRecordings() {

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            self.data = urls.filter( { (name: URL) -> Bool in
                return name.lastPathComponent.hasSuffix("m4a")
            })

        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("something went wrong")
        }
    }
    /*
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.row == 0{
        //.... return height whatever you want for indexPath.row
            return 40
        }else {
            return 30
        }
    }
    */

    // MARK: - Table view data source

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCellView") as! RecordingCellView
            do {
                try FileManager.default.removeItem(at: cell.cellURL!)
                print("Deleted Item")
                tableView.reloadData()
            } catch let error as NSError {
                print("Error: \(error.domain)")
            }
            
            data?.remove(at: indexPath.row)
            
            if FileManager.default.fileExists(atPath: cell.cellURL!.absoluteString) {
                print("File still here")
            } else {
                print("File gone")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        /*
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        */
        }
    }
    
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
extension RecordingsTable: RecordingCellViewDelegate {
    func didTapButton(with url: URL, avPlayer: AVAudioPlayer, cell: RecordingCellView) {
        print(url)
        
        
        if (avPlayer.isPlaying) {
            // Since the audioPlayer is playing, w want to pause the music
            avPlayer.pause()
            timer?.invalidate()
            cell.playPauseButton.setTitle("Play", for: .normal)
            // We will change the button's (sender's) image to reflect the change
        } else {
            // Since the audioPlayer is NOT playing, we want to play the music
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: cell, selector: #selector(cell.updateTime), userInfo: nil, repeats: true)
            cell.playPauseButton.setTitle("Pause", for: .normal)
            avPlayer.play()
            // We will change the button's (sender's) image to reflect the change
        }
    }
    
    func didSlide(with url: URL, value: TimeInterval, player: AVAudioPlayer) {
        self.audioPlayer = player
        player.currentTime = value
    }
}
