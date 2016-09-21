//
//  JLCustomTextView.swift
//  ecommerce
//
//  Created by José Lucas Souza das Chagas on 07/11/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit
//import QuartzCore

/**
 A delegate that notifies when a file is added or removed
 */
protocol FileDelegate{
    
    func fileAdded()
    
    func fileRemoved()
}



open class JLCustomTextView: UITextView,FileIndicatorViewDelegate {

    
    @IBInspectable var placeHolderText:String! = ""{
    
        didSet{
            self.placeHolder.placeholder = placeHolderText
        }
        
    }
    
    
    var placeHolder:UITextField!
    
    var placeHolderTopDist:NSLayoutConstraint!
    
    
    fileprivate var fileIndicatorView:JLFileIndicatorView!
    fileprivate var fileIndicatorViewHeight:NSLayoutConstraint!
    fileprivate let fileIndicatorViewHeightValue:CGFloat = 35
    fileprivate(set) var fileAddedState:Bool = false

   
    var fileDelegate:FileDelegate? //a delegate to notify when some file is added to it
    
    override open var text:String!{
        didSet{
            showPlaceHolder(!thereIsSomeText())
        }
    }
    
    override open var font:UIFont?{
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
    
    open override var intrinsicContentSize : CGSize {
        
        return super.intrinsicContentSize
        
    }
    
    fileprivate func configCornerRadius(){
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 6
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.gray.cgColor
    }
    
    
    
    
    
    /**
    Use this method for you know if there is some text.
    
    If you want to see if there is some character including \n for example use thereIsSomeChar() instead
     
    - returns : true if there is some text and false if there is not text
    */
    open func thereIsSomeText()->Bool{
        
        for char in self.text.characters{
            if char != " " && char != "\n"{
                return true
            }
        }
        
        return false
    }
    
    /**
     Use this method for you know if there is some character.
     - returns : true if there is some character and false if there is not
     */
    open func thereIsSomeChar()->Bool{
        return self.text.characters.count > 0
    }
    
    /**
     Reset the textView for its default state.
    */
    func resetTextView(){
        self.isScrollEnabled = false
        self.text = nil
        self.removeFile()

    }
    
    override open func paste(_ sender: AnyObject?) {
        
        super.paste(sender)
             
    }
    
    
    //MARK: - file indicator view delegate
    
    func didTapFileIndicatorView() {
        self.removeFile()
    }
    
    
    //MARK: - File added view
    
    
    /**
    Add a indicator of file added with 'JLFile' informations
    - parameter file: The 'JLFile' containing the informations
    */
    open func addFile(_ file:JLFile){
        //caso o valor antigo de fileAddedState for true quer dizer que ja havia algo adicionado entao nao precisa ajeitar o textinsets
        let correctEdges:Bool = !fileAddedState
        
        fileAddedState = true
        
        fileDelegate?.fileAdded()
        
        self.fileIndicatorView.addFileInformations(file)
        
        fileIndicatorViewHeight.constant = fileIndicatorViewHeightValue
        
        
       
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            
            self.layoutIfNeeded()
            

            }) { (finished) -> Void in
                var a = self.text
                
                a = a! + " "
                
                self.text = a
                
                self.text = String(self.text.characters.dropLast())
                
                if correctEdges{
                    self.correctEdgesForFile(self.fileIndicatorViewHeightValue)
                }

        }
        
