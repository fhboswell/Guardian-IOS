//
//  AddGroupWizard2ViewController.swift
//  Guardian
//
//  Created by Henry Boswell on 5/14/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit

class AddGroupWizard2ViewController: UIViewController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
       
    @IBOutlet weak var InstructorName: UITextField!
    
    var wizardInput : [String: String]?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        print(wizardInput?["GroupName"])
        
        
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
    @IBAction func NextButton(_ sender: Any) {
        var instructorName = InstructorName.text
        if (instructorName?.characters.count)! > 3{
            print(instructorName?.characters.count)
            wizardInput?["InstructorName"] = instructorName
            performSegue(withIdentifier: "goToWizard3", sender: self)
        }else{
            print("error")
            alert(message: "Too short")
        }
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToWizard3" {
           
            let toViewController = segue.destination as! AddGroupWizard3ViewController
            toViewController.transitioningDelegate = self
            toViewController.wizardInput = wizardInput
        }
    }
    
}
