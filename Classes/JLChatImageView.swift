//
//  JLChatImageView.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 02/12/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit

public class JLChatImageView: UIImageView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override public var image:UIImage?{
        didSet{
            if let _ = self.image{
                loadActivity.stopAnimating()
            }
            else{
                loadActivity.startAnimating()
            }
        }
    }
    
    
    public var loadActivity:UIActivityIndicatorView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 0.3)
        initLoadActivity()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 0.3)
        initLoadActivity()
    }
    
    
    private func initLoadActivity(){
        
        loadActivity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        
        loadActivity.hidesWhenStopped = true
        
        loadActivity.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(loadActivity)
        
        loadActivity.startAnimating()
        //Constraints
        
        let centerX = NSLayoutConstraint(item: loadActivity, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.addConstraint(centerX)
        
        
        let centerY = NSLayoutConstraint(item: loadActivity, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        self.addConstraint(centerY)
        
    }
 }
