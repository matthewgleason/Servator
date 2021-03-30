//
//  OnboardingView.swift
//  Servator
//
//  Created by Matt Gleason on 11/26/20.
//

import UIKit

class OnboardingView: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet weak var victimFront: UIButton!
    @IBOutlet weak var victimSide: UIButton!
    @IBOutlet weak var offenderFront: UIButton!
    @IBOutlet weak var offenderSide: UIButton!
    @IBOutlet var offenderNameTextField: UITextField!
    @IBOutlet weak var caseDescriptionTextField: UITextView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var caseViewBoxShadow: UIView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        victimFront.layer.cornerRadius = 4
        victimSide.layer.cornerRadius = 4
        offenderFront.layer.cornerRadius = 4
        offenderSide.layer.cornerRadius = 4
        caseDescriptionTextField.text = "Describe your case here."
        
        addKeyboardMove()
        addGradient()
        createContainer()
        
        self.nameTextField.delegate = self
        self.offenderNameTextField.delegate = self
        
        nameTextField.returnKeyType = .done
        offenderNameTextField.returnKeyType = .done
        
        self.caseDescriptionTextField.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        
        if let oName = UserDefaults.standard.string(forKey: "offenderName") {
            offenderNameTextField.text = oName
        }
        
        if let vName = UserDefaults.standard.string(forKey: "victimName") {
            nameTextField.text = vName
        }
        
        caseDescriptionTextField.backgroundColor = UIColor.clear
        caseViewBoxShadow.backgroundColor = UIColor.clear
    }
    
    func createContainer() {
        let properties = [caseDescriptionTextField, nameTextField, victimFront, victimSide, offenderFront, offenderSide, offenderNameTextField, containerView, caseViewBoxShadow]
        for property in properties {
            property?.layer.cornerRadius = 4
            property?.layer.shadowColor = UIColor.black.cgColor
            property?.layer.shadowOpacity = 0.3
            property?.layer.shadowOffset = .zero
            property?.layer.shadowRadius = 4
        }
        
    }
    
    func addKeyboardMove() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.topView.bounds
        gradientLayer.colors = [#colorLiteral(red: 0.4962245968, green: 0.4269699434, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0.645699501, green: 0.5257949233, blue: 0.9328801036, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.topView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @objc func tapDone(sender: Any) {
            self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }
    
    func saveHistoryTextView()
    {
        if caseDescriptionTextField.text?.count != nil
        {
            let defaults = UserDefaults.standard
            defaults.set(caseDescriptionTextField.text!, forKey: "description")
        }
    }
    
    func displaySavedHistory()
    {
        let defaults = UserDefaults.standard
        if let savedCase = defaults.string(forKey: "description")
        {
            caseDescriptionTextField.text = savedCase
        }
    }


    override func viewWillDisappear(_ animated: Bool)
    {
        saveHistoryTextView()
    }
    override func viewWillAppear(_ animated: Bool)
    {
        displaySavedHistory()
    }
    
    @IBAction func editVictimeName(_ sender: Any) {
        UserDefaults.standard.set(nameTextField.text, forKey: "victimName")
    }
    
    @IBAction func editOffenderName(_ sender: Any) {
        UserDefaults.standard.set(offenderNameTextField.text, forKey: "offenderName")
    }
    
    
    /*
    @IBAction func selectVictimFront(_ sender: Any) {
        self.performSegue(withIdentifier: "toVictimFront", sender: self)
    }
    
    @IBAction func selectVictimSide(_ sender: Any) {
        performSegue(withIdentifier: "toVictimSide", sender: self)
    }
    
    @IBAction func selectOffenderFront(_ sender: Any) {
        performSegue(withIdentifier: "toOffenderFront", sender: self)
    }
    
    @IBAction func selectOffenderSide(_ sender: Any) {
        performSegue(withIdentifier: "toOffenderSide", sender: self)
        
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "toVictimFront"){
            let displayVC = segue.destination as! AddImage
            displayVC.command = "Victim Front"
            displayVC.imgName = "victim_front.png"
        } else if (segue.identifier == "toVictimSide") {
            let displayVC = segue.destination as! AddImage
            displayVC.command = "Victim Side"
            displayVC.imgName = "victim_side.png"
            
        } else if (segue.identifier == "toOffenderFront") {
            let displayVC = segue.destination as! AddImage
            displayVC.command = "Offender Front"
            displayVC.imgName = "offender_front.png"
            
        } else if (segue.identifier == "toOffenderSide") {
            let displayVC = segue.destination as! AddImage
            displayVC.command = "Offender Side"
            displayVC.imgName = "offender_side.png"
            
        } else {
            
        }
    }

}

extension UITextView {
    
    func addDoneButton(title: String, target: Any, selector: Selector) {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))//1
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//2
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)//3
        toolBar.setItems([flexible, barButton], animated: false)//4
        self.inputAccessoryView = toolBar//5
    }
}
