//
//  AddIndividualViewController.swift
//  Guardian
//
//  Created by Henry Boswell on 4/27/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit

class AddIndividualViewController: UIViewController, CreateSuccess, UIViewControllerTransitioningDelegate{
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        IndividualData.sharedInstance.delegate = self

        // Do any additional setup after loading the view.
    }

    @IBAction func testButton(_ sender: Any) {
        print("here")
        self.performSegue(withIdentifier: "test", sender: self)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBOutlet weak var NameField: UITextField!
    @IBOutlet weak var EmailField: UITextField!
    
    
    @IBAction func AddButton(_ sender: Any) {
        
       IndividualData.sharedInstance.createIndividualWithGuardian(email:EmailField.text!, name: NameField.text!)
       //  self.dismiss(animated: true, completion: nil)
    }
    
    func executeSeuge() {
        self.dismiss(animated: true, completion: nil)
        print("made it")
    }
    
    let customPresentAnimationController = CustomPresentAnimationController()
    
   
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("here222")
        return customPresentAnimationController
    }
    
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "test" {
            print("hedddddre")
            let toViewController = segue.destination as! testViewController
            toViewController.transitioningDelegate = self
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
