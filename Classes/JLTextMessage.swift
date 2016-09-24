//
//  JLTextMessage.swift
//  Pods
//
//  Created by José Lucas Souza das Chagas on 20/09/16.
//
//

import UIKit

open class JLTextMessage: JLMessage {
    
    /**
     The text of the message.
     
     */
    open var text:String?
    

    
    public init(id:Double!, text:String,senderID:String!,messageDate:Date,senderImage:UIImage?){
        
        super.init(id: id,senderID: senderID, messageDate: messageDate, senderImage: senderImage)
        
        self.text = text
        
        self.messageKind = MessageKind.text
    }

    
}
