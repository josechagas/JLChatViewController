//
//  JLImageMessageCell.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 02/12/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit
//346

open class JLImageMessageCell: JLChatMessageCell {

    /**
     Image that is related with the message
    */
    @IBOutlet open weak var messageImageView: JLChatImageView!
    /**
     Image of the one that sent the message
    */
    @IBOutlet open weak var senderImageView: UIImageView!
    

    /**
     The button that indicates that the message status is 'MessageSendStatus.ErrorToSend'
     */
    @IBOutlet open weak var errorButton: UIButton!
   
    
    
    
    /**
     This is a constraint of 'errorButton' do not change its value if you do not know what exactly you are doing.
     
     This constraint represents the dist between 'errorButton' and 'messageImageView'.
     */
    @IBOutlet weak var errorButtonDist: NSLayoutConstraint!
    
    
    // sender image constraints
    /**
    This is a constraint of 'senderImageView' do not change its value manually.
    
    Changes on it are made by 'JLChatAppearance'
    */
    @IBOutlet weak var senderImageViewheight: NSLayoutConstraint!
    
    /**
     This is a constraint of 'senderImageView' do not change its value manually.
     
     Changes on it are made by 'JLChatAppearance'
     */
    @IBOutlet weak var senderImageViewWidth: NSLayoutConstraint!
    
