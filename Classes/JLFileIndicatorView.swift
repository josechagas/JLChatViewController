//
//  JLFileIndicatorView.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 03/12/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit


protocol FileIndicatorViewDelegate{
    
    func didTapFileIndicatorView()
}

public class JLFileIndicatorView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    
    private var fileImageView:UIImageView!
    private var leadingAlignmentConstraint:NSLayoutConstraint!

    
    private var fileTitleLabel:UILabel!
    
    private var removeFileButton:UIButton!
    
    private var fileInformations:JLFile?
    
    
    var delegate:FileIndicatorViewDelegate?
    
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
    
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        if let file = fileInformations, _ = file.image{
            leadingAlignmentConstraint.constant = 0
        }
        else{
            leadingAlignmentConstraint.constant = -self.fileImageView.frame.width
        }
        self.layoutIfNeeded()
    }
        
    private func  configView(){
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.height/4
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1).CGColor
        
    }
    
    
    func addFileInformations(file:JLFile){
        
        if let image = file.image{
            fileImageView.image = image
        }
                
        self.fileTitleLabel.text = file.title
        
        self.fileInformations = file
    }
    
    
    
    //MARK: - Gesture reognizers
    
    private func addGestures(){
        
        let tap = UITapGestureRecognizer(target: self, action: "target:")
        self.addGestureRecognizer(tap)
    }
    
    func target(tapGes:UITapGestureRecognizer){
        
        self.removeFileButton.highlighted = true
        
        self.delegate?.didTapFileIndicatorView()
        
    }
    
    func removeFileButtonAction(sender:AnyObject?){
        
        self.removeFileButton.highlighted = true
        
        self.delegate?.didTapFileIndicatorView()

    }
    
    //MARK: - add subViews
    

    private func initFileImageView(){
        
        fileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        
        fileImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        fileImageView.backgroundColor = UIColor.blueColor()
        
        fileImageView.layer.masksToBounds = true
        
        fileImageView.layer.cornerRadius = fileImageView.frame.height/4
        
        fileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(fileImageView)
        
        
        //Constraints
        
        let aspectRatio = NSLayoutConstraint(item: fileImageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: fileImageView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)

        fileImageView.addConstraint(aspectRatio)
        
        leadingAlignmentConstraint = NSLayoutConstraint(item: fileImageView, attribute: NSLayoutAttribute.Leading, relatedBy: .Equal, toItem: self, attribute:NSLayoutAttribute.Leading, multiplier: 1, constant:0)
        
        self.addConstraint(leadingAlignmentConstraint)
        
        let topAlignmentConstraint = NSLayoutConstraint(item: fileImageView, attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: self, attribute:NSLayoutAttribute.Top, multiplier: 1, constant:0)
        
        self.addConstraint(topAlignmentConstraint)
        
        let bottomAlignmentConstraint = NSLayoutConstraint(item: fileImageView, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: self, attribute:NSLayoutAttribute.Bottom, multiplier: 1, constant:0)
        
        self.addConstraint(bottomAlignmentConstraint)
        
    }
    
    private func initFileTitleLabel(){
        
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
        
        let leadingAlignmentConstraint = NSLayoutConstraint(item: fileTitleLabel, attribute: NSLayoutAttribute.Leading, relatedBy: .Equal, toItem: fileImageView, attribute:NSLayoutAttribute.Trailing, multiplier: 1, constant:5)
        
        self.addConstraint(leadingAlignmentConstraint)
        
        let centerYConstraint =  NSLayoutConstraint(item: fileTitleLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: self, attribute:NSLayoutAttribute.CenterY, multiplier: 1, constant:0)
        
        self.addConstraint(centerYConstraint)
        
       
    }
    
    
    private func initRemoveFileButton(){
        
        removeFileButton = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        
        removeFileButton.setTitle("x", forState: UIControlState.Normal)
        
        removeFileButton.tintColor = UIColor.grayColor()
        
        removeFileButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        
        removeFileButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Highlighted)
        
        removeFileButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        removeFileButton.addTarget(self, action: "removeFileButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(removeFileButton)
        
        
        
        
        
        //constraints
        
        let aspectRatio = NSLayoutConstraint(item: removeFileButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: removeFileButton, attribute: NSLayoutAttribute.Height, multiplier: 0.5, constant: 0)
        
        removeFileButton.addConstraint(aspectRatio)
        
        let leadingAlignmentConstraint = NSLayoutConstraint(item: removeFileButton, attribute: NSLayoutAttribute.Leading, relatedBy: .Equal, toItem: fileTitleLabel, attribute:NSLayoutAttribute.Trailing, multiplier: 1, constant:0)
        
        self.addConstraint(leadingAlignmentConstraint)
        
        let trailingAlignmentConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Trailing, relatedBy: .Equal, toItem: removeFileButton, attribute:NSLayoutAttribute.Trailing, multiplier: 1, constant:5)
        
        self.addConstraint(trailingAlignmentConstraint)
        
        let topAlignmentConstraint = NSLayoutConstraint(item: removeFileButton, attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: self, attribute:NSLayoutAttribute.Top, multiplier: 1, constant:0)
        
        self.addConstraint(topAlignmentConstraint)
        
        let bottomAlignmentConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: removeFileButton, attribute:NSLayoutAttribute.Bottom, multiplier: 1, constant:0)
        
        self.addConstraint(bottomAlignmentConstraint)
        

    }
    
}
