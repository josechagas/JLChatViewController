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

    /**
     The id of the one that sent the message.
    */
    public var senderID:String!
    
    /**
     The image of the one that sent the message.
     */
    public var senderImage:UIImage?
    
    /**
     The text of the message.
     
     */
    public var text:String?
    
    /**
     The image of the message.
    */
    public var relatedImage:UIImage?
    
    /**
     The date that the message were sent.
    */
    public var messageDate:NSDate!
    
    
    /**
     The Message kind accordingly to the enum MessageKind
     */
    public var messageKind:MessageKind = MessageKind.AllZeros
    
    /**
     The message status accordingly to the enum MessageSendStatus
     Ex some error happend when trying to send the message so messageStatus = MessageSendStatus.ErrorToSend
    */
    public private(set) var messageStatus:MessageSendStatus = MessageSendStatus.Sending
    
    /**
     The message read status 
     */
    public var messageRead:Bool = true
    
    /**
     This is the initializer for the messages of messageKind = MessageKind.Text
     */
    public init(text:String,senderID:String,messageDate:NSDate,senderImage:UIImage?){
        
        super.init()
        
        self.text = text
        
        self.senderID = senderID
        
        self.senderImage = senderImage
        
        self.messageKind = MessageKind.Text
        
        self.messageDate = messageDate
        
    }
    
    /**
     This is the initializer for the messages of messageKind = MessageKind.Image
     */
    public init(senderID:String,messageDate:NSDate,senderImage:UIImage?,relatedImage:UIImage?){
        
        super.init()
        
        self.senderID = senderID
        self.senderImage = senderImage
        self.relatedImage = relatedImage
        
        self.messageKind = MessageKind.Image
        
        self.messageDate = messageDate
        
    }
    
    /**
     Use this method to update messageStatus.
    */
    public func updateMessageSendStatus(newStatus:MessageSendStatus){
        self.messageStatus = newStatus
    }
    
    /**
     this method gives you the formatted string to be shown on the top of the messageCell, almost never you will need to call this method.
    */
    public func generateStringFromDate()->String{
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        return dateFormatter.stringFromDate(self.messageDate)
    }
}

