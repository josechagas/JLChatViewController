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
    func haveToUpdateInsetsBottom(bottom:CGFloat,scrollToBottom:Bool)
}




public class JLChatToolBar: UIToolbar,UITextViewDelegate,FileDelegate {
    
    override public var frame:CGRect{
        didSet{
            toolBarFrameDelegate?.haveToUpdateInsetsBottom(keyBoadHeight + self.frame.height,scrollToBottom: false)
        }
    }
    
    /**
     The instance of the textView where you write your message and add an indicator of file
     */
    public private(set) var inputText:JLCustomTextView!
    
    
    
    public private(set) var rightButton:UIButton!
    
    public private(set) var leftButton:UIButton!
    
    public var toolBarDelegate:ChatToolBarDelegate?
    
    public var toolBarFrameDelegate:ToolBarFrameDelegate?
    
    private var lastToolBarHeight:CGFloat = 0
    
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
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        
        
        
        if keyPath == "center"{
            
            toolBarFrameDelegate?.haveToUpdateInsetsBottom(keyBoadHeight + self.frame.height,scrollToBottom: lastToolBarHeight < self.frame.height)
        
            self.lastToolBarHeight = self.frame.height
        }
        
    }
    
    
    private func addObserver(){
        
        self.addObserver(self, forKeyPath: "center", options: NSKeyValueObservingOptions.New, context: nil)
        
    }
    
    
    //MARK: - Config subViews
    
    /**
    Use this method for you configure the textView of your chat
    - parameter font: The font of the 'JLCustomTextView'
    - parameter textColor: The color of the text of the 'JLCustomTextView'
    - parameter placeHolder: The text that will be shown when there is nothing on 'JLCustomTextView'

    */
    public func configToolInputText(font:UIFont,textColor:UIColor?,placeHolder:String?){
        
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
    public func configLeftButton(title:String?,image:UIImage?){
        
        self.leftButton.setTitle(title, forState: UIControlState.Normal)
        
        self.leftButton.setImage(image, forState: UIControlState.Normal)
    
    }
    /**
     Use this method for you set right button title and or image
     - parameter title: title of the button
     - parameter image: the image of the button
     */
    public func configRightButton(title:String?,image:UIImage?){
        
        self.rightButton.setTitle(title, forState: UIControlState.Normal)
        
        self.rightButton.setImage(image, forState: UIControlState.Normal)
       
    }
    
    private func addButtonsActions(){
    
        leftButton.addTarget(self, action: "leftButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        rightButton.addTarget(self, action: "rightButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    
    
    //MARK: - Buttons actions
    
    
    func leftButtonAction(sender:AnyObject?){
        
        toolBarDelegate?.didTapLeftButton()
        
    }
    
    
    func rightButtonAction(sender:AnyObject?){
        toolBarDelegate?.didTapRightButton()
        self.inputText.resetTextView()
        self.rightButton.enabled = self.inputText.thereIsSomeText()
    }
    
    
    //MARK: - TextView delegate
    
    public func textViewDidBeginEditing(textView: UITextView) {
        self.rightButton.enabled = self.inputText.thereIsSomeText()
    }
    
    public func textViewDidChange(textView: UITextView) {
        
        self.rightButton.enabled = self.inputText.thereIsSomeText()
        
    }
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if self.frame.height >= 196 && !self.inputText.scrollEnabled{
            
            self.inputText.scrollEnabled = true
            
        }
        return true
        
    }
    
    
    
    //MARK: - File Delegate methods
    
    func fileAdded() {
        self.rightButton.enabled = self.inputText.thereIsSomeText() || true
    }
    
    func fileRemoved() {
        self.rightButton.enabled = self.inputText.thereIsSomeText() || false
    }
    
    /**
     Use this method for you know if there is some file added to be sent
     - returns : True if there is a file added and False if there is not.
    */
    public func thereIsSomeFileAdded()->Bool{
        return self.inputText.fileAddedState
    }
    
    
    //MARK: - KeyBoard notifications
    
    func registerKeyBoardNotifications(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showkeyBoardTarget:", name: UIKeyboardWillShowNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideKeyBoardTarget:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func showkeyBoardTarget(notification:NSNotification){
        
        let info = notification.userInfo as! [String:AnyObject]
        
        let keyBoardFrame = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
        
        keyBoadHeight = keyBoardFrame!.height
        
        toolBarFrameDelegate?.haveToUpdateInsetsBottom(keyBoadHeight + self.frame.height,scrollToBottom: true)

    }
    
    
    
    func hideKeyBoardTarget(notification:NSNotification){
        
        keyBoadHeight = 0

        toolBarFrameDelegate?.haveToUpdateInsetsBottom(keyBoadHeight + self.frame.height,scrollToBottom: false)

    }

    
    
    
    //MARK: - add Subviews
    
    private func addSubViews(){
        
        initLeftButton()
        initRightButton()
        initTextView()
        self.layoutIfNeeded()
        
    }
    
    
    //create and add the left button to the toolBar
    private func initLeftButton(){
        
        leftButton = UIButton(frame: CGRect(origin: CGPoint(x: 5, y: 5), size: CGSize(width: 46, height: self.frame.size.height - 10)))
        
        leftButton.setTitle("File", forState: UIControlState.Normal)
        leftButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        leftButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        leftButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)

        leftButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(leftButton)
        
        
        
    
        let bottomDist =  NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: leftButton, attribute:NSLayoutAttribute.Bottom, multiplier: 1, constant: 5)
        
        self.addConstraint(bottomDist)
        
        let leftDist = NSLayoutConstraint(item: leftButton, attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: self, attribute:NSLayoutAttribute.Left, multiplier: 1, constant: 5)
        
        self.addConstraint(leftDist)
        
        
        
        //Height and Width
        
        
        let height =  NSLayoutConstraint(item: leftButton, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant:leftButton.frame.height)
        
        leftButton.addConstraint(height)
        
        let width =  NSLayoutConstraint(item: leftButton, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: leftButton.frame.width)
        
        leftButton.addConstraint(width)


    }
    
    //create and add the right button into tooBar
    private func initRightButton(){
        
        rightButton = UIButton(frame: CGRect(origin: CGPoint(x: self.frame.size.width - 5 - 46, y: 5), size: CGSize(width: 46, height: self.frame.size.height - 10)))
        rightButton.setTitle("Send", forState: UIControlState.Normal)
        rightButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        rightButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        rightButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)

        rightButton.enabled = false
        
        
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(rightButton)
        
        
        
        let bottomDist =  NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: rightButton, attribute:NSLayoutAttribute.Bottom, multiplier: 1, constant: 5)
        
        self.addConstraint(bottomDist)
    
        let rightDist = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Right, relatedBy: .Equal, toItem: rightButton, attribute:NSLayoutAttribute.Right, multiplier: 1, constant: 5)
        
        self.addConstraint(rightDist)
        
        
        //Height and Width
        
        
        let height =  NSLayoutConstraint(item: rightButton, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant:rightButton.frame.height)
        
        rightButton.addConstraint(height)
        
        let width =  NSLayoutConstraint(item: rightButton, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: rightButton.frame.width)
        
        rightButton.addConstraint(width)


    }

    //create and add textView into ToolBar
    
    private func initTextView(){
                
        inputText = JLCustomTextView(frame: CGRect(origin: CGPoint(x: 40, y: 5), size: CGSize(width: self.frame.size.width - 80, height: self.frame.size.height - 10)))
        inputText.font = JLChatAppearence.chatFont
        inputText.scrollEnabled = false
        inputText.fileDelegate = self
        inputText.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.addSubview(inputText)
        
        
        
        let topDist =  NSLayoutConstraint(item: inputText, attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: self, attribute:NSLayoutAttribute.Top, multiplier: 1, constant: 7)

        self.addConstraint(topDist)
        
        let bottomDist =  NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: inputText, attribute:NSLayoutAttribute.Bottom, multiplier: 1, constant: 7)

        self.addConstraint(bottomDist)
        
        
        //dist to left button
        let leftDist = NSLayoutConstraint(item: inputText, attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: leftButton, attribute:NSLayoutAttribute.Right, multiplier: 1, constant: 5)
        
        self.addConstraint(leftDist)
        
        //dist to right button
        let rightDist = NSLayoutConstraint(item: inputText, attribute: NSLayoutAttribute.Right, relatedBy: .Equal, toItem: rightButton, attribute:NSLayoutAttribute.Left, multiplier: 1, constant: -5)
        
        self.addConstraint(rightDist)

    }
    
    
}
