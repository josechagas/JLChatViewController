//
//  JLChatTextView.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 29/11/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit


enum PasteboardKeysForValueTypes:String{
    case StringType = "Text"
    case ImageType = "Image"
    case CustomData = "CustomData"
}

open class JLChatTextView: UITextView {

    
    var bubbleImageView:UIImageView!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override open var text:String!{
        didSet{
            configInsets()
        }
    }
    
    
    fileprivate var bubbleDrawed:Bool = false

    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        initBallon()

    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //configInsets()
        
        initBallon()
       

    }
    
       
    fileprivate func configInsets(){
        
        self.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    
    
    //MARK: Ballon methods
    
    fileprivate func initBallon(){
        
        bubbleImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size:self.frame.size))
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
                
        self.addSubview(bubbleImageView)
        
        self.bubbleImageView.layer.zPosition = -1
        
        //Constraints
        
        let centerX = NSLayoutConstraint(item: bubbleImageView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        self.addConstraint(centerX)
        
        
        let centerY = NSLayoutConstraint(item: bubbleImageView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        self.addConstraint(centerY)
        
        let height = NSLayoutConstraint(item: bubbleImageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
        self.addConstraint(height)
        
        let width = NSLayoutConstraint(item: bubbleImageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
        self.addConstraint(width)
        
        
    }
    
    /**
     Creates the ballon image for the corresponding textView
     
     - parameter isOutgoingMessage: true this is a out going message, false this is a incoming message
     */
    open func createBallonForMessage(IsThisOutGoingMessage isOutgoingMessage:Bool){
        
        if isOutgoingMessage{
            
            self.bubbleImageView.image = JLChatAppearence.outgoingBubbleImage
            
            //it was used when the BubbleImage used to have rendering mode imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            //self.bubbleImageView.tintColor = JLChatAppearence.outgoingBubbleColor
        }
        else{
            self.bubbleImageView.image = JLChatAppearence.incomingBubbleImage
            
            //it was used when the BubbleImage used to have rendering mode imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            //self.bubbleImageView.tintColor = JLChatAppearence.incomingBubbleColor
        }
        
    }

    
    /**
     THIS IS NOT BEING USED
     
     Creates the ballon image for the corresponding textView
     - parameter isOutgoingMessage: true this is a out going message, false this is a incoming message
     */
    open func createBallonForOugoingMessage(_ isOutgoingMessage:Bool){
        
        if isOutgoingMessage{
            
            self.bubbleImageView.image = JLChatAppearence.outgoingBubbleImage
            //it was used when the BubbleImage used to have rendering mode imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            //self.bubbleImageView.tintColor = JLChatAppearence.outgoingBubbleColor
        }
        else{
            self.bubbleImageView.image = JLChatAppearence.incomingBubbleImage
            
            //it was used when the BubbleImage used to have rendering mode imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            //self.bubbleImageView.tintColor = JLChatAppearence.incomingBubbleColor
        }
        
    }
    
    

}
