//
//  VictimFrontView.swift
//  Servator
//
//  Created by Matt Gleason on 11/29/20.
//

import UIKit

class AddImage: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topText: UILabel!
    @IBOutlet weak var saveViewButton: UIView!
    
    @IBOutlet weak var LibraryViewButton: UIView!
    @IBOutlet weak var saveText: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var cameraViewButton: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var command: String = ""  // could lead to disaster
    var imgName: String = ""
    var chose = false
    
    
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        addGradient()
        addProperties()
        topText.text = "Choose \(command) Profile"
        
        self.getImage(imageName: imgName)
        saveText.isHidden = true
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }
    
    func addProperties() {
        let properties = [saveViewButton, LibraryViewButton, cameraViewButton, containerView, saveViewButton]
        for property in properties {
            property?.layer.cornerRadius = 4
            property?.layer.shadowColor = UIColor.black.cgColor
            property?.layer.shadowOpacity = 0.3
            property?.layer.shadowOffset = .zero
            property?.layer.shadowRadius = 4
            
        }
        let libraryGesture = UITapGestureRecognizer(target: self, action:  #selector(self.chooseLibrary))
        LibraryViewButton.isUserInteractionEnabled = true
        LibraryViewButton.addGestureRecognizer(libraryGesture)
        
        let cameraGesture = UITapGestureRecognizer(target: self, action:  #selector(self.chooseCamera))
        cameraViewButton.isUserInteractionEnabled = true
        cameraViewButton.addGestureRecognizer(cameraGesture)
        
        let saveGesture = UITapGestureRecognizer(target: self, action:  #selector(self.saveImage))
        saveViewButton.isUserInteractionEnabled = true
        saveViewButton.addGestureRecognizer(saveGesture)
    }
    
    func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.topView.bounds
        gradientLayer.colors = [#colorLiteral(red: 0.4962245968, green: 0.4269699434, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0.645699501, green: 0.5257949233, blue: 0.9328801036, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.topView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func getImage(imageName: String) {
       let fileManager = FileManager.default
       let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
       if fileManager.fileExists(atPath: imagePath) {
        photoView.image = UIImage(contentsOfFile: imagePath)
       }
    }
    
    @objc func chooseLibrary(_ sender: UITapGestureRecognizer) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        chose = true
    }
    
    @objc func chooseCamera(_ sender: UITapGestureRecognizer) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        chose = true
        
    }
    
    @objc func saveImage(_ sender: Any) {
        if chose {
            saveImageInternal(imageName: imgName)
        }
    }
    
    func saveImageInternal(imageName: String) {
        //create an instance of the FileManager
           let fileManager = FileManager.default
           //get the image path
           let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
           //get the image we took with camera
           let image = photoView.image!
           //get the PNG data for this image
        let data = image.pngData()
           //store it in the document directory    fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
        print(imagePath)
        
        // store in docuement directory
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
        saveText.isHidden = false
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddImage: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photoView.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }

}
