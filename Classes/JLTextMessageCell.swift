//
//  JLTextMessageCell.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 29/11/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit


//https://www.captechconsulting.com/blogs/performance-tuning-on-older-ios-devices

//https://yalantis.com/blog/mastering-uikit-performance/


public class JLTextMessageCell: JLChatMessageCell {
    
    
    @IBOutlet public weak var chatTextView: JLChatTextView!
    
    @IBOutlet public weak var senderImageView: UIImageView!
    
    @IBOutlet weak var errorToSendButton: UIButton!
    

    @IBOutlet public weak var chatMessageLabel: JLChatLabel!
    // --- ---- ----- constraints
    
    
    @IBOutlet weak var errorToSendLeadingDist: NSLayoutConstraint!
    
    
    
    //senderImage contraints - start
    /**
     This is a constraint of 'senderImageView' do not change its value manually.
     
     Changes on it are made by 'JLChatAppearance'
     */

    @IBOutlet weak var senderImageHeight: NSLayoutConstraint!
    /**
     This is a constraint of 'senderImageView' do not change its value manually.
     
     Changes on it are made by 'JLChatAppearance'
     */
    @IBOutlet weak var senderImageWidth: NSLayoutConstraint!
        
    @IBOutlet weak var imageDistToSide: NSLayoutConstraint!
    //senderImage contraints - end
    
    //for know its being used because its seems that some last bug is resolved using a better way
    @IBOutlet weak var bubbleMinWidth: NSLayoutConstraint!
    @IBOutlet weak var bubbleMinHeight: NSLayoutConstraint!
    
