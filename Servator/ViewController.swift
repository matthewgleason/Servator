//
//  ViewController.swift
//  Servator
//
//  Created by Matt Gleason on 11/17/20.
//

import UIKit
import MessageUI
import CoreLocation


class ViewController: UIViewController, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate {

    
    @IBOutlet weak var shirtIV: UIImageView!
    @IBOutlet weak var pantsIV: UIImageView!
    @IBOutlet weak var jacketIV: UIImageView!
    @IBOutlet weak var skirtsIV: UIImageView!
    @IBOutlet weak var underwearIV: UIImageView!
    @IBOutlet weak var socksIV: UIImageView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var shirtOuter: UIView!
    @IBOutlet weak var pantsOuter: UIView!
    @IBOutlet weak var jacketOuter: UIView!
    @IBOutlet weak var skirtOuter: UIView!
    @IBOutlet weak var underwearOuter: UIView!
    @IBOutlet weak var shoeOuter: UIView!
    @IBOutlet weak var settingsImageButton: UIImageView!
    @IBOutlet weak var contactImageButton: UIImageView!
    
    
    let locationManager = CLLocationManager()
    var lat: Double?
    var long: Double?
    var address: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let navBar = self.navigationController?.navigationBar
        //navBar?.layer.insertSublayer(gradientLayer, at: 0)
        navBar?.tintColor = UIColor(cgColor: #colorLiteral(red: 0.4962245968, green: 0.4269699434, blue: 1, alpha: 1).cgColor)
        navBar?.barTintColor = UIColor.white
        navBar?.barStyle = .black
        

        // tint color changes the color of the nav item colors eg. the back button

        // the following attribute changes the title color
        navBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(cgColor: #colorLiteral(red: 0.4962245968, green: 0.4269699434, blue: 1, alpha: 1).cgColor)]
        
        createImagesLayout()
        
        createInnerImagesLayout()
        
        addGradient()
        
        addTapToBottomButtons()
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func addTapToBottomButtons() {
        let gesture1 = UITapGestureRecognizer(target: self, action:  #selector(self.goToProfile))
        settingsImageButton.isUserInteractionEnabled = true
        settingsImageButton.addGestureRecognizer(gesture1)
        
        let gesture2 = UITapGestureRecognizer(target: self, action:  #selector(self.contactAuthories))
        contactImageButton.isUserInteractionEnabled = true
        contactImageButton.addGestureRecognizer(gesture2)
    }
    
    
    
    func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.topView.bounds
        gradientLayer.colors = [#colorLiteral(red: 0.4962245968, green: 0.4269699434, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0.645699501, green: 0.5257949233, blue: 0.9328801036, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.topView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func createInnerImagesLayout() {
        let properties = [shirtIV, pantsIV, jacketIV, skirtsIV, underwearIV, socksIV]
        // Do any additional setup after loading the view.
        for property in properties {
            property?.layer.cornerRadius = 25
            property?.layer.masksToBounds = true
            
        }
    }
    
    func createImagesLayout() {
        let outerProperties = [shirtOuter, pantsOuter, jacketOuter, skirtOuter, underwearOuter, shoeOuter]
        
        for outer in outerProperties {
            outer?.layer.cornerRadius = 4
            outer?.layer.shadowColor = UIColor.black.cgColor
            outer?.layer.shadowOpacity = 0.3
            outer?.layer.shadowOffset = .zero
            outer?.layer.shadowRadius = 4
            outer?.isUserInteractionEnabled = true
            
        }
        
        let topButtons = [shirtOuter, pantsOuter, jacketOuter, skirtOuter]
        for button in topButtons {
            let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.tapAction))
            button?.addGestureRecognizer(gesture)
        }
        
        let leftBottomButton = UITapGestureRecognizer(target: self, action:  #selector(self.tapActionToRecord))
        underwearOuter.addGestureRecognizer(leftBottomButton)
        
        let rightBottomButton = UITapGestureRecognizer(target: self, action:  #selector(self.tapActionToRecord))
        shoeOuter.addGestureRecognizer(rightBottomButton)
        
    }
    
    @objc func tapActionToRecord(_ sender:UITapGestureRecognizer){
            // do other task
        print("tapped to record")
        performSegue(withIdentifier: "toBeginRecord", sender: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lat = location.coordinate.latitude
            long = location.coordinate.longitude
            
            let location = CLLocation(latitude: lat!, longitude: long!)
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Failed")
                    return
                }
                if (placemarks?.count)! > 0 {
                    let pm = placemarks?[0]
                    
                    let address = (pm?.subThoroughfare)! + " " + (pm?.thoroughfare)! + " " + (pm?.locality)! + ", " + (pm?.administrativeArea)! + " " + (pm?.postalCode)! + " " + (pm?.isoCountryCode)!
                    self.address = address
                }
            })
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    func showLocationDisabledPopUp() {
        let alert = UIAlertController(title: "Location Acess Denied", message: "In order to contact the authorities, we need to know your location.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let openAction = UIAlertAction(title: "Open Settings", style: .default, handler: { action in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        alert.addAction(cancelAction)
        alert.addAction(openAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func listRecordings() -> [URL] {

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var data: [URL]
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            data = urls.filter( { (name: URL) -> Bool in
                return name.lastPathComponent.hasSuffix("m4a")
            })
            return data

        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("something went wrong")
        }
        return []
        
    }
    
    @objc func tapAction(_ sender:UITapGestureRecognizer){
            // do other task
        print("tapped")
        if listRecordings().count == 0 {
            let alert = UIAlertController(title: "No Recordings Available", message: "There are no recordings stored on disk", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        performSegue(withIdentifier: "toRecordings", sender: self)
    }
    
    @objc func goToProfile(_ sender:UITapGestureRecognizer) {
        performSegue(withIdentifier: "toOnboard", sender: self)
    }
    
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    
    func getFileManager() -> NSString {
        let filePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
        return filePath
    }
    
    
    @objc func contactAuthories(_ sender:UITapGestureRecognizer) {
        let alert = UIAlertController(title: "You are about to dial XXX", message: "Are you sure you want to perform this action? It cannot be undone.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                                      self.displayMessageInterface()
                                  }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
            case .cancelled:
                print("Message was cancelled")
                dismiss(animated: true, completion: nil)
            case .failed:
                print("Message failed")
                dismiss(animated: true, completion: nil)
            case .sent:
                print("Message was sent")
                dismiss(animated: true, completion: nil)
                let vc = self.storyboard?.instantiateViewController(identifier: "BeginRecording") as! BeginRecording
                self.present(vc, animated: true, completion: nil)
            default:
                break
        }
        
    }
    
    func displayMessageInterface() {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.recipients = ["4803093312"]
        // WORKS
        let picArr = ["victim_front.png", "victim_side.png", "offender_front.png", "offender_side.png"]
        let nameArr = ["Victim Front", "Victim Side", "Offender Front", "Offender Side"]
        composeVC.body = "\n\n"
        
        let defaults = UserDefaults.standard
        
        if defaults.string(forKey: "victimName") != nil {
            composeVC.body! += "Victim Name: " + defaults.string(forKey: "victimName")!
            composeVC.body! += "\n"
        }
        if defaults.string(forKey: "offenderName") != nil {
            composeVC.body! += "Offender Name: " + defaults.string(forKey: "offenderName")!
            composeVC.body! += "\n"
            
        }
        composeVC.body! += "\n"
        
        for i in 0 ... picArr.count-1 {
            let filePath = self.getFileManager().appendingPathComponent(picArr[i])
        
            let image = UIImage(contentsOfFile: filePath)
        
            let data = (image?.pngData())!
            composeVC.body! += "Photo " + String(i + 1) + ": " + nameArr[i] + "\n"
            composeVC.addAttachmentData(data, typeIdentifier: "public.data", filename: picArr[i])
        }
        
        composeVC.body! += "\nCase Description:\n"
        
        if let description = UserDefaults.standard.string(forKey: "description") {
            composeVC.body! += description
        }
        
        composeVC.body! += "\n\n"
        
        composeVC.body! += "Latitude: " + String(lat!) + "\n"
        composeVC.body! += "Longitude: " + String(long!) + "\n"
        
        composeVC.body! += "\n"
        
        composeVC.body! += "Current Address: " + self.address!
       
        
        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        } else {
            print("Can't send messages.")
        }
    }
    
    
    
}