    /**
     Image dist to right or left side of superview do not change its value manually
     Changes on it are made on config methods of this class
     */
    @IBOutlet weak var imageDistToSide: NSLayoutConstraint!
    
    
    @IBOutlet weak var senderImageBottomToBubbleBottom: NSLayoutConstraint!
    @IBOutlet weak var senderImageToBubble: NSLayoutConstraint!
    
    
    //This is a value to garantee that we will not mask the same image twice for the same cell
    open var usedImageIdentifier:Int = 0
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override open func prepareForReuse() {
        //messageImageView.image = nil
        //senderImageView.image = nil
        self.hideErrorButton(false)

    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    open override func initCell(_ message: JLMessage, isOutgoingMessage: Bool) {
        super.initCell(message, isOutgoingMessage: isOutgoingMessage)
        
        //If it is being reused do not configure these things again
        if cellAlreadyUsed == false{
            self.errorButton.setImage(JLChatAppearence.normalStateErrorButtonImage, for: UIControlState())
            self.errorButton.setImage(JLChatAppearence.selectedStateErrorButtonImage, for: UIControlState.selected)
            
            if isOutgoingMessage{
                configAsOutgoingMessage()
            }
            else{
                configAsIncomingMessage()
            }
            
            cellAlreadyUsed = true
            
        }
        
        senderImageView.image = message.senderImage
        
        if let image = (message as! JLImageMessage).relatedImage{
            //put it on bubble form and add
            if !self.cellAlreadyUsed || usedImageIdentifier != image.hashValue{
                usedImageIdentifier = image.hashValue
                self.addImage(image)
            }
        }
        else{
            self.achiveLoadingMode()
        }
        
        if message.messageStatus == MessageSendStatus.errorToSend{
            self.showErrorButton(false)
        }

        
    }
    
    
    
    open override func initCell(_ message: JLMessage, thisIsNewMessage: Bool, isOutgoingMessage: Bool) {
        
        super.initCell(message, thisIsNewMessage: thisIsNewMessage, isOutgoingMessage: isOutgoingMessage)
        
        //If it is being reused do not configure these things again
        if cellAlreadyUsed == false{
            
            
            
            self.errorButton.setImage(JLChatAppearence.normalStateErrorButtonImage, for: UIControlState())
            self.errorButton.setImage(JLChatAppearence.selectedStateErrorButtonImage, for: UIControlState.selected)
            
            if isOutgoingMessage{
                configAsOutgoingMessage()
            }
            else{
                configAsIncomingMessage()
            }
            
            cellAlreadyUsed = true
            
        }
        
        
        senderImageView.image = message.senderImage
        
        if let image = (message as! JLImageMessage).relatedImage{
            //put it on bubble form and add
            if !self.cellAlreadyUsed || usedImageIdentifier != image.hashValue{
                usedImageIdentifier = image.hashValue
                self.addImage(image)
            }
        }
        else{
            self.achiveLoadingMode()
        }
        
        
        
        
        if message.messageStatus == MessageSendStatus.errorToSend{
            self.showErrorButton(false)
        }

    }
    
 
    /**
     Use this method to add the image into 'messageImageView'
     - parameter image: The image that came with the image
    */
    open func addImage(_ image:UIImage){
        
        
        let mask = self.isOutgoingMessage ? JLChatAppearence.outgoingBubbleImageMask : JLChatAppearence.incomingBubbleImageMask
        
        self.messageImageView.addImage(image, ApplyingMask: mask)
        
        self.messageImageView.loadActivity.stopAnimating()
        
    }
    /**
     If the related image is not loaded and you are downloading it you can call this method for the user see that its been loaded, but by default if the 'JLMessage' parameter of method 'initCell' have its image  equal to nil this method is called.
    */
    open func achiveLoadingMode(){
        self.messageImageView.image = isOutgoingMessage ? JLChatAppearence.outgoingBubbleLoadingImage : JLChatAppearence.incomingBubbleLoadingImage
        
        
        //self.messageImageView.tintColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        
        self.messageImageView.loadActivity.startAnimating()
    }
    
    
    override open func updateMessageStatus(_ message:JLMessage){
        
        super.updateMessageStatus(message)
        
        if message.messageStatus == MessageSendStatus.errorToSend{
            self.showErrorButton(true)
            
        }
        else{
            self.hideErrorButton(true)
        }
        
    }
    
    //MARK: - Alert error button methods
    
    override open func showErrorButton(_ animated:Bool){
        
        super.showErrorButton(animated)
        
        self.errorButtonDist.constant = 5
        
        if animated{
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.layoutIfNeeded()
            }) 
            UIView.animate(withDuration: 0.5, delay: 0.3, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.errorButton.alpha = 1
                
                }, completion: nil)
        }
        else{
            self.errorButton.alpha = 1
            self.layoutIfNeeded()
        }
        
       

        
    }
    
    override open func hideErrorButton(_ animated:Bool){
        
        super.hideErrorButton(animated)
        
        self.errorButtonDist.constant = -35
        
        self.errorButton.alpha = 0
        if animated{
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.layoutIfNeeded()
            }) 
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.errorButton.alpha = 0
                
                }, completion: nil)

        }
        else{
            self.errorButton.alpha = 0
            self.layoutIfNeeded()
        }
        
        
    }

    
    //MARK: - Menu methods
    @IBAction func errorButtonAction(_ sender: AnyObject) {
        self.showMenu()
    }
       
    override open func configMenu(_ deleteTitle:String?,sendTitle:String?,deleteBlock:@escaping()->(),sendBlock:@escaping()->()){
        
        
        if !isMenuConfigured{
            
            addLongPress()
        
        }
        
        super.configMenu(deleteTitle, sendTitle: sendTitle, deleteBlock: deleteBlock, sendBlock: sendBlock)

    }
    
    
    fileprivate func addLongPress(){
        
        let longPress = UILongPressGestureRecognizer(target: self, action:#selector(JLImageMessageCell.longPressAction(_:)))
        
        self.messageImageView.addGestureRecognizer(longPress)
        
    }
    
    
    func longPressAction(_ longPress:UILongPressGestureRecognizer){
        
        if longPress.state == UIGestureRecognizerState.began{
            
            self.messageImageView.alpha = 0.5
            
        }
        else if longPress.state == UIGestureRecognizerState.ended{
            
            self.showMenu()
            
        }
        else if longPress.state == UIGestureRecognizerState.cancelled || longPress.state == UIGestureRecognizerState.failed{
            self.messageImageView.alpha = 1
        }
        
    }
    
    fileprivate func showMenu(){
        self.becomeFirstResponder()
        
        self.messageImageView.alpha = 1
        
        let targetRectangle = self.messageImageView.frame
        
        UIMenuController.shared.setTargetRect(targetRectangle, in: self)
        
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }
    
   
    //MARK: - Config methods
    
    open override func configAsIncomingMessage(){
        if JLChatAppearence.showIncomingSenderImage{
            self.senderImageView.backgroundColor = JLChatAppearence.senderImageBackgroundColor
            
            self.senderImageView.image = JLChatAppearence.senderImageDefaultImage
            
            self.senderImageViewheight.constant = JLChatAppearence.senderImageSize.height
            
            self.senderImageViewWidth.constant = JLChatAppearence.senderImageSize.width
            
            self.senderImageView.layer.cornerRadius = JLChatAppearence.senderImageCornerRadius
            
            senderImageBottomToBubbleBottom.constant = JLChatAppearence.vertivalDistBetweenImgBottom_And_BubbleBottom
            senderImageToBubble.constant = JLChatAppearence.horizontalDistBetweenImg_And_Bubble
            
        }
        else{
            //self.senderImageViewWidth.constant = 0
            
            //self.senderImageViewWidth.constant = 0
            senderImageToBubble.constant = 5
            imageDistToSide.constant = -30
        }

    }
    
    open override func configAsOutgoingMessage(){
        if JLChatAppearence.showOutgoingSenderImage{
            self.senderImageView.backgroundColor = JLChatAppearence.senderImageBackgroundColor
            
            self.senderImageView.image = JLChatAppearence.senderImageDefaultImage
            
            self.senderImageViewheight.constant = JLChatAppearence.senderImageSize.height
            
            self.senderImageViewWidth.constant = JLChatAppearence.senderImageSize.width
            
            self.senderImageView.layer.cornerRadius = JLChatAppearence.senderImageCornerRadius
            
            senderImageBottomToBubbleBottom.constant = JLChatAppearence.vertivalDistBetweenImgBottom_And_BubbleBottom
            senderImageToBubble.constant = JLChatAppearence.horizontalDistBetweenImg_And_Bubble
            
        }
        else{
            //self.senderImageViewWidth.constant = 0
            
            //self.senderImageViewWidth.constant = 0
            senderImageToBubble.constant = 5
            imageDistToSide.constant = -30
        }

    }

    
}