    /**
     This a constraint used for aligment between sender`s image and bubble
     */
    @IBOutlet weak var senderImageBottomToBubbleBottom: NSLayoutConstraint!
    /**
     This a constraint used for aligment between sender`s image and bubble
     */
    @IBOutlet weak var senderImageToBubble: NSLayoutConstraint!
    

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
    }
    

    override public func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        // Initialization code
    }
    
    override public func prepareForReuse() {
        //senderImageView.image = nil
        hideErrorButton(false)

    }
    
    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    public override func initCell(message: JLMessage, thisIsNewMessage: Bool, isOutgoingMessage: Bool) {
        super.initCell(message, thisIsNewMessage: thisIsNewMessage, isOutgoingMessage: isOutgoingMessage)
        
        //If it is being reused do not configure these things again
        if cellAlreadyUsed == false{
            
            //self.transform = CGAffineTransformMakeScale(1, -1)//CGAffineTransformInvert(self.transform)
            
            self.chatMessageLabel.font = JLChatAppearence.chatFont
            
            self.errorToSendButton.setImage(JLChatAppearence.normalStateErrorButtonImage, forState: UIControlState.Normal)
            self.errorToSendButton.setImage(JLChatAppearence.selectedStateErrorButtonImage, forState: UIControlState.Selected)
            
            
            if isOutgoingMessage{
               //bubbleMinWidth.constant = JLChatAppearence.outgoingBubbleImage!.size.width
                //bubbleMinHeight.constant = JLChatAppearence.outgoingBubbleImage!.size.height
                
                configAsOutgoingMessage()
            }
            else{
                //bubbleMinWidth.constant = JLChatAppearence.incomingBubbleImage!.size.width
                //bubbleMinHeight.constant = JLChatAppearence.incomingBubbleImage!.size.height
                
                configAsIncomingMessage()
            }
            
            cellAlreadyUsed = true
            
        }
        
        
        
        self.chatMessageLabel.text = (message as! JLTextMessage).text
        //self.chatMessageLabel.settAttributedText(message.text)

        senderImageView.image = message.senderImage
        
        if message.messageStatus == MessageSendStatus.ErrorToSend{
            showErrorButton(false)
        }

    }
    
      
    
    override public func updateMessageStatus(message:JLMessage){
        
        super.updateMessageStatus(message)
        
        if message.messageStatus == MessageSendStatus.ErrorToSend{
            self.showErrorButton(true)
        }
        else{
            self.hideErrorButton(true)
        }
        
        
    }
    
    //MARK: - Alert error button methods
    
    override public func showErrorButton(animated:Bool){
        
        super.showErrorButton(animated)
        
        self.errorToSendLeadingDist.constant = 5
        
        if animated{
            
            UIView.animateWithDuration(0.4) { () -> Void in
                self.layoutIfNeeded()
            }
            
            UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.errorToSendButton.alpha = 1
                
                }, completion: nil)
            
        }
        else{
            self.errorToSendButton.alpha = 1
            self.layoutIfNeeded()
        }
       
       
    }
    
     override public func hideErrorButton(animated:Bool){
        
        super.hideErrorButton(animated)
        
        self.errorToSendLeadingDist.constant = -35
        
        if animated{
            
            UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.errorToSendButton.alpha = 0
                
                }, completion: nil)
            
            UIView.animateWithDuration(0.4, delay: 0.4, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.layoutIfNeeded()
                
                }, completion: nil)


        }
        else{
            self.errorToSendButton.alpha = 0
            self.layoutIfNeeded()
        }

        
    }
    
    
    //MARK: - Menu methods
    @IBAction func errorButtonAction(sender: AnyObject) {
        
        showMenu()
    }
    
    override public func configMenu(deleteTitle:String?,sendTitle:String?,deleteBlock:()->(),sendBlock:()->()){
        
        if !isMenuConfigured{
            addLongPress()
        }
        
        super.configMenu(deleteTitle, sendTitle: sendTitle, deleteBlock: deleteBlock, sendBlock: sendBlock)

        
        

    }
    
    private func addLongPress(){
        
        let longPress = UILongPressGestureRecognizer(target: self, action:#selector(JLTextMessageCell.longPressAction(_:)))
            
        self.chatMessageLabel.addGestureRecognizer(longPress)
    }
    
    
    func longPressAction(longPress:UILongPressGestureRecognizer){
        
        if longPress.state == UIGestureRecognizerState.Began{
            
            self.chatMessageLabel.alpha = 0.5
        }
        else if longPress.state == UIGestureRecognizerState.Ended{
            
            self.showMenu()
            
        }
        else if longPress.state == UIGestureRecognizerState.Cancelled || longPress.state == UIGestureRecognizerState.Failed{
            self.chatMessageLabel.alpha = 1
        }
        
    }
    
    
    func showMenu(){
        self.becomeFirstResponder()
        
        self.chatMessageLabel.alpha = 1
        
        let targetRectangle = self.chatMessageLabel.frame
        
        UIMenuController.sharedMenuController().setTargetRect(targetRectangle, inView: self)
                
        UIMenuController.sharedMenuController().setMenuVisible(true, animated: true)
        

    }
    
    
    
    //MARK: - Config methods
    public override func configAsOutgoingMessage(){
        if JLChatAppearence.showOutgoingSenderImage{
            self.senderImageView.backgroundColor = JLChatAppearence.senderImageBackgroundColor
            
            self.senderImageView.image = JLChatAppearence.senderImageDefaultImage
            
            self.senderImageHeight.constant = JLChatAppearence.senderImageSize.height
            
            self.senderImageWidth.constant = JLChatAppearence.senderImageSize.width
            
            self.senderImageView.layer.cornerRadius = JLChatAppearence.senderImageCornerRadius
            
            
            //config the changes only if needs to show the sender image
            senderImageBottomToBubbleBottom.constant = JLChatAppearence.vertivalDistBetweenImgBottom_And_BubbleBottom
            senderImageToBubble.constant = JLChatAppearence.horizontalDistBetweenImg_And_Bubble
            
        }
        else{
            senderImageToBubble.constant = 5
            imageDistToSide.constant = -30
            
            //self.senderImageHeight.constant = 0
            
            //self.senderImageWidth.constant = 0
        }
        
        self.chatMessageLabel.textColor = JLChatAppearence.outGoingTextColor
    }
    
    public override func configAsIncomingMessage(){
        if JLChatAppearence.showIncomingSenderImage{
            
            self.senderImageView.backgroundColor = JLChatAppearence.senderImageBackgroundColor
            
            self.senderImageView.image = JLChatAppearence.senderImageDefaultImage
            
            self.senderImageHeight.constant = JLChatAppearence.senderImageSize.height
            
            self.senderImageWidth.constant = JLChatAppearence.senderImageSize.width
            
            self.senderImageView.layer.cornerRadius = JLChatAppearence.senderImageCornerRadius
            
            //config the changes only if needs to show the sender image

            senderImageBottomToBubbleBottom.constant = JLChatAppearence.vertivalDistBetweenImgBottom_And_BubbleBottom
            senderImageToBubble.constant = JLChatAppearence.horizontalDistBetweenImg_And_Bubble

        }
        else{
            //self.senderImageHeight.constant = 0
            
            //self.senderImageWidth.constant = 0
            senderImageToBubble.constant = 5
            imageDistToSide.constant = -30
        }
        
        
        self.chatMessageLabel.textColor = JLChatAppearence.incomingTextColor

    }
       
    
}
