//
//  IndividualData.swift
//  Guardian
//
//  Created by Henry Boswell on 4/15/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit
import CoreData
import Foundation


class IndividualData  {
    static let sharedInstance = IndividualData()
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
    
    
    func getIndividualDataFromServer(group :String){
        purge("Individual")
        let token = KeychainController.loadToken()!
        print(token)
        
        var urlString = "https://guardian-app-v1.herokuapp.com/api/v1/groupsapi/"
        
        urlString += group
        urlString += "/individualsapi"
        
        print(urlString)
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
                    print(json?[1] as Any)
                    
                    for individual in json! {
                        let addIndividual = individual 
                        
                        
                        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                        
                        let individual = NSEntityDescription.insertNewObject(forEntityName: "Individual", into: moc) as! Individual
                        individual.name = addIndividual["name"] as! String?
                        individual.check = addIndividual["check"] as! String?
                        print(individual.check ?? "default value")
                        
                        
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
