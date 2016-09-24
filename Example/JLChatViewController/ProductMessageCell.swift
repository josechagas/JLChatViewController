//
//  ProductMessageCell.swift
//  JLChatViewController
//
//  Created by José Lucas Souza das Chagas on 12/12/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import JLChatViewController



class ProductMessageCell: JLChatMessageCell {
    
    
    @IBOutlet weak var delimiterView: UIView!

    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var senderImageView: UIImageView!
    
    @IBOutlet weak var errorToSendButton: UIButton!
    
    
    // --- ---- ----- constraints
    
    
    @IBOutlet weak var errorToSendLeadingDist: NSLayoutConstraint!
    
    
    
    //senderImage contraints
    
    @IBOutlet weak var senderImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var senderImageWidth: NSLayoutConstraint!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //self.senderImageView.image = nil
        self.productImageView.image = nil
        self.nameLabel.text = nil
    }
    
    
    override func initCell(_ message: JLMessage, isOutgoingMessage: Bool) {
        super.initCell(message, isOutgoingMessage: isOutgoingMessage)
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        configView()
        
        //If the cell is being reused do not config these things again
        if cellAlreadyUsed == false{
            
            self.nameLabel.font = JLChatAppearence.chatFont
            
            self.errorToSendButton.setImage(JLChatAppearence.normalStateErrorButtonImage, for: UIControlState())
            self.errorToSendButton.setImage(JLChatAppearence.selectedStateErrorButtonImage, for: UIControlState.selected)
            
            if isOutgoingMessage{
                
                configAsOutgoingMessage()
            }
            else{
                
                configAsIncomingMessage()
            }
            cellAlreadyUsed = true
            
        }
        
        //let productMessage = message as! ProductMessage
        self.nameLabel.text = (message as! ProductMessage).text
        self.productImageView.image = (message as! ProductMessage).relatedImage
        
        if let img = message.senderImage{
            self.senderImageView.image = img
        }
        
        if message.messageStatus == MessageSendStatus.errorToSend{
            showErrorButton(false)
        }

    }
    
   
    override func initCell(_ message: JLMessage, thisIsNewMessage: Bool, isOutgoingMessage: Bool) {
        super.initCell(message, thisIsNewMessage: thisIsNewMessage, isOutgoingMessage: isOutgoingMessage)
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        configView()
        
        
        //If the cell is being reused do not config these things again
        if cellAlreadyUsed == false{
            
            self.nameLabel.font = JLChatAppearence.chatFont
            
            self.errorToSendButton.setImage(JLChatAppearence.normalStateErrorButtonImage, for: UIControlState())
            self.errorToSendButton.setImage(JLChatAppearence.selectedStateErrorButtonImage, for: UIControlState.selected)
            
            if isOutgoingMessage{
                
                configAsOutgoingMessage()
            }
            else{
                
                configAsIncomingMessage()
            }
            cellAlreadyUsed = true
            
        }
        
        
        //let productMessage = message as! ProductMessage
        self.nameLabel.text = (message as! ProductMessage).text
        self.productImageView.image = (message as! ProductMessage).relatedImage
        
        if let img = message.senderImage{
            self.senderImageView.image = img
        }
        
        if message.messageStatus == MessageSendStatus.errorToSend{
            showErrorButton(false)
        }

    }
    
    
    fileprivate func  configView(){
        delimiterView.layer.masksToBounds = true
        delimiterView.layer.cornerRadius = self.frame.height/4
        delimiterView.layer.borderWidth = 2
        delimiterView.layer.borderColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1).cgColor
        
    }
    
    
    
    override func updateMessageStatus(_ message:JLMessage){
        super.updateMessageStatus(message)
        if message.messageStatus == MessageSendStatus.errorToSend{
            self.showErrorButton(true)
        }
        else{
            self.hideErrorButton(true)
        }
        
        
    }
    
    //MARK: - Alert error button methods
    
    override func showErrorButton(_ animated:Bool){
        
        super.showErrorButton(animated)
        
        self.errorToSendLeadingDist.constant = 5
        
        if animated{
            
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.layoutIfNeeded()
            }) 
            
            UIView.animate(withDuration: 0.5, delay: 0.3, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.errorToSendButton.alpha = 1
                
                }, completion: nil)
        }
        else{
            self.errorToSendButton.alpha = 1
            self.layoutIfNeeded()
        }
        
        
    }
    
    override internal func hideErrorButton(_ animated:Bool){
        
        super.hideErrorButton(animated)
        
        self.errorToSendLeadingDist.constant = -35
        
        if animated{
            
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.layoutIfNeeded()
            }) 
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.errorToSendButton.alpha = 0
                
                }, completion: nil)
            
            
        }
        else{
            self.errorToSendButton.alpha = 0
            self.layoutIfNeeded()
        }
        
        
    }
    
    
    //MARK: - Menu methods
    @IBAction func errorButtonAction(_ sender: AnyObject) {
        
        showMenu()
    }
    
    override func configMenu(_ deleteTitle:String?,sendTitle:String?,deleteBlock:@escaping()->(),sendBlock:@escaping()->()){
        
        if !isMenuConfigured{
            addLongPress()
            
        }
        
        super.configMenu(deleteTitle, sendTitle: sendTitle, deleteBlock: deleteBlock, sendBlock: sendBlock)
        
    }
    

    fileprivate func addLongPress(){
        
        let longPress = UILongPressGestureRecognizer(target: self, action:#selector(ProductMessageCell.longPressAction(_:)))
        
        self.delimiterView.addGestureRecognizer(longPress)
        
        
    }
    
    
    func longPressAction(_ longPress:UILongPressGestureRecognizer){
        
        if longPress.state == UIGestureRecognizerState.began{
            
            self.delimiterView.alpha = 0.5
            
        }   
        else if longPress.state == UIGestureRecognizerState.ended{
            
            self.showMenu()
            
        }
        else if longPress.state == UIGestureRecognizerState.cancelled || longPress.state == UIGestureRecognizerState.failed{
            self.delimiterView.alpha = 1
        }
        
    }
    
    
    func showMenu(){
        
        self.becomeFirstResponder()
        
        self.delimiterView.alpha = 1
        
        let targetRectangle = self.delimiterView.frame
        
        UIMenuController.shared.setTargetRect(targetRectangle, in: self)
        
        UIMenuController.shared.setMenuVisible(true, animated: true)
        
    }
    
    
    
    //MARK: - Config methods
    internal override func configAsOutgoingMessage(){
        
        super.configAsOutgoingMessage()
        
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
        self.nameLabel.font = JLChatAppearence.chatFont
        
        self.nameLabel.textColor = JLChatAppearence.outGoingTextColor
        
        self.delimiterView.backgroundColor = JLChatAppearence.outgoingBubbleColor
        
    }
    
    override internal func configAsIncomingMessage(){
        
        super.configAsIncomingMessage()
        
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
        
        self.nameLabel.font = JLChatAppearence.chatFont
        
        self.nameLabel.textColor = JLChatAppearence.incomingTextColor
        
        self.delimiterView.backgroundColor = JLChatAppearence.incomingBubbleColor

        
    }

}
