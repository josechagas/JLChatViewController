//
//  JLUserTypingView.swift
//  Pods
//
//  Created by José Lucas Souza das Chagas on 18/01/16.
//
//

import UIKit


open class JLUserTypingView: UIView {
    
    @IBOutlet weak var ballonImageView: UIImageView!

    @IBOutlet weak var animationImageView: UIImageView!
    
    @IBOutlet weak var leftDist: NSLayoutConstraint!
    
    @IBOutlet weak var topDist: NSLayoutConstraint!
    
    @IBOutlet weak var bottomDist: NSLayoutConstraint!
    
    @IBOutlet weak var rightDist: NSLayoutConstraint!
    
    
    /**
     This method load the custom view of type JLUserTypingView from nib file and execute all necessary configurations , calling method 'config'
     - returns : A instance of JLUserTypingView
     */
    open class func loadViewFromNib() -> JLUserTypingView {
        
        let bundle = JLBundleController.getBundle()//NSBundle(forClass: JLUserTypingView.classForCoder())
        let nib = UINib(nibName: "JLUserTypingView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! JLUserTypingView
        view.config()
        return view
    }
    
    /**
     Execute the necessary configurations of type view like load the images of animationImageView
     */
    open func config(){
        configConstraints()
        
        ballonImageView.image = JLChatAppearence.incomingBubbleImage
        
        //self.ballonImageView.tintColor = JLChatAppearence.incomingBubbleColor

        addAnimationImages()
        
        self.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 68, height: 44))
        
    }
    
    /**
     This method config the constraints values accordingly to 'JLChatAppearence' defined values for 'incomingTextAligment'
     */
    fileprivate func configConstraints(){
        self.topDist.constant += JLChatAppearence.incomingTextAligment.top
        self.bottomDist.constant += JLChatAppearence.incomingTextAligment.bottom
        self.leftDist.constant += JLChatAppearence.incomingTextAligment.left
        self.rightDist.constant += JLChatAppearence.incomingTextAligment.right
    }
    
    /**
     Execute what is necessary to load and paint the images of the animation
     */
    public func addAnimationImages(){
        let bundle = JLBundleController.getBundle()//NSBundle(forClass: JLUserTypingView.classForCoder())
        var array:[UIImage] = [UIImage]()
        for i in 0..<10{
            
            let image = UIImage(named: "UserWriting__00\(i)", in: bundle, compatibleWith: nil)

            array.append(paintImage(image!, WithColor: JLChatAppearence.incomingTextColor))
        }
        
        animationImageView.animationImages = array
    }
    
    /**
     This method is used to paint the dot images with the color of corresponding text of incoming messages
     */
    public func paintImage( _ image:UIImage,WithColor color:UIColor)->UIImage{
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()
        
        // flip the image
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.translateBy(x: 0.0, y: -image.size.height)
        
        // multiply blend mode
        context?.setBlendMode(CGBlendMode.multiply)
        
        //fill rect with color
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        context?.clip(to: rect, mask: image.cgImage!)
        color.setFill()
        context?.fill(rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //apply cap insets
        return newImage!
    }
    
    /**
     Start the animation of animationImageView
     */
    open func startAnimation(_ speed:Double){
        
        animationImageView.animationDuration = speed
        animationImageView.animationRepeatCount = Int.max
        animationImageView.startAnimating()

    }
    /**
     Stop the animation of animationImageView
     */
    open func stopAnimation(){
        animationImageView.stopAnimating()
    }
    
}
