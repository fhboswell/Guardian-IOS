//
//  IndividualsTableViewController.swift
//  Guardian
//
//  Created by Henry Boswell on 1/5/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit
import CoreData

class IndividualsTableViewController: UITableViewController {

    var group: String = ""
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(group)
        initalizeFetchedResultsController()
        IndividualData.sharedInstance.getIndividualDataFromServer(group: group)
        
      
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    
    
    
    func initalizeFetchedResultsController(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Individual")
        let sort = NSSortDescriptor(key: "name", ascending: false)
        request.sortDescriptors = [sort]
        
        let sortAgain = NSSortDescriptor(key: "check", ascending: false)
        request.sortDescriptors = [sortAgain]

        
        
        
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
            print(fetchedResultsController.fetchedObjects ?? "default value")
        }catch{
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        
    }
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath) {
        guard let selectedIndividual = fetchedResultsController.object(at: indexPath) as? Individual
            else{
                fatalError("Failed to initialize ")
        }
        cell.textLabel?.text = selectedIndividual.name
        if(selectedIndividual.check == "No"){
            cell.backgroundColor = UIColor.red
            print("turn it red")
        }else {
            cell.backgroundColor = UIColor.green
            print("turn it green")
        }
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
        
        
        
        guard let selectedIndividual = fetchedResultsController.object(at: indexPath) as? Individual
            else{
                fatalError("Failed to initialize ")
        }
       // cell.textLabel?.text = selectedIndividual.name
    tableView.deselectRow(at: indexPath, animated: true)
       IndividualData.sharedInstance.changeCheckInStatus(group: group, individual: selectedIndividual.id!)
        
        //performSegue(withIdentifier: "ShowGroup", sender: tableView.cellForRow(at: indexPath))
        
        
    }
    

}

extension IndividualsTableViewController:NSFetchedResultsControllerDelegate{
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
            //configureCell(cell: tableView.cellForRow(at: indexPath! as IndexPath)!, indexPath: indexPath! as IndexPath)
            //tableView.moveRow(at: indexPath!, to: newIndexPath! as IndexPath)
            tableView.reloadData()
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

