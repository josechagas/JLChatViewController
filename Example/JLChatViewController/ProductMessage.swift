//
//  ProductMessage.swift
//  JLChatViewController
//
//  Created by José Lucas Souza das Chagas on 12/12/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import JLChatViewController



class ProductMessage: JLImageMessage {

    var productPrice:String?
    
    var text:String!
    
    init(id:Double!, senderID: String, messageDate: Date, senderImage: UIImage?,text:String!,relatedImage: UIImage,productPrice:String?) {
        super.init(id: id, senderID: senderID, messageDate: messageDate, senderImage: senderImage, relatedImage: relatedImage)
        
        self.text = text
        self.productPrice = productPrice
        
        self.messageKind = MessageKind.custom
    }
    
}
