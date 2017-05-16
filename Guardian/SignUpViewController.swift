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
    
    var delegate: AutoLogin? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor(netHex:0x1D3557)
        self.view.backgroundColor = UIColor(netHex:0x1D3557)
        self.navigationController?.isNavigationBarHidden = true
        
        
        if let navv = self.navigationController {
            var stack = navv.viewControllers
            print(stack)
            stack.remove(at: 1)
            //stack.removeAtIndex(3)
            navv.setViewControllers(stack, animated: false)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.executeSeuge()
        
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
        postString += "&user[type_key]="
        postString += "Admin"
        
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
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                    print(json)
                    self.loginToAccount()
                }catch{
                    //self.signUpUnsucessful()
                }
            }
                    }
        task.resume()
        
        
        
    }
    
    
    func loginToAccount(){
        
        
        
        let urlString = URLModel.sharedInstance.authUrl
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        
        
        
        var postString = "email="
        postString += EmailField.text!
        postString += "&password="
        postString += PasswordField.text!
        
        
        
        request.httpBody = postString.data(using: .utf8)
        print(postString)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                self.loginUnsucessful()
            }else{
                
                //let responseString = String(data: data, encoding: .utf8)
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                    let userJson = json["user"] as! [String:Any]
                    let userID = userJson["id"] as! Int
                    self.loginSucessful(token: json["auth_token"]! as! NSString, ID: "\(userID)" as NSString)
                }catch{
                    // self.loginUnsucessful()
                }
            }
            
            //print("responseString = \(responseString)")
        }
        task.resume()
        
        
    }
    
    func loginUnsucessful(){
        DispatchQueue.main.async {
            self.alert(message: "Could not log in")
        }
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
        
            self.dismiss(animated: true, completion: { self.delegate?.executeSeuge()})
            self.delegate?.executeSeuge()
            
            
            
        }
        
        
    }
    
    
}

protocol AutoLogin {
    func executeSeuge()
}

