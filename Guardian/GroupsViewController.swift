//
//  GroupsViewController.swift
//  Guardian
//
//  Created by Henry Boswell on 4/24/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit
import CoreData

class GroupsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var GroupTableView: UITableView!
    
     var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor(netHex:0x1D3557)
        self.navigationController?.isNavigationBarHidden = false
        
        GroupTableView.delegate = self
        GroupTableView.dataSource = self
        
        initalizeFetchedResultsController()
        
        //GroupData.sharedInstance.getGroupDataFromServer()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        


        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        
        
        GroupData.sharedInstance.getGroupDataFromServer()
    }
    @IBAction func AddGroupButton(_ sender: Any) {
        print("signup")
        
        
        
        
        self.performSegue(withIdentifier: "AddGroup", sender: self)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            print(fetchedResultsController.fetchedObjects ?? "default")
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cellidentifier", for: indexPath)
        // Set up the cell
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        performSegue(withIdentifier: "ShowGroup", sender: tableView.cellForRow(at: indexPath))
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var destination = segue.destination as UIViewController
        if let navCon = destination as? UINavigationController{
            destination = navCon.visibleViewController!
        }
        if let IVC = destination as? IndividualsViewController {
            if let identifier = segue.identifier{
                switch identifier{
                case "ShowGroup":
                    if let cell = sender as? UITableViewCell{
                        if let indexPath = GroupTableView.indexPath(for: cell){
                            
                            guard let selectedGroup = fetchedResultsController.object(at: indexPath) as? Group
                                else{
                                    fatalError("Failed to initialize ")
                            }
                            let group = selectedGroup.id
                            
                            
                            IVC.group = group!
                        }
                    }
                default: break
                }
            }
        }
        
        
        
        
    }
    

    
    /*
     //MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension GroupsViewController:NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        GroupTableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            GroupTableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            GroupTableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            GroupTableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case .delete:
            GroupTableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        case .update:
            configureCell(cell: GroupTableView.cellForRow(at: indexPath! as IndexPath)!, indexPath: indexPath! as IndexPath)
        case .move:
            GroupTableView.moveRow(at: indexPath!, to: newIndexPath! as IndexPath)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        GroupTableView.endUpdates()
    }
}
