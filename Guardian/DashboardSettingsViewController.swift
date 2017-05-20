//
//  DashboardSettingsViewController.swift
//  Guardian
//
//  Created by Henry Boswell on 5/19/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit

class DashboardSettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        profileImage.isUserInteractionEnabled = true
        
        //profileImage.addGestureRecognizer(tapRecognizer)

        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var profileImage: UIImageView!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        if touch.view == profileImage {
             self.performSegue(withIdentifier: "Crop", sender: self)
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
