//
//  JLImageMessageCell.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 02/12/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit
//346

public class JLImageMessageCell: JLChatMessageCell {

    @IBOutlet public weak var messageImageView: JLChatImageView!
    
    @IBOutlet public weak var senderImageView: UIImageView!
    
    @IBOutlet public weak var messageDateLabel: UILabel!
    
    
    @IBOutlet weak var errorButton: UIButton!
    
    @IBOutlet weak var errorButtonDist: NSLayoutConstraint!
    
    
    // sender image constraints
    
    @IBOutlet weak var senderImageViewheight: NSLayoutConstraint!
    
    
    @IBOutlet weak var senderImageViewWidth: NSLayoutConstraint!
    
    
    
    
    //private var cellAlreadyUsed:Bool = false

    //private(set) var isMenuConfigured:Bool = false

    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override public func prepareForReuse() {
        messageImageView.image = nil
        senderImageView.image = nil
        messageDateLabel.text = nil
        self.hideErrorButton(false)

    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
      
    
    override public func initCell(message:JLMessage,thisIsNewMessage:Bool,showDate:Bool,isOutgoingMessage:Bool){
        
        super.initCell(message, thisIsNewMessage: thisIsNewMessage, showDate: showDate, isOutgoingMessage: isOutgoingMessage)
        
        senderImageView.image = message.senderImage
        
        self.messageImageView.image = message.relatedImage

        if message.messageStatus == MessageSendStatus.ErrorToSend{
            self.showErrorButton(false)
        }
               
        if showDate{
            self.messageDateLabel.text = message.generateStringFromDate()
        }
        else{
            messageDateLabel.text = nil
        }
        
        if cellAlreadyUsed == false{
            if isOutgoingMessage{
                configAsOutgoingMessage()
            }
            else{
                configAsIncomingMessage()
            }
            cellAlreadyUsed = true

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
        
        self.errorButtonDist.constant = 5
        
        if animated{
            UIView.animateWithDuration(0.4) { () -> Void in
                self.layoutIfNeeded()
            }
            UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.errorButton.alpha = 1
                
                }, completion: nil)
        }
        else{
            self.errorButton.alpha = 1
            self.layoutIfNeeded()
        }
        
       

        
    }
    
    override public func hideErrorButton(animated:Bool){
        
        super.hideErrorButton(animated)
        
        self.errorButtonDist.constant = -35
        
        self.errorButton.alpha = 0
        if animated{
            UIView.animateWithDuration(0.4) { () -> Void in
                self.layoutIfNeeded()
            }
            UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.errorButton.alpha = 0
                
                }, completion: nil)

        }
        else{
            self.errorButton.alpha = 0
            self.layoutIfNeeded()
        }
        
        
    }

    
    //MARK: - Menu methods
    @IBAction func errorButtonAction(sender: AnyObject) {
        self.showMenu()
    }
       
    override public func configMenu(deleteTitle:String?,sendTitle:String?,deleteBlock:()->(),sendBlock:()->()){
        
        
        if !isMenuConfigured{
            
            addLongPress()
        
        }
        
        super.configMenu(deleteTitle, sendTitle: sendTitle, deleteBlock: deleteBlock, sendBlock: sendBlock)

    }
    
    
    private func addLongPress(){
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "longPressAction:")
        
        self.messageImageView.addGestureRecognizer(longPress)
        
    }
    
    
    func longPressAction(longPress:UILongPressGestureRecognizer){
        
        if longPress.state == UIGestureRecognizerState.Began{
            
            self.messageImageView.alpha = 0.5
            
        }
        else if longPress.state == UIGestureRecognizerState.Ended{
            
            self.showMenu()
            
        }
        else if longPress.state == UIGestureRecognizerState.Cancelled || longPress.state == UIGestureRecognizerState.Failed{
            self.messageImageView.alpha = 1
        }
        
    }
    
    func showMenu(){
        self.becomeFirstResponder()
        
        self.messageImageView.alpha = 1
        
        let targetRectangle = self.messageImageView.frame
        
        UIMenuController.sharedMenuController().setTargetRect(targetRectangle, inView: self)
        
        UIMenuController.sharedMenuController().setMenuVisible(true, animated: true)
    }
    
   
    //MARK: - Config methods
    
    public override func configAsIncomingMessage(){
        if JLChatAppearence.showIncomingSenderImage{
            self.senderImageView.backgroundColor = JLChatAppearence.senderImageBackgroundColor
            
            self.senderImageViewheight.constant = JLChatAppearence.senderImageSize.height
            
            self.senderImageViewWidth.constant = JLChatAppearence.senderImageSize.width
            
            self.senderImageView.layer.cornerRadius = JLChatAppearence.senderImageCornerRadius
            
        }
        else{
            self.senderImageViewWidth.constant = 0
            
            self.senderImageViewWidth.constant = 0
        }

    }
    
    public override func configAsOutgoingMessage(){
        if JLChatAppearence.showOutgoingSenderImage{
            self.senderImageView.backgroundColor = JLChatAppearence.senderImageBackgroundColor
            
            self.senderImageViewheight.constant = JLChatAppearence.senderImageSize.height
            
            self.senderImageViewWidth.constant = JLChatAppearence.senderImageSize.width
            
            self.senderImageView.layer.cornerRadius = JLChatAppearence.senderImageCornerRadius
            
        }
        else{
            self.senderImageViewWidth.constant = 0
            
            self.senderImageViewWidth.constant = 0
        }

    }

    
}
