//
//  DashboardViewController.swift
//  Guardian
//
//  Created by Henry Boswell on 5/8/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit
import CoreData
import AWSS3

class DashboardViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    
    
    @IBOutlet weak var GuardianName: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var DashboardTableView: UITableView!
    var imagePicker = UIImagePickerController()
    
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    
    let transferManager = AWSS3TransferManager.default()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor(netHex:0x1D3557)
        nav?.titleTextAttributes = [ NSFontAttributeName: UIFont.systemFont(ofSize: 34, weight: UIFontWeightThin)]
        self.title = "Your Groups"
        
        self.navigationController?.isNavigationBarHidden = false
       
        DashboardTableView.delegate = self
        DashboardTableView.dataSource = self
        
        initalizeFetchedResultsController()
        
        
        DashboardData.sharedInstance.getDashboardDataFromServer()
        setImage()
        
        //cell.textLabel?.text = selectedGroup.title
        
        
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func setImage(){
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        
        do {
            let fetchedUsers = try moc.fetch(fetchRequest) as! [User]
            //fetchedUsers.first?.uuid
            
            //print(fetchedUsers.first?.selfieurl)
            if fetchedUsers.first?.selfieurl == "None"{
                return
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
                self.ImageView.contentMode = .scaleAspectFit
                self.ImageView.image = UIImage(contentsOfFile: downloadingFileURL.path)
                //let downloadOutput = task.result
                return nil
            })

            
            
            
            
            
            
            
            //print(fetchedUsers.first?.uuid)
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }

        
    }
    
       override func viewDidAppear(_ animated: Bool) {
        //DashboardData.sharedInstance.getDashboardDataFromServer()
    }
    
    
    
    @IBAction func AddPhoto(_ sender: Any) {
        

        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallary", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        imagePicker.delegate = (self as UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    func openCamera(){
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self .present(imagePicker, animated: true, completion: nil)
        }else{
            let alert = UIAlertView()
            alert.title = "Warning"
            alert.message = "You don't have camera"
            alert.addButton(withTitle: "OK")
            alert.show()
        }
    }
    func openGallary(){
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    //MARK:UIImagePickerControllerDelegate
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.ImageView.contentMode = .scaleAspectFit
            self.ImageView.image = pickedImage
        }
        
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let imagePath = documentsPath?.appendingPathComponent("image.jpg")
        
        // extract image from the picker and save it
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            try! UIImageJPEGRepresentation(pickedImage, 1.0)?.write(to: imagePath!)
        }
        
        print(imagePath!)
         DashboardData.sharedInstance.upload(imagePath: imagePath!)
    
        
        dismiss(animated: true, completion: nil)
        
    }
    
       /*
    //PickerView Delegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        imagePicker.dismiss(animated: true, completion: nil)
        ImageView.image=info[UIImagePickerControllerOriginalImage] as? UIImage
    }
 */
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("picker cancel.")
    }
    
    
    
    
    func initalizeFetchedResultsController(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Individual")
        let sort = NSSortDescriptor(key: "name", ascending: false)
        request.sortDescriptors = [sort]
        
        let sortAgain = NSSortDescriptor(key: "check", ascending: false)
        request.sortDescriptors = [sortAgain]
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
        do{
            try fetchedResultsController.performFetch()
            print(fetchedResultsController.fetchedObjects ?? "default value")
        }catch{
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        
    }
    
    func configureCell(cell: DashboardTableViewCell, indexPath: IndexPath) {
        guard let selectedIndividual = fetchedResultsController.object(at: indexPath) as? Individual
            else{
                fatalError("Failed to initialize ")
        }
        cell.NameLabel?.text = selectedIndividual.name
        if(selectedIndividual.check == "No"){
            cell.CheckView.backgroundColor = UIColor.red
            print("turn it red")
        }else {
            cell.CheckView.backgroundColor = UIColor.green
            print("turn it green")
        }
        cell.layer.borderWidth = 3.0
        cell.layer.borderColor = UIColor.black.cgColor
        //cell.contentView.alpha = 1
        //cell.contentView.backgroundColor = UIColor.init(white: 0.9, alpha: 1)
    }
    
    func configureGuardianCell(cell: DashboardGuardianTableViewCell, indexPath: IndexPath) {
        
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            guard let sections = fetchedResultsController.sections else {
                fatalError("No sections in fetchedResultsController")
            }
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        if section == 1{
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Children"
        }
        if section == 1{
            return "Guardians"
        }
        return ""
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.font = UIFont(name: "Apple SD Gothic Neo", size: 14)!
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cellidentifier3", for: indexPath) as! DashboardTableViewCell
            // Set up the cell
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        }
        if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cellidentifier4", for: indexPath) as! DashboardGuardianTableViewCell
            // Set up the cell
            configureGuardianCell(cell: cell, indexPath: indexPath)
            return cell
            
            
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cellidentifier3", for: indexPath)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        guard fetchedResultsController.object(at: indexPath) is Individual
            else{
                fatalError("Failed to initialize ")
        }
        // cell.textLabel?.text = selectedIndividual.name
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
    }
    
    
}

extension DashboardViewController:NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DashboardTableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            DashboardTableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            DashboardTableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            DashboardTableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case .delete:
            DashboardTableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        case .update:
            configureCell(cell: DashboardTableView.cellForRow(at: indexPath! as IndexPath)! as! DashboardTableViewCell, indexPath: indexPath! as IndexPath)
        case .move:
            //configureCell(cell: tableView.cellForRow(at: indexPath! as IndexPath)!, indexPath: indexPath! as IndexPath)
            //tableView.moveRow(at: indexPath!, to: newIndexPath! as IndexPath)
            DashboardTableView.reloadData()
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DashboardTableView.endUpdates()
    }
}
