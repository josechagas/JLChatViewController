//
//  JLChatImageView.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 02/12/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//


//http://iosdevelopertips.com/cocoa/how-to-mask-an-image.html

import UIKit

public class JLChatImageView: UIImageView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable public var useBubbleForm:Bool = false
    
    override public var image:UIImage?{
        didSet{
            self.clipsToBounds = true
        }
    }
    
    public var loadActivity:UIActivityIndicatorView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)

        initLoadActivity()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initLoadActivity()
        
    }
    
    private func cutImage(image:UIImage)->UIImage{
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
        
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
        
            
        
        let rect: CGRect = CGRectMake(posX, posY, newWidth, newHeight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let newImage: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return newImage
    }
    
    public func addImage(image:UIImage,mask:UIImage?){
        
        if let mask = mask{
            let imageReference = cutImage(image).CGImage

            
            
            //---- resizing the bubble mask
            let hasAlpha = true
            let scale: CGFloat = 0.0
            
            UIGraphicsBeginImageContextWithOptions(self.frame.size, !hasAlpha, scale)
            mask.drawInRect(CGRect(origin: CGPointZero, size: self.frame.size))
            
            let resizedMask = UIGraphicsGetImageFromCurrentImageContext()
            
            let maskReference = resizedMask.CGImage
            //-----
            
            
            let imageMask = CGImageMaskCreate(CGImageGetWidth(maskReference),
                CGImageGetHeight(maskReference),
                CGImageGetBitsPerComponent(maskReference),
                CGImageGetBitsPerPixel(maskReference),
                CGImageGetBytesPerRow(maskReference),
                CGImageGetDataProvider(maskReference), nil, true)
            
            let maskedReference = CGImageCreateWithMask(imageReference, imageMask)
            
            let maskedImage = UIImage(CGImage:maskedReference!)
            
            self.image = maskedImage

        }
        else{
            self.image = image

        }
    }
    
    
    private func initLoadActivity(){
        
        loadActivity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        
        loadActivity.hidesWhenStopped = true
        
        loadActivity.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(loadActivity)
    
        loadActivity.startAnimating()
        //Constraints
        
        let centerX = NSLayoutConstraint(item: loadActivity, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.addConstraint(centerX)
        
        
        let centerY = NSLayoutConstraint(item: loadActivity, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        self.addConstraint(centerY)
        
    }
 }
