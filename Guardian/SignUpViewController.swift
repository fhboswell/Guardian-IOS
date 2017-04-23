//
//  ViewController.swift
//  Guardian
//
//  Created by Henry Boswell on 1/3/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import ActionCableClient


class SignUpViewController: UIViewController  {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor(netHex:0x1D3557)
        self.view.backgroundColor = UIColor(netHex:0x1D3557)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var EmailField: UITextField!
    
    @IBOutlet weak var PasswordField: UITextField!
    
    @IBOutlet weak var PasswordConfirmField: UITextField!
    
    @IBAction func CreateAccount(_ sender: Any) {
  
        
        
        makeAccount()
    }
    
    
    
    
    
    
    func makeAccount(){
        
        
        
        let urlString = URLModel.sharedInstance.createUrl
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        
        
        
        var postString = "user[email]="
        postString += EmailField.text!
        postString += "&user[password]="
        postString += PasswordField.text!
        
        request.httpBody = postString.data(using: .utf8)
        print(postString)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 201 {           // check for http errors
                print("statusCode should be 201, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                self.signUpUnsucessful()
            }
            
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                print(json)
                
               self.loginToAccount()
            }catch{
                self.signUpUnsucessful()
            }
                    }
        task.resume()
        
        
        
    }
    
    
    func loginToAccount(){
        
        
    }
    
    
    
    func signUpUnsucessful(){
        DispatchQueue.main.async {
            self.alert(message: "Email already in use")
        }
    }
    
    func loginSucessful(token: NSString, ID: NSString){
        
        DispatchQueue.main.async {
            KeychainController.saveToken(token: token)
            KeychainController.saveID(ID: ID)
            let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: moc) as! User
            user.token = token as String
            self.performSegue(withIdentifier: "login", sender: self)
            
        }
        
        
    }
    
    
}

