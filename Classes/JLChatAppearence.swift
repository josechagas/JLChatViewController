//
//  JLChatAppearence.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 30/11/15.  s.version.to_s
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit

public class JLChatAppearence: NSObject {
    
    
    
    
    
   
    //Incoming messages
    static public private(set) var incomingBubbleImage:UIImage?
    
    static public private(set) var incomingBubbleColor:UIColor = UIColor(red: 0.2, green: 0.6, blue: 0.7, alpha: 1)
    
    static public private(set) var showIncomingSenderImage:Bool = true
    
    static public private(set) var incomingTextColor:UIColor = UIColor.blackColor()
    
    public class func configIncomingMessages(incomingBubbleColor:UIColor? ,showIncomingSenderImage:Bool?,incomingTextColor:UIColor?){
        
        if let incomingBubbleColor = incomingBubbleColor{
            self.incomingBubbleColor = incomingBubbleColor
            
        }
        
        if let showIncomingSenderImage = showIncomingSenderImage{
            self.showIncomingSenderImage = showIncomingSenderImage
        }
        
        if let incomingTextColor = incomingTextColor{
            self.incomingTextColor = incomingTextColor
        }
        
        
        let edges = UIEdgeInsets(top: 16, left: 23, bottom: 16, right: 23)//UIEdgeInsets(top: 16, left: 28, bottom: 17, right: 16)
        
        if let bundle = JLBundleController.getBundle(){
            
            incomingBubbleImage = UIImage(named: "bubble_min_incoming", inBundle: bundle, compatibleWithTraitCollection: nil)?.resizableImageWithCapInsets(edges)
            
            incomingBubbleImage = incomingBubbleImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            
        }

    }

    
    //
    
    //Outgoing messages
    static public private(set) var outgoingBubbleImage:UIImage?

    static public private(set) var outgoingBubbleColor:UIColor = UIColor(red: 0, green: 0.7, blue: 0.4, alpha: 0.5)
    
    static public private(set) var showOutgoingSenderImage:Bool = true

    static public private(set) var outGoingTextColor:UIColor = UIColor.whiteColor()
    
    
    public class func configOutgoingMessages(outgoingBubbleColor:UIColor? ,showOutgoingSenderImage:Bool?,outgoingTextColor:UIColor?){
        
        if let outgoingBubbleColor = outgoingBubbleColor{
            self.outgoingBubbleColor = outgoingBubbleColor
        }
        
        if let showOutgoingSenderImage = showOutgoingSenderImage{
            self.showOutgoingSenderImage = showOutgoingSenderImage
        }
        
        if let outGoingTextColor = outgoingTextColor{
            self.outGoingTextColor = outGoingTextColor
        }
        
        
        let edges = UIEdgeInsets(top: 16, left: 23, bottom: 16, right: 23)//UIEdgeInsets(top: 16, left: 28, bottom: 17, right: 16)
        
        if let bundle = JLBundleController.getBundle(){
                      
            outgoingBubbleImage = UIImage(named: "bubble_min", inBundle: bundle, compatibleWithTraitCollection: nil)?.resizableImageWithCapInsets(edges)
            
            outgoingBubbleImage = outgoingBubbleImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            
        }

    }

    
    
    // sender image
    
    
    
    static public private(set) var senderImageSize:CGSize = CGSize(width: 30, height: 30)
    
    static public private(set) var senderImageCornerRadius:CGFloat = 15
    
    static public private(set) var senderImageBackgroundColor:UIColor = UIColor.lightGrayColor()
    
    public class func configSenderImage(senderImageSize:CGSize?,senderImageCornerRadius:CGFloat?,senderImageBackgroundColor:UIColor?){
        
        if let senderImageSize = senderImageSize{
            self.senderImageSize = senderImageSize
        }
        
        if let senderImageCornerRadius = senderImageCornerRadius{
            self.senderImageCornerRadius = senderImageCornerRadius
        }
        
        if let senderImageBackgroundColor = senderImageBackgroundColor{
            self.senderImageBackgroundColor = senderImageBackgroundColor
        }
    }
    
    // message date label
    
    static public private(set) var shouldShowMessageDateAtIndexPath:(indexPath:NSIndexPath)->Bool = { (indexPath) -> Bool in
        
        if indexPath.row % 3 == 0{
            return true
        }
        return false
    }
    
    
    static public private(set) var chatFont:UIFont = UIFont(name: "Helvetica", size: 16)!
    
    public class func configChatFont(font:UIFont?,shouldShowMessageDateAtIndexPath:((indexPath:NSIndexPath)->Bool)?){
        
        if let font = font{
            chatFont = font
        }
        
        if let dateBlock = shouldShowMessageDateAtIndexPath{
            self.shouldShowMessageDateAtIndexPath = dateBlock
        }
        
    }
}
