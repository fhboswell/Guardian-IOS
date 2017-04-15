//
//  GroupsTableViewController.swift
//  Guardian
//
//  Created by Henry Boswell on 1/3/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit
import CoreData


class GroupsTableViewController: UITableViewController {

    
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
     //let client = ActionCableClient(url: URL(string:"ws://guardian-app-v1.herokuapp.com/cable")!)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalizeFetchedResultsController()
        tableView.reloadData()
        getGroupDataFromServer()
        
              
        //self.client.connect()

        
        
        //var nav = self.navigationController?.navigationBar
        //nav?.frame = CGRect(x: 0, y: 40, width: self.view.frame.size.width, height: 80.0)
        //nav?.barTintColor = UIColor(netHex:0x1D3557)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func getGroupDataFromServer(){
        
        let token = KeychainController.loadToken()!
        print(token)
        
        
        //let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.nnhd7iTOuy-h-RH8pP_37KcQmkgDq4m3dsIgkY4IwT0"
        
      
        var urlString = "https://guardian-app-v1.herokuapp.com/api/v1/groupsapi/"
        
        urlString += KeychainController.loadID() as! String
        
        var request = URLRequest(url: URL(string: urlString)!)

        
        request.httpMethod = "GET"
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
            DispatchQueue.main.async {
            
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String:AnyObject]]
                    
                    
                    for group in json! {
                        let addGroup = group as! [String:AnyObject]
                        
                        
                        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                        
                        let group = NSEntityDescription.insertNewObject(forEntityName: "Group", into: moc) as! Group
                        group.title = addGroup["title"] as! String?
                        let groupID = addGroup["id"] as! Int
                        group.id = "\(groupID)"
                        print(group)
                    }
                }catch{
                    
                    DispatchQueue.main.async {
                        self.alert(message: "website error")
                    }
              
                }
            }
        }
        task.resume()
        
        
        
    }
    
    
    
    
    func initalizeFetchedResultsController(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Group")
        let sort = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sort]
        
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
            print(fetchedResultsController.fetchedObjects)
        }catch{
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        
    }
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath) {
        guard let selectedGroup = fetchedResultsController.object(at: indexPath) as? Group
            else{
              fatalError("Failed to initialize ")
        }
        cell.textLabel?.text = selectedGroup.title
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cellidentifier", for: indexPath)
        // Set up the cell
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    
        
        performSegue(withIdentifier: "ShowGroup", sender: tableView.cellForRow(at: indexPath))
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var destination = segue.destination as UIViewController
        if let navCon = destination as? UINavigationController{
            destination = navCon.visibleViewController!
        }
        if let ITVC = destination as? IndividualsTableViewController {
            if let identifier = segue.identifier{
                switch identifier{
                case "ShowGroup":
                    if let cell = sender as? UITableViewCell{
                        if let indexPath = tableView.indexPath(for: cell){
                            
                            guard let selectedGroup = fetchedResultsController.object(at: indexPath) as? Group
                                else{
                                    fatalError("Failed to initialize ")
                            }
                            let group = selectedGroup.id
                            
                            
                            ITVC.group = group!
                        }
                    }
                default: break
                }
            }
        }

        
        
        
    }
    
    
}

extension GroupsTableViewController:NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        case .update:
            configureCell(cell: tableView.cellForRow(at: indexPath! as IndexPath)!, indexPath: indexPath! as IndexPath)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath! as IndexPath)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
