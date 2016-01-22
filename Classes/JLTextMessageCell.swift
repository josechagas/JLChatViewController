//
//  JLTextMessageCell.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 29/11/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit





public class JLTextMessageCell: JLChatMessageCell {
    
    
    @IBOutlet public weak var messageDateLabel: UILabel!
    
    @IBOutlet public weak var chatTextView: JLChatTextView!
    
    @IBOutlet public weak var senderImageView: UIImageView!
    
    @IBOutlet weak var errorToSendButton: UIButton!
    

    // --- ---- ----- constraints
    
    
    @IBOutlet weak var errorToSendLeadingDist: NSLayoutConstraint!
    
    
    
    //senderImage contraints
    
    @IBOutlet weak var senderImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var senderImageWidth: NSLayoutConstraint!
    
    
    
    //some properties
    
       
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override public func prepareForReuse() {
        chatTextView.text = ""
        senderImageView.image = nil
        messageDateLabel.text = nil
        hideErrorButton(false)

    }
    
    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override public func initCell(message:JLMessage,thisIsNewMessage:Bool,showDate:Bool,isOutgoingMessage:Bool){
    
        self.chatTextView.text = message.text
        
        senderImageView.image = message.senderImage
        
        if message.messageStatus == MessageSendStatus.ErrorToSend{
            showErrorButton(false)
        }
        
        
        
        if showDate{
            self.messageDateLabel.text = message.generateStringFromDate()//"terca - 12/12/2015"
        }
        else{
            messageDateLabel.text = nil
        }
        
        //se a celula estiver sendo reutilizada nao configura essas coisas novamente
        if cellAlreadyUsed == false{
            
            //self.transform = CGAffineTransformMakeScale(1, -1)//CGAffineTransformInvert(self.transform)
            
            self.chatTextView.font = JLChatAppearence.chatFont
            
            if isOutgoingMessage{
                
                self.chatTextView.createBallonForOugoingMessage(true)
                
                configAsOutgoingMessage()
            }
            else{
                
                self.chatTextView.createBallonForOugoingMessage(false)
                
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
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "longPressAction:")
            
        self.chatTextView.addGestureRecognizer(longPress)
    
    }
    
    
    func longPressAction(longPress:UILongPressGestureRecognizer){
        
        if longPress.state == UIGestureRecognizerState.Began{
            
            self.chatTextView.alpha = 0.5
            
        }
        else if longPress.state == UIGestureRecognizerState.Ended{
            
            self.showMenu()
            
        }
        else if longPress.state == UIGestureRecognizerState.Cancelled || longPress.state == UIGestureRecognizerState.Failed{
            self.chatTextView.alpha = 1
        }
        
    }
    
    
    func showMenu(){
        self.becomeFirstResponder()
        
        self.chatTextView.alpha = 1
        
        let targetRectangle = self.chatTextView.frame
        
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
            
        }
        else{
            self.senderImageHeight.constant = 0
            
            self.senderImageWidth.constant = 0
        }
        
        self.chatTextView.textColor = JLChatAppearence.outGoingTextColor

    }
    
    public override func configAsIncomingMessage(){
        if JLChatAppearence.showIncomingSenderImage{
            self.senderImageView.backgroundColor = JLChatAppearence.senderImageBackgroundColor
            
            self.senderImageView.image = JLChatAppearence.senderImageDefaultImage
            
            self.senderImageHeight.constant = JLChatAppearence.senderImageSize.height
            
            self.senderImageWidth.constant = JLChatAppearence.senderImageSize.width
            
            self.senderImageView.layer.cornerRadius = JLChatAppearence.senderImageCornerRadius
            
        }
        else{
            self.senderImageHeight.constant = 0
            
            self.senderImageWidth.constant = 0
        }
        
        
        self.chatTextView.textColor = JLChatAppearence.incomingTextColor

    }
    
    
    
}
