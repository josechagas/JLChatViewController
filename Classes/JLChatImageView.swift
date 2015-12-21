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
            if let _ = self.image{
                self.layer.masksToBounds = false
                self.backgroundColor = UIColor.clearColor()
                loadActivity.stopAnimating()
            }
            else{
                self.layer.masksToBounds = true
                self.backgroundColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 0.3)
                loadActivity.startAnimating()
            }
        }
    }
    
    
    public var loadActivity:UIActivityIndicatorView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 0.3)
        initLoadActivity()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 0.3)
        initLoadActivity()
    }
    
    
    public func addImage(image:UIImage,mask:UIImage?){
        
        
        if let mask = mask{
            let imageReference = image.CGImage
            
            
            //----
            let hasAlpha = true
            let scale: CGFloat = 0.0
            
            UIGraphicsBeginImageContextWithOptions(self.frame.size, !hasAlpha, scale)
            mask.drawInRect(CGRect(origin: CGPointZero, size: self.frame.size))
            
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            
            let maskReference = scaledImage.CGImage
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
