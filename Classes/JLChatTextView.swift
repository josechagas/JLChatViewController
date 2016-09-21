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

public class JLChatTextView: UITextView {

    
    var bubbleImageView:UIImageView!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override public var text:String!{
        didSet{
            configInsets()
        }
    }
    
    
    private var bubbleDrawed:Bool = false

    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        initBallon()

    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //configInsets()
        
        initBallon()
       

    }
    
       
    private func configInsets(){
        
        self.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    
    
    //MARK: Ballon methods
    
    private func initBallon(){
        
        bubbleImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size:self.frame.size))
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
                
        self.addSubview(bubbleImageView)
        
        self.bubbleImageView.layer.zPosition = -1
        
        //Constraints
        
        let centerX = NSLayoutConstraint(item: bubbleImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.addConstraint(centerX)
        
        
        let centerY = NSLayoutConstraint(item: bubbleImageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        self.addConstraint(centerY)
        
        let height = NSLayoutConstraint(item: bubbleImageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        self.addConstraint(height)
        
        let width = NSLayoutConstraint(item: bubbleImageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        self.addConstraint(width)
        
        
    }
    
    /**
     Creates the ballon image for the corresponding textView
     
     - parameter isOutgoingMessage: true this is a out going message, false this is a incoming message
     */
    public func createBallonForMessage(IsThisOutGoingMessage isOutgoingMessage:Bool){
        
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
    public func createBallonForOugoingMessage(isOutgoingMessage:Bool){
        
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
