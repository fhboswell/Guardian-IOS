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

    
    
   
   
    @IBOutlet weak var TitleLabel: UILabel!
    
    var actionRequired: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         #############################################-----Change URL TYPE HERE-----#############################################
         *///
        URLModel.sharedInstance.makeUrlsDevelopment()
         self.navigationController?.isNavigationBarHidden = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        ActionCableController.sharedInstance.initializeActionCable()
        
        TitleLabel.layer.borderColor = UIColor.black.cgColor
        TitleLabel.layer.borderWidth = 4
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func executeSeuge() {
        self.performSegue(withIdentifier: "Admin", sender: self)
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
        self.performSegue(withIdentifier: "SignUpIdent", sender: self)

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
                    print(userJson["type_key"]!)
                    print(userJson["selfieurl"]!)
                    
                    print(userJson["selfieurl"]!)
                    print(userJson["uuid"]!)
                    self.actionRequired = userJson["actionreq"] as! String
                    
                    var usersName = ""
                    var usersTitle = ""
                    if self.actionRequired != "Yes" && self.actionRequired != "yes" {
                        usersName = userJson["name"]! as! String
                        usersTitle = userJson["title"]! as! String
                    }
                    
                    //var selfieurl: NSString
                    
                    if let selfieurl = userJson["selfieurl"] as? NSString{
                        self.loginSucessful(token: json["auth_token"]! as! NSString, ID: "\(userID)" as NSString, type_key: userJson["type_key"] as! NSString, selfieurl: selfieurl as String, uuid: userJson["uuid"] as! NSString, name: usersName, title: usersTitle)
                    } else{
                        let selfieurl = "None"
                        if (userJson["uuid"] as? NSString) != nil{
                            self.loginSucessful(token: json["auth_token"]! as! NSString, ID: "\(userID)" as NSString, type_key: userJson["type_key"] as! NSString, selfieurl: selfieurl as String, uuid: userJson["uuid"] as! NSString, name: usersName, title: usersTitle)
                        } else{
                            let uuid = "None"
                            self.loginSucessful(token: json["auth_token"]! as! NSString, ID: "\(userID)" as NSString, type_key: userJson["type_key"] as! NSString, selfieurl: selfieurl, uuid: uuid as NSString, name: usersName, title: usersTitle)
                        }
                    
                    }
                    
                        
                    
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
    
    func loginSucessful(token: NSString, ID: NSString, type_key: NSString, selfieurl: String, uuid: NSString, name: String, title: String){
        
        DispatchQueue.main.async {
            KeychainController.saveToken(token: token)
            KeychainController.saveID(ID: ID)
            self.purge("User")
            let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: moc) as! User
            user.token = token as String
            user.type_key = type_key as String
            user.selfieurl = selfieurl
            user.uuid = uuid as String
            user.title = title
            user.name = name
            self.performSegue(withIdentifier: type_key as String, sender: self)
        }
        
        
    }
    func purge(_ entityName:String){
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let venueFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName )
        do {
            let fetched = try moc.fetch(venueFetch) as! [NSManagedObject]
            fetched.forEach({moc.delete($0)})
            
        } catch {
            print("Something went wrong.\n")
        }
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Guardian" {
            
            let nextView = segue.destination as! DashboardViewController
            
            
            
            nextView.actionRequired = actionRequired
        }
        if segue.identifier == "SignUpIdent" {
            let secondController = segue.destination as! SignUpViewController
            secondController.delegate = self
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

