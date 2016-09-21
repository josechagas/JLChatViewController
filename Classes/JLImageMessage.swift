//
//  JLImageMessage.swift
//  Pods
//
//  Created by José Lucas Souza das Chagas on 20/09/16.
//
//

import UIKit

open class JLImageMessage: JLMessage {

    /**
     The image of the message.
     */
    open var relatedImage:UIImage?
    
    
    
    public init(senderID:String,messageDate:Date,senderImage:UIImage?,relatedImage:UIImage?){
        
        super.init(senderID: senderID, messageDate: messageDate, senderImage: senderImage)
        
      
        self.relatedImage = relatedImage
        
        self.messageKind = MessageKind.image
        
        self.messageDate = messageDate
        
        self.messageKind = MessageKind.image
        
    }
    
}
