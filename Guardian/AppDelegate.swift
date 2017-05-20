//
//  AppDelegate.swift
//  Guardian
//
//  Created by Henry Boswell on 1/3/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import UIKit
import CoreData
import AWSCore
import AWSS3

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        /*
        
        var keys: NSDictionary?
        var key: String?
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            key = dict["key"] as? String
        }
        
        
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USWest2,
                                                                identityPoolId:key!)
        
        let configuration = AWSServiceConfiguration(region:.USWest2, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
 
        */
        
 
        
        setupCoreData()
        purge("Individual")
        purge("Group")

        
        
        
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = UIColor(netHex:0x1D3557)
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = false
        
        //UINavigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 80.0)
        
        
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        /*
         Store the completion handler.
         */
        AWSS3TransferUtility.interceptApplication(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    }
    
    
    func purge(_ entityName:String){
        let moc = persistentContainer.viewContext
        let venueFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName )
        do {
            let fetched = try moc.fetch(venueFetch) as! [NSManagedObject]
            fetched.forEach({moc.delete($0)})
            
        } catch {
            print("Something went wrong.\n")
        }
        saveContext()
        
    }
    
    func setupCoreData(){
        let moc = persistentContainer.viewContext
        let group = NSEntityDescription.insertNewObject(forEntityName: "Group", into: moc) as! Group
        
        
        group.title = "testgrou"
        group.desc = "test group descritption"
       
        
        let individual = NSEntityDescription.insertNewObject(forEntityName: "Individual", into: moc) as! Individual
        individual.name = "bob"
        individual.check = "No"
        
        let individual2 = NSEntityDescription.insertNewObject(forEntityName: "Individual", into: moc) as! Individual
        individual.name = "henry"
        individual.check = "No"
        
        
        group.individuals = [individual, individual2]
        
        
        saveContext()
    
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Guardian")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
/*//
 //  DashboardCropViewController.swift
 //  Guardian
 //
 //  Created by Henry Boswell on 5/19/17.
 //  Copyright © 2017 com.project. All rights reserved.
 //
 
 import UIKit
 
 class DashboardCropViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
 // MARK : Constant declaration
 let TITLE_BAR_HEIGHT: CGFloat = 70
 let CROP_WINDOW_HEIGHT: CGFloat = 300
 let CROP_WINDOW_WIDTH: CGFloat = 300
 let CROP_WINDOW_Y_POSITION: CGFloat = 50
 let CROP_MASK_COLOR: UIColor = UIColor(netHex:0x1D3557)
 var imageToCrop: UIImage?
 var processedImage: UIImage = UIImage()
 
 
 // MARK : View (or View Related) variables
 let screenSize: CGRect = UIScreen.main.bounds
 let titleBar: UIView = UIView()
 let btnCropAndSave: UIButton = UIButton()
 var scrollView: UIScrollView = UIScrollView()
 var imageView: UIImageView = UIImageView()
 var cropWindowPieceTop: UIView = UIView()
 var cropWindowPieceLeft: UIView = UIView()
 var cropWindowPieceRight: UIView = UIView()
 var cropWindowPieceBottom: UIView = UIView()
 var resultMsgLable: UILabel = UILabel()
 
 var imagePicker = UIImagePickerController()
 var photo = false
 // MARK : Lifecycles
 override func viewDidLoad() {
 super.viewDidLoad()
 self.navigationController?.isNavigationBarHidden = true
 
 }
 override func viewDidAppear(_ animated: Bool) {
 if photo == false{
 AddPhoto()
 photo = true
 }
 
 }
 
 
 func AddPhoto() {
 
 
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
 print("hereeee")
 self.navigationController?.popViewController(animated: true)
 }
 
 // Add the actions
 imagePicker.delegate = (self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
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
 // self.ImageView.contentMode = .scaleAspectFit
 // self.ImageView.image = pickedImage
 imageToCrop = pickedImage
 initialize()
 makeView()
 putDataIntoView()
 }
 
 
 
 }
 
 func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
 print("here")
 _ = self.navigationController?.popViewController(animated: true)
 }
 
 
 
 override func didReceiveMemoryWarning() {
 super.didReceiveMemoryWarning()
 // Dispose of any resources that can be recreated.
 }
 
 
 // MARK : Delegates
 func viewForZooming(in scrollView: UIScrollView) -> UIView? {
 return self.imageView
 }
 
 
 // MARK : custom methods
 func initialize () {
 if imageToCrop != nil {
 var w = imageToCrop!.size.width
 var h = imageToCrop!.size.height
 if  w < CROP_WINDOW_WIDTH || h < CROP_WINDOW_HEIGHT {
 if w < h {
 h = h * CROP_WINDOW_WIDTH / w
 w = CROP_WINDOW_WIDTH
 } else {
 w = w * CROP_WINDOW_HEIGHT / h
 h = CROP_WINDOW_HEIGHT
 }
 
 UIGraphicsBeginImageContext(CGSize(width: w, height: h))
 imageToCrop!.draw(in: CGRect(x: 0, y: 0, width: w, height: h))
 processedImage = UIGraphicsGetImageFromCurrentImageContext()!
 UIGraphicsEndImageContext()
 } else {
 processedImage = imageToCrop!
 }
 
 imageToCrop = nil
 }
 }
 
 
 func makeView() {
 
 let screenWidth = self.screenSize.width
 let screenHeight = self.screenSize.height
 
 scrollView.frame = CGRect(x: 0, y: TITLE_BAR_HEIGHT, width: screenWidth, height: (screenHeight - TITLE_BAR_HEIGHT))
 scrollView.backgroundColor = UIColor.black
 self.view.addSubview(scrollView)
 
 imageView.frame = CGRect(x: 0, y: 0, width: processedImage.size.width, height: processedImage.size.height)
 imageView.backgroundColor = UIColor.yellow
 scrollView.addSubview(imageView)
 cropWindowPieceTop.frame = CGRect(x: 0, y: TITLE_BAR_HEIGHT, width: screenWidth, height: CROP_WINDOW_Y_POSITION)
 cropWindowPieceTop.backgroundColor = CROP_MASK_COLOR
 self.view.addSubview(cropWindowPieceTop)
 
 cropWindowPieceLeft.frame = CGRect(
 x: 0,
 y: TITLE_BAR_HEIGHT + CROP_WINDOW_Y_POSITION,
 width: (screenWidth - CROP_WINDOW_WIDTH)/2,
 height: screenHeight - TITLE_BAR_HEIGHT-CROP_WINDOW_Y_POSITION)
 cropWindowPieceLeft.backgroundColor = CROP_MASK_COLOR
 self.view.addSubview(cropWindowPieceLeft)
 
 cropWindowPieceRight.frame = CGRect(
 x: (CROP_WINDOW_WIDTH + screenWidth)/2,
 y: TITLE_BAR_HEIGHT + CROP_WINDOW_Y_POSITION,
 width: (screenWidth - CROP_WINDOW_WIDTH)/2,
 height: screenHeight - TITLE_BAR_HEIGHT-CROP_WINDOW_Y_POSITION)
 cropWindowPieceRight.backgroundColor = CROP_MASK_COLOR
 self.view.addSubview(cropWindowPieceRight)
 
 cropWindowPieceBottom.frame = CGRect(
 x: (screenWidth - CROP_WINDOW_WIDTH)/2,
 y: TITLE_BAR_HEIGHT + CROP_WINDOW_Y_POSITION + CROP_WINDOW_HEIGHT,
 width: CROP_WINDOW_WIDTH,
 height: screenHeight - (TITLE_BAR_HEIGHT + CROP_WINDOW_Y_POSITION + CROP_WINDOW_HEIGHT))
 cropWindowPieceBottom.backgroundColor = CROP_MASK_COLOR
 self.view.addSubview(cropWindowPieceBottom)
 self.view.bringSubview(toFront: DoneButtonOutlet)
 self.view.bringSubview(toFront: ResetButtonOutlet)
 self.view.bringSubview(toFront: CancelButtonOutlet)
 }
 
 func putDataIntoView() {
 imageView.image = processedImage
 
 // setting the scrollView.minimumZoomScale
 let w = processedImage.size.width
 let h = processedImage.size.height
 if  w < h {
 scrollView.minimumZoomScale = CROP_WINDOW_WIDTH / w
 } else {
 scrollView.minimumZoomScale = CROP_WINDOW_HEIGHT / h
 }
 
 scrollView.maximumZoomScale = 10
 scrollView.contentSize = processedImage.size
 scrollView.delegate = self
 scrollView.contentInset = UIEdgeInsets(
 top: CROP_WINDOW_Y_POSITION,
 left: (screenSize.width - CROP_WINDOW_WIDTH)/2,
 bottom: scrollView.frame.height - CROP_WINDOW_Y_POSITION - CROP_WINDOW_HEIGHT,
 right: (screenSize.width - CROP_WINDOW_WIDTH)/2)
 
 scrollView.zoomScale = scrollView.minimumZoomScale
 
 cropWindowPieceTop.isUserInteractionEnabled = false
 cropWindowPieceLeft.isUserInteractionEnabled = false
 cropWindowPieceRight.isUserInteractionEnabled = false
 cropWindowPieceBottom.isUserInteractionEnabled = false
 //  DoneButtonOutlet.bringSubview(toFront: self.view)
 }
 
 
 @IBOutlet weak var ResetButtonOutlet: UIButton!
 
 @IBAction func ResetButton(_ sender: Any) {
 
 AddPhoto()
 }
 
 
 @IBOutlet weak var CancelButtonOutlet: UIButton!
 
 @IBAction func CancelButton(_ sender: Any) {
 
 self.navigationController?.popViewController(animated: true)
 
 
 }
 @IBOutlet weak var DoneButtonOutlet: UIButton!
 @IBAction func DoneButton(_ sender: Any)  {
 print("save btn clicked")
 
 let scale = 1 / scrollView.zoomScale
 
 let visibleRect = CGRect(
 x: (scrollView.contentOffset.x + scrollView.contentInset.left) * scale,
 y: (scrollView.contentOffset.y + scrollView.contentInset.top) * scale,
 width: CROP_WINDOW_WIDTH * scale,
 height: CROP_WINDOW_HEIGHT * scale)
 
 let imageRef: CGImage? = processedImage.cgImage?.cropping(to: visibleRect)!
 
 let croppedImage:UIImage = UIImage(cgImage: imageRef!)
 
 // UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
 
 let fileManager = FileManager.default
 let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
 let imagePath = documentsPath?.appendingPathComponent("image.jpg")
 try! UIImageJPEGRepresentation(croppedImage, 1.0)?.write(to: imagePath!)
 DashboardData.sharedInstance.upload(imagePath: imagePath!)
 
 
 
 }
 
 
 func showResultMessage() {
 resultMsgLable.frame = CGRect(x: (screenSize.width - 200)/2, y: (screenSize.height - 30 - 50), width: 200, height: 30)
 resultMsgLable.backgroundColor = UIColor.black
 resultMsgLable.textColor = UIColor.white
 resultMsgLable.text = "cropped and saved"
 self.view.addSubview(resultMsgLable)
 
 Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(DashboardCropViewController.dismissResultMessage), userInfo: nil, repeats: false)
 }
 
 func dismissResultMessage() {
 resultMsgLable.removeFromSuperview()
 }
 
 }
*/
