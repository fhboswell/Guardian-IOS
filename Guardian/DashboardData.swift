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
    var group :String?
     var delegate: UpdateLateImageProtocol?
    
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
          
            DispatchQueue.main.async {
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String:AnyObject]]
                    print(json!)
                    for dict in json! {
                        
                        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                        
                        if let val = dict["check"] {
                            let addIndividual = dict
                        
                            let individual = NSEntityDescription.insertNewObject(forEntityName: "Individual", into: moc) as! Individual
                            individual.name = addIndividual["name"] as! String?
                            individual.check = addIndividual["check"] as! String?
                            individual.id = String(addIndividual["id"] as! Int)
                            individual.group_id = String(addIndividual["group_id"] as! Int)
                        }else{
                            let addGroup = dict
                            
                            let group = NSEntityDescription.insertNewObject(forEntityName: "Group", into: moc) as! Group
                            group.title = addGroup["title"] as! String?
                            group.instructor = addGroup["instructor"] as! String?
                            group.time = addGroup["time"] as! String?
                            group.location = addGroup["location"] as! String?
                            group.id = String(addGroup["id"] as! Int)
                            
                        }
                        //print(individual.check ?? "default value")
                        
                        
                        
                        
                        //add group data here
                        //the individual needs a group id
                        
                        
                        
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
    
    
    func setImage(ImageView :UIImageView)-> UIImage{
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        var recieveImage: UIImage? = UIImage (named: "NoUserImage.png")
        
        do {
            let fetchedUsers = try moc.fetch(fetchRequest) as! [User]
            //fetchedUsers.first?.uuid
            
            //print(fetchedUsers.first?.selfieurl)
            if fetchedUsers.first?.selfieurl == "None"{
                ImageView.contentMode = .scaleAspectFit
                ImageView.image = recieveImage?.roundedImage
                return recieveImage!
            }
            
            let filepath = fetchedUsers.first!.selfieurl!
            
            let index  = filepath.index(filepath.startIndex, offsetBy: URLModel.sharedInstance.s3url.characters.count )
            
            print(filepath.substring(from: index))
            let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("myImage.jpg")
            
            let downloadRequest = AWSS3TransferManagerDownloadRequest()
            
            downloadRequest?.bucket = "guardian-v1-storage"
            downloadRequest?.key = filepath.substring(from: index)
            downloadRequest?.downloadingFileURL = downloadingFileURL
            
            
            transferManager.download(downloadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
                
                if let error = task.error as NSError? {
                    if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch code {
                        case .cancelled, .paused:
                            break
                        default:
                            print("Error downloading: \(String(describing: downloadRequest?.key)) Error: \(error)")
                        }
                    } else {
                        print("Error downloading: \(String(describing: downloadRequest?.key)) Error: \(error)")
                    }
                    return nil
                    
                }
                print("Download complete for: \(String(describing: downloadRequest?.key))")
                ImageView.contentMode = .scaleAspectFit
                ImageView.image = UIImage(contentsOfFile: downloadingFileURL.path)?.roundedImage
                recieveImage = UIImage(contentsOfFile: downloadingFileURL.path)
                self.delegate?.updateImage(image: recieveImage!)
                return nil
                
            })
            
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        ImageView.contentMode = .scaleAspectFit
        ImageView.image = recieveImage?.roundedImage
        return recieveImage!
        
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
            
            //print(fetchedUsers.first?.selfieurl)
            if fetchedUsers.first?.uuid == "None"{
                return
            }
            
            let uuid = fetchedUsers.first!.uuid!
            
            let filepath = "uploads/" + uuid + "/file.jpg"
            
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            
            uploadRequest?.bucket = "guardian-v1-storage"
            uploadRequest?.key = filepath
            uploadRequest?.body = uploadingFileURL
            
            transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
                
                if let error = task.error as NSError? {
                    if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch code {
                        case .cancelled, .paused:
                            break
                        default:
                            print("Error uploading: \(String(describing: uploadRequest?.key)) Error: \(error)")
                        }
                    } else {
                        print("Error uploading: \(String(describing: uploadRequest?.key)) Error: \(error)")
                    }
                    return nil
                }
                
                //let uploadOutput = task.result
                print("Upload complete for: \(String(describing: uploadRequest?.key))")
          
                self.changeUrl(filepath: filepath)
         
                return nil
        
            })
            
            //print(fetchedUsers.first?.uuid)
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
            let fetched = try moc.fetch(fetchRequest) as! [Individual]
            fetched.first?.check = check
            print(fetched)
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        // }
        
    }
    
    func fetchGroup(group :String, cell :DashboardTableViewCell) -> DashboardTableViewCell{
        //if(group == self.group){
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Group")
        
        fetchRequest.predicate = NSPredicate(format: "id == %@", group)
        
        do {
            let fetched = try moc.fetch(fetchRequest) as! [Group]
            //print(fetched.first?.id)
            cell.InstructorLabel.text = fetched.first?.title
            cell.InstructorLabel.text = cell.InstructorLabel.text! + " with " + (fetched.first?.instructor)!
            cell.LocationLabel.text = fetched.first?.location
            cell.TimeLabel.text = fetched.first?.time
            
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    
        return cell
        
        /*
 @IBOutlet weak var NameLabel: UILabel!
 @IBOutlet weak var InstructorLabel: UILabel!
 @IBOutlet weak var CheckView: UIView!
 @IBOutlet weak var LocationLabel: UILabel!
 @IBOutlet weak var TimeLabel: UILabel!
*/
 
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
