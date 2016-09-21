//
//  JLChatToolBar.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 28/11/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit

/**
 Implement this protocol for you can respond to touch events on ChatToolBar buttons
*/
public protocol ChatToolBarDelegate{
    
    /**
    Called always when the user taps the left side button
    */
    func didTapLeftButton()
    /**
     * Called always when the user taps the right side button
     */
    func didTapRightButton()
}


public protocol ToolBarFrameDelegate{
    func haveToUpdateInsetsBottom(_ bottom:CGFloat,scrollToBottom:Bool)
}




open class JLChatToolBar: UIToolbar,UITextViewDelegate,FileDelegate {
    
    override open var frame:CGRect{
        didSet{
            toolBarFrameDelegate?.haveToUpdateInsetsBottom(keyBoadHeight + self.frame.height,scrollToBottom: false)
        }
    }

    /**
     This is used to control the max possible height the tool bar based on device dimensions, its to avoid the toolbar to get all screen
     */
    fileprivate var maxAllowedHeight:CGFloat{
        get{
            let screenRect = UIScreen.main.bounds
            //let actualAspectRatio = screenRect.size.height/screenRect.size.width
            let value = (screenRect.size.height - self.keyBoadHeight)/4
            return value
        }
    }
    
    /**
     The instance of the textView where you write your message and add an indicator of file
     */
    open fileprivate(set) var inputText:JLCustomTextView!
    
    
    
    open fileprivate(set) var rightButton:UIButton!
    
    open fileprivate(set) var leftButton:UIButton!
    
    open var toolBarDelegate:ChatToolBarDelegate?
    
    open var toolBarFrameDelegate:ToolBarFrameDelegate?{
        didSet{
            toolBarFrameDelegate?.haveToUpdateInsetsBottom(keyBoadHeight + self.frame.height,scrollToBottom: false)
        }
    }
    
    fileprivate var lastToolBarHeight:CGFloat = 0
    
    var keyBoadHeight:CGFloat = 0//used to help in the correction of the chat tableView insets
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubViews()//add subview into toolbar
        self.addButtonsActions()//add buttons action to call delegate
        
        self.registerKeyBoardNotifications()//observe for changes on state of the keyboard
        
        addObserver()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubViews()//add subview into toolbar
        self.addButtonsActions()//add buttons action to call delegate
        
        self.registerKeyBoardNotifications()//observe for changes on state of the keyboard
        
