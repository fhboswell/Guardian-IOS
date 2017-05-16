//
//  AddGroupWizard5ViewController.swift
//  Guardian
//
//  Created by Henry Boswell on 5/15/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit
class AddGroupWizard5ViewController: UIViewController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var ReviewView: UITextView!
   
    var wizardInput = [String: String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        var fullDict = ""
        
        for (x, y) in wizardInput {
            fullDict += "(\(x): \(y))\n"
        }
        
        //display.text = fullDict
        print(fullDict)
        ReviewView.text = fullDict
        
        
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
    
    @IBAction func DoneButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: {
           //
            //self.navController = nil;
        });
    }
    
    
    
}

