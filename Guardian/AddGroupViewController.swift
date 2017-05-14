//
//  AddGroupViewController.swift
//  Guardian
//
//  Created by Henry Boswell on 4/28/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit

class AddGroupViewController: UIViewController, CreateGroupSuccess {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddGroupViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        GroupData.sharedInstance.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var NameField: UITextField!

    @IBOutlet weak var DescriptionField: UITextField!
    
    @IBAction func CancelButton(_ sender: Any) {
        executeSeuge()
    }
    @IBAction func AddButton(_ sender: Any) {
        
        GroupData.sharedInstance.createGroup(description: DescriptionField.text!, name: NameField.text!)
        //  self.dismiss(animated: true, completion: nil)
    }
    
    func executeSeuge() {
        self.dismiss(animated: true, completion: nil)
        print("made it")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
