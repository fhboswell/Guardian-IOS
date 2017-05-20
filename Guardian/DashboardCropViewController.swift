//
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
     var delegate: UpdateImageProtocol?
    
    
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
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("picker cancel.")
        self.navigationController?.popViewController(animated: true)
        
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
        scrollView.backgroundColor = UIColor.brown
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
         self.view.bringSubview(toFront: LabelOutlet)
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
        
        
    }
    
    
    @IBOutlet weak var LabelOutlet: UILabel!
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
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let imagePath = documentsPath?.appendingPathComponent("image.jpg")
        try! UIImageJPEGRepresentation(croppedImage, 1.0)?.write(to: imagePath!)
        DashboardData.sharedInstance.upload(imagePath: imagePath!)
        delegate?.userIsDone(image: croppedImage)
        self.navigationController?.popViewController(animated: true)
    }

    
}

