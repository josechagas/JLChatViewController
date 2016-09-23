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

        self.navigationBar.tintColor = UIColor.white
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func getImageFromGallery(_ viewController:UIViewController,allowsEditing:Bool){
        self.allowsEditing = allowsEditing
        
        self.sourceType = .photoLibrary
        viewController.present(self, animated: true, completion: nil)
        
        //self.modalPresentationStyle = .Popover
        //viewController.presentViewController(self,animated: true, completion: nil)//4

    }
    
    func getImageFromCamera(_ viewController:UIViewController,captureMode:UIImagePickerControllerCameraCaptureMode,allowsEditing:Bool){
        self.allowsEditing = allowsEditing
        self.sourceType = UIImagePickerControllerSourceType.camera
        self.cameraCaptureMode = captureMode
        //self.modalPresentationStyle = .FullScreen
        viewController.present(self,animated: true,completion: nil)
    }
    
    //swift 3 update
    func getOriginalSelectedImageFrom(_ info:[String:Any])->UIImage{
        
        
        return info[UIImagePickerControllerOriginalImage] as! UIImage
    }
    
    //swift 3 update
    func getEditedSelectedImageFrom(_ info:[String:Any])->UIImage{
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            return editedImage
        }
        
        return getOriginalSelectedImageFrom(info)
    }
    
    func getMediaTypeFrom(_ info:[String:AnyObject])->String{
        return info[UIImagePickerControllerMediaType] as! String
    }
    
    func getMediaURLFrom(_ info:[String:AnyObject])->URL{
        return info[UIImagePickerControllerMediaURL] as! URL
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
