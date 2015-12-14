//
//  CustomTextView.swift
//  ecommerce
//
//  Created by José Lucas Souza das Chagas on 07/11/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit
//import QuartzCore

protocol FileDelegate{
    
    func fileAdded()
    
    func fileRemoved()
}


public class CustomTextView: UITextView,FileIndicatorViewDelegate {

    
    @IBInspectable var placeHolderText:String! = ""{
    
        didSet{
            self.placeHolder.placeholder = placeHolderText
        }
        
    }
    
    
    var placeHolder:UITextField!
    
    var placeHolderTopDist:NSLayoutConstraint!
    
    
    private var fileIndicatorView:FileIndicatorView!
    private var fileIndicatorViewHeight:NSLayoutConstraint!
    private let fileIndicatorViewHeightValue:CGFloat = 35
    private(set) var fileAddedState:Bool = false

   
    var fileDelegate:FileDelegate? //a delegate to notify when some file is added to it
    
    
    override public var text:String!{
        didSet{
            showPlaceHolder(!thereIsSomeText())
        }
    }
    
    override public var font:UIFont?{
        didSet{
            
            if placeHolder != nil {
                self.placeHolder.font = self.font
            }
            
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        
        super.init(frame: frame, textContainer: textContainer)
        configCornerRadius()

        self.initPlaceHolder(CGPoint(x:self.contentInset.left, y:self.contentInset.top), size: CGSize(width: 20, height: 10), text: "")
        
        self.initFileIndicator()

        
        self.registerTextViewNotifications()
        
        self.layoutIfNeeded()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configCornerRadius()


        self.initPlaceHolder(CGPoint(x:self.contentInset.left, y:self.contentInset.top), size: CGSize(width: 20, height: 10), text: "")

        self.initFileIndicator()

        
        registerTextViewNotifications()
        
        self.layoutIfNeeded()

    }
    
    
    private func configCornerRadius(){
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 6
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    
    
    
    

    public func thereIsSomeText()->Bool{
        
        for char in self.text.characters{
            if char != " " && char != "\n"{
                return true
            }
        }
        
        return false
    }
    
    func resetTextView(){
        self.scrollEnabled = false
        self.text = nil
        self.removeFile()

    }
    
    override public func paste(sender: AnyObject?) {
        
        super.paste(sender)
             
    }
    
    
    //MARK: - file indicator view delegate
    
    func didTapFileIndicatorView() {
        self.removeFile()
    }
    
    
    //MARK: - File added view
    
    
    
    //adiciona um indicador de que algum arquivo foi adicionado para ser enviado
    public func addFile(file:File){
        //caso o valor antigo de fileAddedState for true quer dizer que ja havia algo adicionado entao nao precisa ajeitar o textinsets
        let correctEdges:Bool = !fileAddedState
        
        fileAddedState = true
        
        fileDelegate?.fileAdded()
        
        self.fileIndicatorView.addFileInformations(file)
        
        fileIndicatorViewHeight.constant = fileIndicatorViewHeightValue
        
        
        var a = self.text
        
        a = a.stringByAppendingString(" ")
        
        self.text = a
        
        self.text = String(self.text.characters.dropLast())
        
        if correctEdges{
            self.correctEdgesForFile(self.fileIndicatorViewHeightValue)
        }

        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            self.layoutIfNeeded()
            

            }) { (finished) -> Void in
               
        }
        
        UIView.animateWithDuration(0.4, delay: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.showPlaceHolder(false)

            self.fileIndicatorView.alpha = 1

            }, completion: nil)
        
       

        
        
    }
    
    //remove o indicador de que algum arquivo foi adicionado para ser enviado

    public func removeFile(){
        
        if fileAddedState{
            fileAddedState = false
            
            fileDelegate?.fileRemoved()
            
            fileIndicatorViewHeight.constant = 0
            
            
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.fileIndicatorView.alpha = 0
                
                }, completion: nil)
            
            
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.layoutIfNeeded()
                self.fileIndicatorView.layoutIfNeeded()
                }) { (finished) -> Void in
                    var a = self.text
                    
                    a = a.stringByAppendingString(" ")
                    
                    self.text = a
                    
                    self.text = String(self.text.characters.dropLast())
                    
                    self.correctEdgesForFile(-self.fileIndicatorViewHeightValue)
                    
            }

        }
        
        
    }
    
    private func correctEdgesForFile(increaseAtTop:CGFloat){
        
        self.textContainerInset = UIEdgeInsets(top: self.textContainerInset.top + increaseAtTop, left: self.textContainerInset.left, bottom: self.textContainerInset.bottom, right: self.textContainerInset.right)
        self.placeHolderTopDist.constant = self.textContainerInset.top
        
    }
    
    
    func initFileIndicator(){
        
        fileIndicatorView = FileIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: fileIndicatorViewHeightValue))
        
        fileIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        self.fileIndicatorView.layer.zPosition = -1
        
        fileIndicatorView.alpha = 0
        
        fileIndicatorView.delegate = self
        
        self.addSubview(fileIndicatorView)
        
        
        //constraints
        
        fileIndicatorViewHeight = NSLayoutConstraint(item: fileIndicatorView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0)
        fileIndicatorView.addConstraint(fileIndicatorViewHeight)
        
        let leadingAlignmentConstraint = NSLayoutConstraint(item: fileIndicatorView, attribute: NSLayoutAttribute.Leading, relatedBy: .Equal, toItem: self, attribute:NSLayoutAttribute.Leading, multiplier: 1, constant: 5)
        self.addConstraint(leadingAlignmentConstraint)
        
        let topAlignmentConstraint = NSLayoutConstraint(item: fileIndicatorView, attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: self, attribute:NSLayoutAttribute.Top, multiplier: 1, constant: 5)
        self.addConstraint(topAlignmentConstraint)
        

        
        let width = NSLayoutConstraint(item: fileIndicatorView, attribute: NSLayoutAttribute.Width, relatedBy:NSLayoutRelation.LessThanOrEqual, toItem: self, attribute:NSLayoutAttribute.Width, multiplier: 1, constant: -5)
        self.addConstraint(width)



    }
    
       
    //MARK: - placeHolder methods
    
    
    private func initPlaceHolder(position:CGPoint,size:CGSize,text:String){
        placeHolder = UITextField(frame: CGRect(origin: position, size: size))
        placeHolder.placeholder = text
        placeHolder.enabled = false
        placeHolder.userInteractionEnabled = false
        placeHolder.font = self.font
        //do not add automatically the constraints
        placeHolder.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(placeHolder)
        
        //constraints
        
        // leading alignment
        let leadingAlignmentConstraint = NSLayoutConstraint(item: placeHolder, attribute: NSLayoutAttribute.Leading, relatedBy: .Equal, toItem: self, attribute:NSLayoutAttribute.Leading, multiplier: 1, constant: 5 + self.textContainerInset.left)
        self.addConstraint(leadingAlignmentConstraint)
        
        // top
        placeHolderTopDist = NSLayoutConstraint(item: placeHolder, attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: self.textContainerInset.top/*8 + self.contentInset.top*/)
        
        self.addConstraint(placeHolderTopDist)

    }
    
    private func showPlaceHolder(show:Bool){
        placeHolder.hidden = !show
    }

    
    //MARK: - notifications
    
    private func registerTextViewNotifications(){
        
        //UITextViewTextDidChangeNotification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didChangeText:", name: UITextViewTextDidChangeNotification, object: nil)
        
    }
    
    func didChangeText(notification:NSNotification){
                        
        if thereIsSomeText(){
            showPlaceHolder(false)
        }
        else{
            showPlaceHolder(true)
        }
        
    }
    
    
   
}
