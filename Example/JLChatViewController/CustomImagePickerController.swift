//
//  CustomImagePickerController.swift
//  ecommerce
//
//  Created by José Lucas Souza das Chagas on 07/11/15.
//  Copyright © 2015 Siara. All rights reserved.
//

import UIKit

class CustomImagePickerController: UIImagePickerController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.tintColor = UIColor.whiteColor()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func getImageFromGallery(viewController:UIViewController,allowsEditing:Bool){
        self.allowsEditing = allowsEditing
        
        self.sourceType = .PhotoLibrary
        viewController.presentViewController(self, animated: true, completion: nil)
        
        //self.modalPresentationStyle = .Popover
        //viewController.presentViewController(self,animated: true, completion: nil)//4

    }
    
    func getImageFromCamera(viewController:UIViewController,captureMode:UIImagePickerControllerCameraCaptureMode,allowsEditing:Bool){
        self.allowsEditing = allowsEditing
        self.sourceType = UIImagePickerControllerSourceType.Camera
        self.cameraCaptureMode = captureMode
        //self.modalPresentationStyle = .FullScreen
        viewController.presentViewController(self,animated: true,completion: nil)
    }
    
    
    
    /*public let UIImagePickerControllerMediaType: String // an NSString (UTI, i.e. kUTTypeImage)
    public let UIImagePickerControllerOriginalImage: String // a UIImage
    public let UIImagePickerControllerEditedImage: String // a UIImage
    public let UIImagePickerControllerCropRect: String // an NSValue (CGRect)
    public let UIImagePickerControllerMediaURL: String // an NSURL*/
    
    
    func getOriginalSelectedImageFrom(info:[String:AnyObject])->UIImage{
        
        
        return info[UIImagePickerControllerOriginalImage] as! UIImage
    }
    
    func getEditedSelectedImageFrom(info:[String:AnyObject])->UIImage{
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            return editedImage
        }
        
        return getOriginalSelectedImageFrom(info)
    }
    
    func getMediaTypeFrom(info:[String:AnyObject])->String{
        return info[UIImagePickerControllerMediaType] as! String
    }
    
    func getMediaURLFrom(info:[String:AnyObject])->NSURL{
        return info[UIImagePickerControllerMediaURL] as! NSURL
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