        UIView.animate(withDuration: 0.4, delay: 0.3, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.showPlaceHolder(false)

            self.fileIndicatorView.alpha = 1

            }, completion: nil)
        
       

        
        
    }
    
    /**
    Remove the indicator of file added
    */
    open func removeFile(){
        
        if fileAddedState{
            fileAddedState = false
            
            fileDelegate?.fileRemoved()
            
            fileIndicatorViewHeight.constant = 0
            
            
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.fileIndicatorView.alpha = 0
                
                }, completion: nil)
            
            
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.layoutIfNeeded()
                self.fileIndicatorView.layoutIfNeeded()
                }) { (finished) -> Void in
                    var a = self.text
                    
                    a = a! + " "
                    
                    self.text = a
                    
                    self.text = String(self.text.characters.dropLast())
                    
                    self.correctEdgesForFile(-self.fileIndicatorViewHeightValue)
                    
            }

        }
        
        
    }
    
    fileprivate func correctEdgesForFile(_ increaseAtTop:CGFloat){
        
        self.textContainerInset = UIEdgeInsets(top: self.textContainerInset.top + increaseAtTop, left: self.textContainerInset.left, bottom: self.textContainerInset.bottom, right: self.textContainerInset.right)
        self.placeHolderTopDist.constant = self.textContainerInset.top
        
    }
    
    
    func initFileIndicator(){
        
        fileIndicatorView = JLFileIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: fileIndicatorViewHeightValue))
        
        fileIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        self.fileIndicatorView.layer.zPosition = -1
        
        fileIndicatorView.alpha = 0
        
        fileIndicatorView.delegate = self
        
        self.addSubview(fileIndicatorView)
        
        
        //constraints
        
        fileIndicatorViewHeight = NSLayoutConstraint(item: fileIndicatorView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 0)
        fileIndicatorView.addConstraint(fileIndicatorViewHeight)
        
        let leadingAlignmentConstraint = NSLayoutConstraint(item: fileIndicatorView, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: self, attribute:NSLayoutAttribute.leading, multiplier: 1, constant: 5)
        self.addConstraint(leadingAlignmentConstraint)
        
        let topAlignmentConstraint = NSLayoutConstraint(item: fileIndicatorView, attribute: NSLayoutAttribute.top, relatedBy: .equal, toItem: self, attribute:NSLayoutAttribute.top, multiplier: 1, constant: 5)
        self.addConstraint(topAlignmentConstraint)
        

        
        let width = NSLayoutConstraint(item: fileIndicatorView, attribute: NSLayoutAttribute.width, relatedBy:NSLayoutRelation.lessThanOrEqual, toItem: self, attribute:NSLayoutAttribute.width, multiplier: 1, constant: -5)
        self.addConstraint(width)



    }
    
       
    //MARK: - placeHolder methods
    
    
    fileprivate func initPlaceHolder(_ position:CGPoint,size:CGSize,text:String){
        placeHolder = UITextField(frame: CGRect(origin: position, size: size))
        placeHolder.placeholder = text
        placeHolder.isEnabled = false
        placeHolder.isUserInteractionEnabled = false
        placeHolder.font = self.font
        //do not add automatically the constraints
        placeHolder.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(placeHolder)
        
        //constraints
        
        // leading alignment
        let leadingAlignmentConstraint = NSLayoutConstraint(item: placeHolder, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: self, attribute:NSLayoutAttribute.leading, multiplier: 1, constant: 5 + self.textContainerInset.left)
        self.addConstraint(leadingAlignmentConstraint)
        
        // top
        placeHolderTopDist = NSLayoutConstraint(item: placeHolder, attribute: NSLayoutAttribute.top, relatedBy: .equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: self.textContainerInset.top/*8 + self.contentInset.top*/)
        
        self.addConstraint(placeHolderTopDist)

    }
    
    fileprivate func showPlaceHolder(_ show:Bool){
        placeHolder.isHidden = !show
    }

    
    //MARK: - notifications
    
    fileprivate func registerTextViewNotifications(){
        
        //UITextViewTextDidChangeNotification
        NotificationCenter.default.addObserver(self, selector:#selector(JLCustomTextView.didChangeText(_:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
        
    }
    
    func didChangeText(_ notification:Notification){
                        
        if thereIsSomeChar(){
            showPlaceHolder(false)
        }
        else{
            showPlaceHolder(true)
        }
        
    }
    
    
   
}
