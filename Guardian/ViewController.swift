//
//  ViewController.swift
//  Guardian
//
//  Created by Henry Boswell on 1/3/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController  {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var EmailField: UITextField!
    
    @IBOutlet weak var PasswordField: UITextField!
    
    @IBAction func LoginButton(_ sender: Any) {
        
        
        var request = URLRequest(url: URL(string: "https://guardian-app-v1.herokuapp.com/api/v1/auth_user")!)
        request.httpMethod = "POST"
        
        
        
        var postString = "email="
        postString += EmailField.text!
        postString += "&password="
        postString += PasswordField.text!
        
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            //let responseString = String(data: data, encoding: .utf8)
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                print(json["auth_token"]!)
                self.loginSucessful(token: json["auth_token"]! as! NSString)
            }catch{
               self.loginUnsucessful()
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
    
    func loginSucessful(token: NSString){
        
        DispatchQueue.main.async {
            KeychainController.saveToken(token: token)
            let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: moc) as! User
            user.token = token as String
            self.performSegue(withIdentifier: "login", sender: self)
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

