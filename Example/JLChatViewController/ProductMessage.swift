//
//  ProductMessage.swift
//  JLChatViewController
//
//  Created by José Lucas Souza das Chagas on 12/12/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import JLChatViewController



class ProductMessage: JLMessage {

    var productPrice:String?
    
    
    init(senderID: String, messageDate: NSDate, senderImage: UIImage?,text:String,relatedImage: UIImage,productPrice:String?) {
        super.init(senderID: senderID, messageDate: messageDate, senderImage: senderImage, relatedImage: relatedImage)
        
        self.text = text
        self.productPrice = productPrice
        
        self.messageKind = MessageKind.Custom
    }
    
}
