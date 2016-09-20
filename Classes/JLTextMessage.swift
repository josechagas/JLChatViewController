//
//  JLTextMessage.swift
//  Pods
//
//  Created by José Lucas Souza das Chagas on 20/09/16.
//
//

import UIKit

public class JLTextMessage: JLMessage {
    
    /**
     The text of the message.
     
     */
    public var text:String?
    

    
    public override init(text:String,senderID:String,messageDate:NSDate,senderImage:UIImage?){
        
        super.init(senderID: senderID, messageDate: messageDate, senderImage: senderImage)
        
        self.text = text
        
        self.messageKind = MessageKind.Text
    }

    
}
