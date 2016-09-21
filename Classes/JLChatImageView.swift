//
//  JLChatImageView.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 02/12/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//


//http://iosdevelopertips.com/cocoa/how-to-mask-an-image.html

import UIKit

open class JLChatImageView: UIImageView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable open var useBubbleForm:Bool = true
    
    override open var image:UIImage?{
        didSet{
            self.clipsToBounds = true
        }
    }
    
    
    /**
     This is an ActivityIndicator used to indicate some activity with this imageview, for example loading the respective image
     */
    open var loadActivity:UIActivityIndicatorView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)

        initLoadActivity()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initLoadActivity()
        
    }
    
    fileprivate func cutImage(_ image:UIImage)->UIImage{
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var newWidth: CGFloat!
        var newHeight: CGFloat!
        
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            newWidth = contextSize.height
            newHeight = contextSize.height
        }else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            newWidth = contextSize.width
            newHeight = contextSize.width
        }
        
            
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: newWidth, height: newHeight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let newImage: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return newImage
    }
    /**
     This method add an image on a JLChatImageView instance applying some mask on it
     
     - parameter image: the image you want to add.
     - parameter mask: The image that you want to use like a mask, pass nil if you do not want to apply any mask on it.
     */
    open func addImage(_ image:UIImage,ApplyingMask mask:UIImage?){
        
        if useBubbleForm,let mask = mask{

            DispatchQueue.global(priority:DispatchQoS.QoSClass.userInitiated.rawValue).async{
            
                let imageReference = self.cutImage(image).cgImage
                //---- resizing the bubble mask
                let hasAlpha = true
                let scale: CGFloat = 0.0
                
                UIGraphicsBeginImageContextWithOptions(self.frame.size, !hasAlpha, scale)
                mask.draw(in: CGRect(origin: CGPoint.zero, size: self.frame.size))
                
                let resizedMask = UIGraphicsGetImageFromCurrentImageContext()
                
                let maskReference = resizedMask.cgImage
                //-----
                
                
                let imageMask = CGImage(maskWidth: maskReference.width,
                                        height: maskReference.height,
                                        bitsPerComponent: maskReference.bitsPerComponent,
                                        bitsPerPixel: maskReference.bitsPerPixel,
                                        bytesPerRow: maskReference.bytesPerRow,
                                        provider: maskReference.dataProvider, decode: nil, shouldInterpolate: true)
                
                let maskedReference = imageReference.masking(imageMask)
                UIGraphicsEndImageContext()
                
                let maskedImage = UIImage(cgImage:maskedReference!)
                
                DispatchQueue.main.async {
                    self.image = maskedImage
                }

            
            }
            
        }
        else{
            self.image = image
        }
    }
    
    
    fileprivate func initLoadActivity(){
        
        loadActivity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        loadActivity.hidesWhenStopped = true
        
        loadActivity.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(loadActivity)
    
        loadActivity.startAnimating()
        //Constraints
        
        let centerX = NSLayoutConstraint(item: loadActivity, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        self.addConstraint(centerX)
        
        
        let centerY = NSLayoutConstraint(item: loadActivity, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        self.addConstraint(centerY)
        
    }
 }
