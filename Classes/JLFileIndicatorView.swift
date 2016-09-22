//
//  JLFileIndicatorView.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 03/12/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit


public protocol FileIndicatorViewDelegate{
    
    func didTapFileIndicatorView()
}

open class JLFileIndicatorView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    
    fileprivate var fileImageView:UIImageView!
    
    fileprivate var leadingAlignmentConstraint:NSLayoutConstraint!
    
    fileprivate var fileTitleLabel:UILabel!
    
    fileprivate var removeFileButton:UIButton!
    
    fileprivate var fileInformations:JLFile?
    
    
    open var delegate:FileIndicatorViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        configView()
        initFileImageView()
        initFileTitleLabel()
        initRemoveFileButton()
        self.layoutIfNeeded()
        
        self.addGestures()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configView()
        initFileImageView()
        initFileTitleLabel()
        initRemoveFileButton()
        self.layoutIfNeeded()
        
        self.addGestures()

    }
    
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        if let file = fileInformations, let _ = file.image{
            leadingAlignmentConstraint.constant = 0
        }
        else{
            leadingAlignmentConstraint.constant = -self.fileImageView.frame.width
        }
        self.layoutIfNeeded()
    }
    /**
     This method applies some configurations on self.layer
     This method is called on it`s inits
     */
    open func configView(){
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.height/4
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1).cgColor
    }
    
    /**
     Use this method for you add the informations on JLFileIndicatorView
     - parameter file: The JLFile instance with its informations.
    */
    open func addFileInformations(_ file:JLFile){
        
        if let image = file.image{
            fileImageView.image = image
        }
                
        self.fileTitleLabel.text = file.title
        
        self.fileInformations = file
    }
    
    
    
    //MARK: - Gesture reognizers
    
    /**
     This method add all necessary gestures that have self as target
     */
    fileprivate func addGestures(){
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(JLFileIndicatorView.tapAction(_:)))
        self.addGestureRecognizer(tap)
    }
    
    /**
     This is the selector for 'UITapGestureRecognizer' added to it
     */
    func tapAction(_ tapGes:UITapGestureRecognizer){
        
        self.removeFileButton.isHighlighted = true
        
        self.delegate?.didTapFileIndicatorView()
        
    }
    
    /**
     This is the action for 'UIButton' used to remove the file
     */
    func removeFileButtonAction(_ sender:AnyObject?){
        
        self.removeFileButton.isHighlighted = true
        
        self.delegate?.didTapFileIndicatorView()

    }
    
    //MARK: - add subViews
    
    /**
     This method instanciate,config and add an 'UIImageView' instance to self adding all necessary constraints
     This method is called on it's inits
     */
    fileprivate func initFileImageView(){
        
        fileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        
        fileImageView.contentMode = UIViewContentMode.scaleAspectFill
        
        fileImageView.backgroundColor = UIColor.blue
        
        fileImageView.layer.masksToBounds = true
        
        fileImageView.layer.cornerRadius = fileImageView.frame.height/4
        
        fileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(fileImageView)
        
        
        //Constraints
        
        let aspectRatio = NSLayoutConstraint(item: fileImageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: fileImageView, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)

        fileImageView.addConstraint(aspectRatio)
        
        leadingAlignmentConstraint = NSLayoutConstraint(item: fileImageView, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: self, attribute:NSLayoutAttribute.leading, multiplier: 1, constant:0)
        
        self.addConstraint(leadingAlignmentConstraint)
        
        let topAlignmentConstraint = NSLayoutConstraint(item: fileImageView, attribute: NSLayoutAttribute.top, relatedBy: .equal, toItem: self, attribute:NSLayoutAttribute.top, multiplier: 1, constant:0)
        
        self.addConstraint(topAlignmentConstraint)
        
        let bottomAlignmentConstraint = NSLayoutConstraint(item: fileImageView, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: self, attribute:NSLayoutAttribute.bottom, multiplier: 1, constant:0)
        
        self.addConstraint(bottomAlignmentConstraint)
        
    }
    
    /**
     This method instanciate,config and add an 'UILabel' instance to self adding all necessary constraints
     This method is called on it's inits
     */
    fileprivate func initFileTitleLabel(){
        
        self.fileTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 15))
        
        if let file = fileInformations{
            self.fileTitleLabel.text = file.title
        }
        else{
            self.fileTitleLabel.text = "arquivo"
        }
        
        
        self.fileTitleLabel.minimumScaleFactor = 0.5
        
        fileTitleLabel.translatesAutoresizingMaskIntoConstraints = false
                
        self.addSubview(fileTitleLabel)
        
        
        
        
        //constraints
        
        let leadingAlignmentConstraint = NSLayoutConstraint(item: fileTitleLabel, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: fileImageView, attribute:NSLayoutAttribute.trailing, multiplier: 1, constant:5)
        
        self.addConstraint(leadingAlignmentConstraint)
        
        let centerYConstraint =  NSLayoutConstraint(item: fileTitleLabel, attribute: NSLayoutAttribute.centerY, relatedBy: .equal, toItem: self, attribute:NSLayoutAttribute.centerY, multiplier: 1, constant:0)
        
        self.addConstraint(centerYConstraint)
        
       
    }
    
    /**
     This method instanciate,config and add an 'UIButton' instance to self adding all necessary constraints
     This method is called on it's inits
     */
    fileprivate func initRemoveFileButton(){
        
        removeFileButton = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        
        removeFileButton.setTitle("x", for: UIControlState())
        
        removeFileButton.tintColor = UIColor.gray
        
        removeFileButton.setTitleColor(UIColor.gray, for: UIControlState())
        
        removeFileButton.setTitleColor(UIColor.lightGray, for: UIControlState.highlighted)
        
        removeFileButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        removeFileButton.addTarget(self, action:#selector(JLFileIndicatorView.removeFileButtonAction(_:)), for: UIControlEvents.touchUpInside)
        
        self.addSubview(removeFileButton)
        
        
        
        
        
        //constraints
        
        let aspectRatio = NSLayoutConstraint(item: removeFileButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: removeFileButton, attribute: NSLayoutAttribute.height, multiplier: 0.5, constant: 0)
        
        removeFileButton.addConstraint(aspectRatio)
        
        let leadingAlignmentConstraint = NSLayoutConstraint(item: removeFileButton, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: fileTitleLabel, attribute:NSLayoutAttribute.trailing, multiplier: 1, constant:0)
        
        self.addConstraint(leadingAlignmentConstraint)
        
        let trailingAlignmentConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.trailing, relatedBy: .equal, toItem: removeFileButton, attribute:NSLayoutAttribute.trailing, multiplier: 1, constant:5)
        
        self.addConstraint(trailingAlignmentConstraint)
        
        let topAlignmentConstraint = NSLayoutConstraint(item: removeFileButton, attribute: NSLayoutAttribute.top, relatedBy: .equal, toItem: self, attribute:NSLayoutAttribute.top, multiplier: 1, constant:0)
        
        self.addConstraint(topAlignmentConstraint)
        
        let bottomAlignmentConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: removeFileButton, attribute:NSLayoutAttribute.bottom, multiplier: 1, constant:0)
        
        self.addConstraint(bottomAlignmentConstraint)
        

    }
    
}
