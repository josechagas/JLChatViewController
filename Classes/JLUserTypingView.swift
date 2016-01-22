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
     Execute the necessary configurations of thie view like load the images of animationImageView
     */
    func config(){
        
        ballonImageView.image = JLChatAppearence.incomingBubbleImage
        
        self.ballonImageView.tintColor = JLChatAppearence.incomingBubbleColor

        addAnimationImages()
        
    }
    
    /**
     Execute the what is necessary to load the images of the animation
     */
    func addAnimationImages(){
        let bundle = JLBundleController.getBundle()//NSBundle(forClass: JLUserTypingView.classForCoder())
        var array:[UIImage] = [UIImage]()
        for i in 0..<10{
            
            let image = UIImage(named: "UserWriting__00\(i)", inBundle: bundle, compatibleWithTraitCollection: nil)
            
            //image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            
            array.append(image!)
        }
        
        animationImageView.animationImages = array
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
