//
//  GroupData.swift
//  Guardian
//
//  Created by Henry Boswell on 4/15/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit
import CoreData
import Foundation


class GroupData  {
    static let sharedInstance = GroupData()
    
    func getGroupDataFromServer(){
        
        let token = KeychainController.loadToken()!
        print(token)
        var urlString = URLModel.sharedInstance.baseUrl
        urlString += KeychainController.loadID()! as String
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            //let responseString = String(data: data, encoding: .utf8)
            DispatchQueue.main.async {
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String:AnyObject]]
                    
                    
                    for group in json! {
                        let addGroup = group 
                        
                        
                        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                        
                        let group = NSEntityDescription.insertNewObject(forEntityName: "Group", into: moc) as! Group
                        group.title = addGroup["title"] as! String?
                        let groupID = addGroup["id"] as! Int
                        group.id = "\(groupID)"
                        print(group)
                    }
                }catch{
                    
                    DispatchQueue.main.async {
                        //self.alert(message: "website error")
                    }
                    
                }
            }
        }
        task.resume()
        
        
        
    }

}
