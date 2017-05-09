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


class ViewController: UIViewController, AutoLogin  {

    
    
   
   
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         #############################################-----Change URL TYPE HERE-----#############################################
         */
        //URLModel.sharedInstance.makeUrlsDevelopment()
        
        
        ActionCableController.sharedInstance.initializeActionCable()
        
       

        //UINavigationBar.a
            //hexStringToUIColor(hex: "0x1D3557")
        
        
    }
    
    func executeSeuge() {
        self.performSegue(withIdentifier: "login", sender: self)
        print("made it")
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
    
    @IBAction func SignUpButton(_ sender: Any) {
        
        
        //SignUpIdent
        print("signup")
        
    
        
        
        self.performSegue(withIdentifier: "SignUpIdent", sender: self)
        
        
    }
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignUpIdent" {
            let secondController = segue.destination as! SignUpViewController
            secondController.delegate = self
        }
    }
    @IBAction func LoginButton(_ sender: Any) {
        
        
        
        
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
                    print(userJson)
                    print(userJson["type_key"])
                   
                    self.loginSucessful(token: json["auth_token"]! as! NSString, ID: "\(userID)" as NSString, type_key: userJson["type_key"] as! NSString)
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
            self.alert(message: "Wrong Username or Password")
        }
    }
    
    func loginSucessful(token: NSString, ID: NSString, type_key: NSString){
        
        DispatchQueue.main.async {
            KeychainController.saveToken(token: token)
            KeychainController.saveID(ID: ID)
            let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: moc) as! User
            user.token = token as String
            user.type_key = type_key as String
            self.performSegue(withIdentifier: type_key as String, sender: self)
        }
        
        
    }
    

}
extension UIViewController {
    
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
        
    }
}

