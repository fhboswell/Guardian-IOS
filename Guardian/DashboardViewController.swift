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


protocol UpdateLateImageProtocol {
    func updateImage(image: UIImage)
}

class DashboardViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UpdateLateImageProtocol{
    
    func updateImage(image: UIImage) {
        self.image = image
    }

    
    
    
    @IBOutlet weak var GuardianName: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var DashboardTableView: UITableView!
    @IBOutlet weak var NameOutlet: UILabel!
    var image: UIImage?
    var rect1: CGRect?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    let transferManager = AWSS3TransferManager.default()
    
    
    override func viewDidLoad() {
         self.navigationController?.isNavigationBarHidden = true
        super.viewDidLoad()
        setupViewController()
        isActionRequired()
        //NameOutlet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.tappedLabel)))
        
        
    }
    
    
    func setupViewController(){
        DashboardData.sharedInstance.delegate = self
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor(netHex:0x1D3557)
        nav?.titleTextAttributes = [ NSFontAttributeName: UIFont.systemFont(ofSize: 34, weight: UIFontWeightThin)]
        //self.title = "Your Groups"
        
        DashboardTableView.delegate = self
        DashboardTableView.dataSource = self
        initalizeFetchedResultsController()
        DashboardData.sharedInstance.getDashboardDataFromServer()
        image = DashboardData.sharedInstance.setImage(ImageView: ImageView)
        
        NameOutlet.isUserInteractionEnabled = true
        rect1 = getRect(str: NameOutlet.attributedText!, range: NSMakeRange(20, 28), maxWidth: NameOutlet.frame.width)
        
        
        
    }
    func isActionRequired(){
        
       
        NameOutlet.attributedText = attributedStringActionRequired()
        NameOutlet.sizeToFit()
       
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        if touch.view == NameOutlet {
             let currentPoint = touch.location(in: NameOutlet)
            if (rect1?.contains(currentPoint))! {
                
                performSegue(withIdentifier: "Settings", sender: self)
            }
        }
        
    }
    
    
    
    
    func attributedStringActionRequired() -> NSAttributedString {
        let fontSize = UIFont.systemFontSize
        let attrs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: UIColor.white
        ]
        let nonBoldAttribute = [
            NSFontAttributeName: UIFont.systemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: UIColor.darkGray
            ]
        var attrStr = NSMutableAttributedString(string: "Action Is Required Please ", attributes: nonBoldAttribute)
        var attrStr2 = NSMutableAttributedString(string: "Touch Here", attributes: attrs)
       
        attrStr.append(attrStr2)
        return attrStr
    }
    
    
    
        
       override func viewDidAppear(_ animated: Bool) {
        //DashboardData.sharedInstance.getDashboardDataFromServer()
    }
    
    @IBAction func SettingsButton(_ sender: Any) {
        performSegue(withIdentifier: "Settings", sender: self)
    }
    
   
    
    @IBAction func LogoutButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    func getRect(str: NSAttributedString, range: NSRange, maxWidth: CGFloat) -> CGRect {
        let textStorage = NSTextStorage(attributedString: str)
        let textContainer = NSTextContainer(size: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineFragmentPadding = 0
        let pointer = UnsafeMutablePointer<NSRange>.allocate(capacity: 1)
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: pointer)
        return layoutManager.boundingRect(forGlyphRange: pointer.move(), in: textContainer)
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
    
    func configureCell(cell: DashboardTableViewCell, indexPath: IndexPath) -> DashboardTableViewCell{
        guard let selectedIndividual = fetchedResultsController.object(at: indexPath) as? Individual
            else{
                fatalError("Failed to initialize ")
        }
        cell.NameLabel?.text = selectedIndividual.name
        
        var newcell = DashboardData.sharedInstance.fetchGroup(group :selectedIndividual.group_id!, cell: cell)

        
        
        
        
        if(selectedIndividual.check == "No"){
            newcell.CheckView.backgroundColor = UIColor.red
            print("turn it red")
        }else {
            newcell.CheckView.backgroundColor = UIColor.green
            print("turn it green")
        }
        newcell.contentView.backgroundColor = UIColor.init(white: 1, alpha: 0.6)
        return newcell
    }
    
    func configureGuardianCell(cell: DashboardGuardianTableViewCell, indexPath: IndexPath) -> DashboardGuardianTableViewCell{
        //cell.layer.borderWidth = 3.0
       // cell.layer.borderColor = UIColor.black.cgColor
        
        return cell
        
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
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        returnedView.backgroundColor = UIColor(netHex:0x1D3557)
        var label: UILabel?
        
        if section == 0{
            label = UILabel(frame: CGRect(x: 10, y: 27, width: view.frame.size.width, height: 25))
            label?.text = "Children"
            label?.textColor = .white
        }
        if section == 1{
            label = UILabel(frame: CGRect(x: 10, y: 7, width: view.frame.size.width, height: 25))
            label?.text = "Guardians"
            label?.textColor = .white
        }
       
        returnedView.addSubview(label!)
        
        return returnedView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cellidentifier3", for: indexPath) as! DashboardTableViewCell
            // Set up the cell
            cell = configureCell(cell: cell, indexPath: indexPath)
            return cell
        }
        if indexPath.section == 1{
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cellidentifier4", for: indexPath) as! DashboardGuardianTableViewCell
            // Set up the cell
            cell = configureGuardianCell(cell: cell, indexPath: indexPath)
            return cell
            
            
        }
        print("fails")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Settings" {
            
            let destinationNavigationController = segue.destination as! UINavigationController
            let nextView: DashboardSettingsViewController = destinationNavigationController.topViewController as!
            DashboardSettingsViewController
            
            
            nextView.image = image
        }
    }
    
    
}
extension UIImage{
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.size.height
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func correctlyOrientedImage() -> UIImage {
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0,y:  0, width: self.size.width, height: self.size.height))
        var normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        return normalizedImage;
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