        addObserver()

    }
    
    //MARK: - Frame change delegate
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "center"{
            
            toolBarFrameDelegate?.haveToUpdateInsetsBottom(keyBoadHeight + self.frame.height,scrollToBottom: lastToolBarHeight < self.frame.height)
        
            self.lastToolBarHeight = self.frame.height
        }
        
    }
    
    
    fileprivate func addObserver(){
        
        self.addObserver(self, forKeyPath: "center", options: NSKeyValueObservingOptions.new, context: nil)
        
    }
    
    
    //MARK: - Config subViews
    
    /**
    Use this method for you configure the textView of your chat
    - parameter font: The font of the 'JLCustomTextView'
    - parameter textColor: The color of the text of the 'JLCustomTextView'
    - parameter placeHolder: The text that will be shown when there is nothing on 'JLCustomTextView'

    */
    open func configToolInputText(_ font:UIFont,textColor:UIColor?,placeHolder:String?){
        
        self.inputText.textColor = textColor
        self.inputText.font = font
        inputText.delegate = self

        if let placeHolder = placeHolder{
            self.inputText.placeHolderText = placeHolder
        }
        
    }
    
    /**
     Use this method for you set left button title and or image
     - parameter title: title of the button
     - parameter image: the image of the button
    */
    open func configLeftButton(_ title:String?,image:UIImage?){
        
        self.leftButton.setTitle(title, for: UIControlState())
        
        self.leftButton.setImage(image, for: UIControlState())
    
    }
    /**
     Use this method for you set right button title and or image
     - parameter title: title of the button
     - parameter image: the image of the button
     */
    open func configRightButton(_ title:String?,image:UIImage?){
        
        self.rightButton.setTitle(title, for: UIControlState())
        
        self.rightButton.setImage(image, for: UIControlState())
       
    }
    
    fileprivate func addButtonsActions(){
    
        leftButton.addTarget(self, action:#selector(JLChatToolBar.leftButtonAction(_:)), for: UIControlEvents.touchUpInside)
        rightButton.addTarget(self, action:#selector(JLChatToolBar.rightButtonAction(_:)), for: UIControlEvents.touchUpInside)
    }
    
    
    
    //MARK: - Buttons actions
    
    
    func leftButtonAction(_ sender:AnyObject?){
        
        toolBarDelegate?.didTapLeftButton()
        
    }
    
    
    func rightButtonAction(_ sender:AnyObject?){
        toolBarDelegate?.didTapRightButton()
        self.inputText.resetTextView()
        self.rightButton.isEnabled = self.inputText.thereIsSomeText()
    }
    
    
    //MARK: - TextView delegate
    
    open func textViewDidBeginEditing(_ textView: UITextView) {
        self.rightButton.isEnabled = self.inputText.thereIsSomeText() || self.inputText.fileAddedState
    }
    
    open func textViewDidChange(_ textView: UITextView) {
        
        self.rightButton.isEnabled = self.inputText.thereIsSomeText() || self.inputText.fileAddedState
        
        if !self.inputText.thereIsSomeChar(){
            self.inputText.resetTextView()
        }
    }
    
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if inputText.contentSize.height >= maxAllowedHeight{
            inputText.isScrollEnabled = true
            inputText.frame.size = CGSize(width: inputText.frame.width, height: inputText.frame.height)
        }
        else{
            inputText.frame.size = CGSize(width: inputText.frame.width, height: inputText.contentSize.height)
            inputText.isScrollEnabled = false
        }
        
        return true
        
    }
    
    //MARK: - JLCustomTextViewSizeDelegate
    /*func haveToUpdateSize(customTextView: JLCustomTextView, suggestedSize: CGSize) -> CGSize {
        var newSize:CGSize! = suggestedSize
        
        if customTextView.scrollEnabled{
            newSize = CGSize(width: suggestedSize.width, height: self.inputText.frame.height)
        }
        else{
            if suggestedSize.height >= maxAllowedHeight{
                customTextView.scrollEnabled = true
                newSize = CGSize(width: suggestedSize.width, height: self.inputText.contentSize.height)
            }
            else{
                self.inputText.scrollEnabled = false
            }

        }
        return suggestedSize
    }*/
    
    
    //MARK: - File Delegate methods
    
    func fileAdded() {
        self.rightButton.isEnabled = self.inputText.thereIsSomeText() || true
    }
    
    func fileRemoved() {
        self.rightButton.isEnabled = self.inputText.thereIsSomeText() || false
    }
    
    /**
     Use this method for you know if there is some file added to be sent
     - returns : True if there is a file added and False if there is not.
    */
    open func thereIsSomeFileAdded()->Bool{
        return self.inputText.fileAddedState
    }
    
    
    //MARK: - KeyBoard notifications
    
    func registerKeyBoardNotifications(){
        
        NotificationCenter.default.addObserver(self, selector:#selector(JLChatToolBar.showkeyBoardTarget(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector:#selector(JLChatToolBar.hideKeyBoardTarget(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func showkeyBoardTarget(_ notification:Notification){
        
        let info = (notification as NSNotification).userInfo as! [String:AnyObject]
        
        let keyBoardFrame = info[UIKeyboardFrameEndUserInfoKey]?.cgRectValue
        
        keyBoadHeight = keyBoardFrame!.height
        
        toolBarFrameDelegate?.haveToUpdateInsetsBottom(keyBoadHeight + self.frame.height,scrollToBottom: true)

    }
    
    
    
    func hideKeyBoardTarget(_ notification:Notification){
        
        keyBoadHeight = 0

        toolBarFrameDelegate?.haveToUpdateInsetsBottom(keyBoadHeight + self.frame.height,scrollToBottom: false)

    }

    
    
    
    //MARK: - add Subviews
    
    fileprivate func addSubViews(){
        
        initLeftButton()
        initRightButton()
        initTextView()
        self.layoutIfNeeded()
        
    }
    
    
    //create and add the left button to the toolBar
    fileprivate func initLeftButton(){
        
        leftButton = UIButton(frame: CGRect(origin: CGPoint(x: 5, y: 5), size: CGSize(width: 46, height: self.frame.size.height - 10)))
        
        leftButton.setTitle("File", for: UIControlState())
        leftButton.setTitleColor(UIColor.blue, for: UIControlState())
        leftButton.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        leftButton.setTitleColor(UIColor.gray, for: UIControlState.disabled)

        leftButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(leftButton)
        
        
        
    
        let bottomDist =  NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: leftButton, attribute:NSLayoutAttribute.bottom, multiplier: 1, constant: 5)
        
        self.addConstraint(bottomDist)
        
        let leftDist = NSLayoutConstraint(item: leftButton, attribute: NSLayoutAttribute.left, relatedBy: .equal, toItem: self, attribute:NSLayoutAttribute.left, multiplier: 1, constant: 5)
        
        self.addConstraint(leftDist)
        
        
        
        //Height and Width
        
        
        let height =  NSLayoutConstraint(item: leftButton, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: nil, attribute:NSLayoutAttribute.notAnAttribute, multiplier: 1, constant:leftButton.frame.height)
        
        leftButton.addConstraint(height)
        
        let width =  NSLayoutConstraint(item: leftButton, attribute: NSLayoutAttribute.width, relatedBy: .equal, toItem: nil, attribute:NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: leftButton.frame.width)
        
        leftButton.addConstraint(width)


    }
    
    //create and add the right button into tooBar
    fileprivate func initRightButton(){
        
        rightButton = UIButton(frame: CGRect(origin: CGPoint(x: self.frame.size.width - 5 - 46, y: 5), size: CGSize(width: 46, height: self.frame.size.height - 10)))
        rightButton.setTitle("Send", for: UIControlState())
        rightButton.setTitleColor(UIColor.blue, for: UIControlState())
        rightButton.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        rightButton.setTitleColor(UIColor.gray, for: UIControlState.disabled)

        rightButton.isEnabled = false
        
        
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(rightButton)
        
        
        
        let bottomDist =  NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: rightButton, attribute:NSLayoutAttribute.bottom, multiplier: 1, constant: 5)
        
        self.addConstraint(bottomDist)
    
        let rightDist = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.right, relatedBy: .equal, toItem: rightButton, attribute:NSLayoutAttribute.right, multiplier: 1, constant: 5)
        
        self.addConstraint(rightDist)
        
        
        //Height and Width
        
        
        let height =  NSLayoutConstraint(item: rightButton, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: nil, attribute:NSLayoutAttribute.notAnAttribute, multiplier: 1, constant:rightButton.frame.height)
        
        rightButton.addConstraint(height)
        
        let width =  NSLayoutConstraint(item: rightButton, attribute: NSLayoutAttribute.width, relatedBy: .equal, toItem: nil, attribute:NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: rightButton.frame.width)
        
        rightButton.addConstraint(width)


    }

    //create and add textView into ToolBar
    
    fileprivate func initTextView(){
                
        inputText = JLCustomTextView(frame: CGRect(origin: CGPoint(x: 40, y: 5), size: CGSize(width: self.frame.size.width - 80, height: self.frame.size.height - 10)))
        inputText.font = JLChatAppearence.chatFont
        inputText.isScrollEnabled = false
        inputText.fileDelegate = self
        inputText.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(inputText)
        
        
        
        let topDist =  NSLayoutConstraint(item: inputText, attribute: NSLayoutAttribute.top, relatedBy: .equal, toItem: self, attribute:NSLayoutAttribute.top, multiplier: 1, constant: 7)

        self.addConstraint(topDist)
        
        let bottomDist =  NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: inputText, attribute:NSLayoutAttribute.bottom, multiplier: 1, constant: 7)

        self.addConstraint(bottomDist)
        
        
        //dist to left button
        let leftDist = NSLayoutConstraint(item: inputText, attribute: NSLayoutAttribute.left, relatedBy: .equal, toItem: leftButton, attribute:NSLayoutAttribute.right, multiplier: 1, constant: 5)
        
        self.addConstraint(leftDist)
        
        //dist to right button
        let rightDist = NSLayoutConstraint(item: inputText, attribute: NSLayoutAttribute.right, relatedBy: .equal, toItem: rightButton, attribute:NSLayoutAttribute.left, multiplier: 1, constant: -5)
        
        self.addConstraint(rightDist)

    }
    
    
}
