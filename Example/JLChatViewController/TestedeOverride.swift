//
//  TestedeOverride.swift
//  JLChatViewController
//
//  Created by José Lucas Souza das Chagas on 21/09/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import JLChatViewController


class TestedeOverride: JLChatToolBar {

    override var inputText: JLCustomTextView!{
        get{
            return self.inputText
        }
    }
    
    func teste(){
        
    }
    
}
