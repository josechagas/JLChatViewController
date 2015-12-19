//
//  JLMessage.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 30/11/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit




public enum MessageKind:Int{
    case Text = 1
    case Image = 2
    case Custom = 3
    case AllZeros = 0
}


public enum MessageSendStatus:Int{
    case Sent = 1
    case Sending = 2
    case ErrorToSend = 3
}

public class JLMessage: NSObject {

    public var senderID:String!
    
    public var senderImage:UIImage?
    
    public var text:String?
    
    public var relatedImage:UIImage?
    
    public var messageDate:NSDate!
    
    public var messageKind:MessageKind = MessageKind.AllZeros
    
    public private(set) var messageStatus:MessageSendStatus = MessageSendStatus.Sending
    
    public init(text:String,senderID:String,messageDate:NSDate,senderImage:UIImage?){
        
        super.init()
        
        self.text = text
        
        self.senderID = senderID
        
        self.senderImage = senderImage
        
        self.messageKind = MessageKind.Text
        
        self.messageDate = messageDate
        
    }
    
    public init(senderID:String,messageDate:NSDate,senderImage:UIImage?,relatedImage:UIImage?){
        
        super.init()
        
        self.senderID = senderID
        self.senderImage = senderImage
        self.relatedImage = relatedImage
        
        self.messageKind = MessageKind.Image
        
        self.messageDate = messageDate
        
    }
    
    public func updateMessageSendStatus(newStatus:MessageSendStatus){
        self.messageStatus = newStatus
    }
    
    
    public func generateStringFromDate()->String{
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        return dateFormatter.stringFromDate(self.messageDate)
    }
}

