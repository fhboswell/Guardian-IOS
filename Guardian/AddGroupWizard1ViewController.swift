//
//  AddGroupWizardViewController.swift
//  Guardian
//
//  Created by Henry Boswell on 5/14/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit

class AddGroupWizard1ViewController: UIViewController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    let customNavigationAnimationController = CustomNavigationAnimationController()
    let customInteractionController = CustomInteractionController()
    
    
    @IBOutlet weak var GroupName: UITextField!
    var wizardInput = [String: String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        navigationController?.delegate = self as UINavigationControllerDelegate

        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
       // tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        
        NextOut.backgroundColor = .clear
        NextOut.layer.cornerRadius = 5
        NextOut.layer.borderWidth = 5
        NextOut.layer.borderColor = UIColor.black.cgColor
        
        CancelOut.backgroundColor = .clear
        CancelOut.layer.cornerRadius = 5
        CancelOut.layer.borderWidth = 5
        CancelOut.layer.borderColor = UIColor.black.cgColor
        
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            customInteractionController.attachToViewController(toVC)
        }
        customNavigationAnimationController.reverse = operation == .pop
        return customNavigationAnimationController
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return customInteractionController.transitionInProgress ? customInteractionController : nil
    }
    
    @IBAction func CancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func NextButton(_ sender: Any) {
        var groupName = GroupName.text
        if (groupName?.characters.count)! > 3{
            //print(groupName?.characters.count)
            wizardInput["GroupName"] = groupName
            //print(
            performSegue(withIdentifier: "goToWizard2", sender: self)
        }else{
            print("error")
            alert(message: "Too short")
        }
        
        
    }
    
    @IBOutlet weak var NextOut: UIButton!
   
    @IBOutlet weak var CancelOut: UIButton!
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToWizard2" {
            print("goToWizard2")
            let toViewController = segue.destination as! AddGroupWizard2ViewController
            toViewController.transitioningDelegate = self
           toViewController.wizardInput = wizardInput
        }
    }

}

//#######################################################################################################################################################


