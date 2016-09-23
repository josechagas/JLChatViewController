//
//  JLMessage.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 30/11/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit




public enum MessageKind:Int{
    case text = 1
    case image = 2
    case custom = 3
    case allZeros = 0
}


public enum MessageSendStatus:Int{
    case waiting = 0
    case sent = 1
    case sending = 2
    case errorToSend = 3
}


open class JLMessage: NSObject {

    /**
     The id of the one that sent the message.
    */
    open var senderID:String!
    
    /**
     The image of the one that sent the message.
     */
    open var senderImage:UIImage?
    
    /**
     The text of the message.
     
     */
    //public var text:String?
    
    /**
     The image of the message.
    */
    //public var relatedImage:UIImage?
    
    /**
     The date that the message were sent.
    */
    open var messageDate:Date!
    
    
    /**
     The Message kind accordingly to the enum MessageKind
     */
    open var messageKind:MessageKind = MessageKind.allZeros
    
    /**
     The message status accordingly to the enum MessageSendStatus
     Ex some error happend when trying to send the message so messageStatus = MessageSendStatus.ErrorToSend
    */
    open fileprivate(set) var messageStatus:MessageSendStatus = MessageSendStatus.sending
    
    /**
     The message read status 
     */
    open var messageRead:Bool = true
    
    
    
    public init(senderID:String,messageDate:Date,senderImage:UIImage?){
        
        super.init()
        
        self.senderID = senderID
        
        self.senderImage = senderImage
        
        self.messageKind = MessageKind.text
        
        self.messageDate = messageDate
        
    }
    
    
    /**
     Use this method to update messageStatus.
    */
    open func updateMessageSendStatus(_ newStatus:MessageSendStatus){
        self.messageStatus = newStatus
    }
    
    /**
     this method gives you the formatted string to be shown on the top of the messageCell, almost never you will need to call this method.
    */
    open func generateStringFromDate()->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        return dateFormatter.string(from: self.messageDate)
    }
}

