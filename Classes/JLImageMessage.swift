//
//  JLImageMessage.swift
//  Pods
//
//  Created by José Lucas Souza das Chagas on 20/09/16.
//
//

import UIKit

public class JLImageMessage: JLMessage {

    /**
     The image of the message.
     */
    public var relatedImage:UIImage?
    
    
    
    public init(senderID:String,messageDate:NSDate,senderImage:UIImage?,relatedImage:UIImage?){
        
        super.init(senderID: senderID, messageDate: messageDate, senderImage: senderImage)
        
      
        self.relatedImage = relatedImage
        
        self.messageKind = MessageKind.Image
        
        self.messageDate = messageDate
        
        self.messageKind = MessageKind.Image
        
    }
    
}
