//
//  AddGroupWizard2ViewController.swift
//  Guardian
//
//  Created by Henry Boswell on 5/14/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit

class AddGroupWizard2ViewController: UIViewController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    let customNavigationAnimationController = CustomNavigationAnimationController()
    let customInteractionController = CustomInteractionController()
    
    
    @IBOutlet weak var InstructorName: UITextField!
    var wizardInput = [String: String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        navigationController?.delegate = self as! UINavigationControllerDelegate
        
        // Do any additional setup after loading the view.
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
    
    @IBAction func BackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func NextButton1(_ sender: Any) {
        var instructorName = InstructorName.text
        if (instructorName?.characters.count)! > 3{
            print(instructorName?.characters.count)
            wizardInput["InstructorName"] = instructorName
            performSegue(withIdentifier: "goToWizard3", sender: self)
        }else{
            print("error")
            alert(message: "Too short")
        }
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToWizard3" {
            print("goToWizard2")
            let toViewController = segue.destination as! AddGroupWizard3ViewController
            toViewController.transitioningDelegate = self
           // toViewController.wizardInput = wizardInput
        }
    }
    
}
