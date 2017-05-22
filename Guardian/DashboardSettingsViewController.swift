//
//  DashboardSettingsViewController.swift
//  Guardian
//
//  Created by Henry Boswell on 5/19/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit
import CoreData

protocol UpdateImageProtocol {
    func userIsDone(image: UIImage)
}

class DashboardSettingsViewController: UIViewController, UpdateImageProtocol {

    var image: UIImage?
    var delegate: UpdateLateImageProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        profileImage.isUserInteractionEnabled = true
        
        userIsDone(image: image!)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DashboardSettingsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        //profileImage.addGestureRecognizer(tapRecognizer)

        // Do any additional setup after loading the view.
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBOutlet weak var profileImage: UIImageView!

    
    @IBAction func CancelButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    
    @IBOutlet weak var NameField: UITextField!
    @IBOutlet weak var TitleField: UITextField!
    
    @IBAction func DoneButton(_ sender: Any) {
        DashboardData.sharedInstance.changeActionRequired(actionReq: "no", name: NameField.text!, title: TitleField.text!)
        delegate?.updateImage(image: image!)
        
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        do {
            let fetchedUsers = try moc.fetch(fetchRequest) as! [User]
            //fetchedUsers.first?.uuid
            
            //print(fetchedUsers.first?.selfieurl)
            fetchedUsers.first?.name = NameField.text!
            fetchedUsers.first?.title = TitleField.text!
            
                
            
        } catch {
            fatalError("Failed to fetch : \(error)")
        }
        self.navigationController?.dismiss(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userIsDone(image: UIImage) {
        profileImage.image = image.roundedImage
        self.image = image
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        if touch.view == profileImage {
             self.performSegue(withIdentifier: "Crop", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Crop" {
            let nextView = segue.destination as! DashboardCropViewController
            nextView.delegate = self
        }
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
