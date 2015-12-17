//
//  JLFile.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 03/12/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit

public class JLFile: NSObject {

    var title:String = "arquivo"
    
    var image:UIImage?
    
    public init(title:String?,image:UIImage?) {
        
        if let title = title{
            self.title = title
        }
        
        self.image = image
        
    }
    
}
