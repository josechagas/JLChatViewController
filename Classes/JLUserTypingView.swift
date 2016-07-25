//
//  JLUserTypingView.swift
//  Pods
//
//  Created by José Lucas Souza das Chagas on 18/01/16.
//
//

import UIKit


public class JLUserTypingView: UIView {
    
    @IBOutlet weak var ballonImageView: UIImageView!

    @IBOutlet weak var animationImageView: UIImageView!
    
    
    @IBOutlet weak var leftDist: NSLayoutConstraint!
    
    @IBOutlet weak var topDist: NSLayoutConstraint!
    
    @IBOutlet weak var bottomDist: NSLayoutConstraint!
    
    @IBOutlet weak var rightDist: NSLayoutConstraint!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //config()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //config()
    }
    
    /**
     This method load the custom view of type JLUserTypingView from nib file
     
     - returns : A instance of JLUserTypingView
     */
    class func loadViewFromNib() -> JLUserTypingView {
        
        let bundle = JLBundleController.getBundle()//NSBundle(forClass: JLUserTypingView.classForCoder())
        let nib = UINib(nibName: "JLUserTypingView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! JLUserTypingView
        view.config()
        return view
    }
    
    /**
     Execute the necessary configurations of thype view like load the images of animationImageView
     */
    func config(){
        configConstraints()
        
        ballonImageView.image = JLChatAppearence.incomingBubbleImage
        
        //self.ballonImageView.tintColor = JLChatAppearence.incomingBubbleColor

        addAnimationImages()
        
        self.frame = CGRect(origin: CGPointZero, size: CGSize(width: 68, height: 44))
        
    }
    
    private func configConstraints(){
        self.topDist.constant += JLChatAppearence.incomingTextAligment.top
        self.bottomDist.constant += JLChatAppearence.incomingTextAligment.bottom
        self.leftDist.constant += JLChatAppearence.incomingTextAligment.left
        self.rightDist.constant += JLChatAppearence.incomingTextAligment.right

    }
    
    /**
     Execute the what is necessary to load the images of the animation
     */
    func addAnimationImages(){
        let bundle = JLBundleController.getBundle()//NSBundle(forClass: JLUserTypingView.classForCoder())
        var array:[UIImage] = [UIImage]()
        for i in 0..<10{
            
            let image = UIImage(named: "UserWriting__00\(i)", inBundle: bundle, compatibleWithTraitCollection: nil)

            array.append(paintImage(image!, WithColor: JLChatAppearence.incomingTextColor))
        }
        
        animationImageView.animationImages = array
    }
    
    /**
     This method is used to paint the dot images with the color of corresponding text of incoming messages
     */
    private func paintImage( image:UIImage,WithColor color:UIColor)->UIImage{
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()
        
        // flip the image
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextTranslateCTM(context, 0.0, -image.size.height)
        
        // multiply blend mode
        CGContextSetBlendMode(context, CGBlendMode.Multiply)
        
        //fill rect with color
        let rect = CGRectMake(0, 0, image.size.width, image.size.height)
        CGContextClipToMask(context, rect, image.CGImage)
        color.setFill()
        CGContextFillRect(context, rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //apply cap insets
        return newImage
    }
    
    /**
     Start the animation of animationImageView
     */
    public func startAnimation(speed:Double){
        
        animationImageView.animationDuration = speed
        animationImageView.animationRepeatCount = Int.max
        animationImageView.startAnimating()

    }
    /**
     Stop the animation of animationImageView
     */
    public func stopAnimation(){
        animationImageView.stopAnimating()
    }
    
}
