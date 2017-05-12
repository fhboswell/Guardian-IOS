//
//  DashboardData.swift
//  Guardian
//
//  Created by Henry Boswell on 5/8/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import AWSS3


class DashboardData  {
    
    let transferManager = AWSS3TransferManager.default()
    
    static let sharedInstance = DashboardData()
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
    
    
    var group :String?
    
    func getDashboardDataFromServer(){
        purge("Individual")
        
        let token = KeychainController.loadToken()!
        print(token)
        
        let urlString = URLModel.sharedInstance.dashboardUrl
        
        
        print(urlString)
        var request = URLRequest(url: URL(string: urlString)!)
        
        
        request.httpMethod = "GET"
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // networking error
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
                   
                    print(json!)
                    for individual in json! {
                        let addIndividual = individual
                        
                        
                        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                        
                        let individual = NSEntityDescription.insertNewObject(forEntityName: "Individual", into: moc) as! Individual
                        individual.name = addIndividual["name"] as! String?
                        individual.check = addIndividual["check"] as! String?
                        individual.id = String(addIndividual["id"] as! Int)
                        //print(individual.check ?? "default value")
                        
                        
                    }
                }catch{
                    DispatchQueue.main.async {
                        //self.alert(message: "website error")
                    }
                    
                }
            }
            //self.fetchAndEdit()
        }
        task.resume()
        
        
        
        
    }
    
    
    func upload(imagePath: URL){
        
        
        
        
        
        
        
        let transferManager = AWSS3TransferManager.default()
        let uploadingFileURL = imagePath
        
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        //let name = "Henry"
        //fetchRequest.predicate = NSPredicate()
        
        do {
            
            
            let fetchedUsers = try moc.fetch(fetchRequest) as! [User]
            //fetchedUsers.first?.uuid
            
            print(fetchedUsers.first?.selfieurl)
            if fetchedUsers.first?.uuid == "None"{
                return
            }
            
            var uuid = fetchedUsers.first!.uuid!
            
            var filepath = "uploads/" + uuid + "/file.jpg"
            
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            
            uploadRequest?.bucket = "guardian-v1-storage"
            uploadRequest?.key = filepath
            uploadRequest?.body = uploadingFileURL
            
            transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
                
                if let error = task.error as? NSError {
                    if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch code {
                        case .cancelled, .paused:
                            break
                        default:
                            print("Error uploading: \(uploadRequest?.key) Error: \(error)")
                        }
                    } else {
                        print("Error uploading: \(uploadRequest?.key) Error: \(error)")
                    }
                    return nil
                }
                
                let uploadOutput = task.result
                print("Upload complete for: \(uploadRequest?.key)")
                //return nil
                
                
                
                self.changeUrl(filepath: filepath)
                
                
                
                
                
                return nil
                
                
                
                
                
                
                
                
            })
            
            print(fetchedUsers.first?.uuid)
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        
        
    }
    
    
    
    func changeUrl(filepath: String){
        let token = KeychainController.loadToken()!
        print(token)
        
        let urlString = URLModel.sharedInstance.fileurl
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        
        
        
        var postString = "fileurl="
        postString += URLModel.sharedInstance.s3url
        postString += filepath
        
        
        request.httpBody = postString.data(using: .utf8)
        print(postString)
        
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
        }
        task.resume()
        
    }

    
    
    
    func fetchAndEdit(group :Int, name :String, check :String){
        //if(group == self.group){
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Individual")
        
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let fetchedEmployees = try moc.fetch(fetchRequest) as! [Individual]
            fetchedEmployees.first?.check = check
            print(fetchedEmployees)
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        // }
        
    }
   
    
    func changeCheckInStatus(group :String, individual :String){
        self.group = group
        let token = KeychainController.loadToken()!
        print(token)
        
        var urlString = URLModel.sharedInstance.baseUrl
        
        urlString += group
        urlString += "/individualsapi/"
        urlString += individual
        urlString += "/change"
        
        
        print(urlString)
        var request = URLRequest(url: URL(string: urlString)!)
        
        
        request.httpMethod = "PATCH"
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
        }
        task.resume()
    }
    
    
    
    
}
