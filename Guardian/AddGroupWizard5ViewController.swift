//
//  AddGroupWizard5ViewController.swift
//  Guardian
//
//  Created by Henry Boswell on 5/15/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit
class AddGroupWizard4ViewController: UIViewController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var GroupLocation: UITextField!
    var wizardInput = [String: String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func BackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func NextButton1(_ sender: Any) {
        
        alert(message: "nope")
        
        
        
    }
    
    
    
}
