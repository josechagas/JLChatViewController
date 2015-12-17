//
//  JLChatMessageCell.swift
//  Pods
//
//  Created by José Lucas Souza das Chagas on 10/12/15.
//
//

import UIKit

public class JLChatMessageCell: UITableViewCell {
    
    
    public var cellAlreadyUsed:Bool = false


    public private(set) var isMenuConfigured:Bool = false
    
    
    private var sendBlock:(()->())!
    private var deleteBlock:(()->())!
    
    internal var sendMenuEnabled:()->Bool = { () -> Bool in
        
        return true
    }

    
    internal var deleteMenuEnabled:()->Bool = { () -> Bool in
        
        return true
    }

  
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        
        if (action == "deleteAction:" && deleteMenuEnabled()) || (action == "sendAction:" && sendMenuEnabled()){
            return true
        }
        
        return false
    }

    
    
    public override func becomeFirstResponder() -> Bool {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuDismissed:", name: UIMenuControllerDidHideMenuNotification, object: nil)
        
        return super.becomeFirstResponder()
        
    }
    
    
    public override func resignFirstResponder() -> Bool {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIMenuControllerDidHideMenuNotification, object: nil)
        
        return super.resignFirstResponder()
    }
    
    
    
    
    public func initCell(message:JLMessage,thisIsNewMessage:Bool,showDate:Bool,isOutgoingMessage:Bool){
       
        
        
    }

    
    //MARK: Status methods
    
    public func updateMessageStatus(message:JLMessage){
        
    }
    
    public func showErrorButton(animated:Bool){
        
    }
    
    public func hideErrorButton(animated:Bool){
       
    }
    
    //MARK: MenuController methods
    
    func menuDismissed(notification:NSNotification){
        
        self.resignFirstResponder()
        
    }
    

    public func configMenu(deleteTitle:String?,sendTitle:String?,deleteBlock:()->(),sendBlock:()->()){
        
        var menus:[UIMenuItem] = [UIMenuItem]()
        
        isMenuConfigured = true
        
        if let deleteTitle = deleteTitle{
            menus.append(UIMenuItem(title: deleteTitle, action: "deleteAction:"))
        }
        else{
            menus.append(UIMenuItem(title: "Delete", action: "deleteAction:"))
        }
        
        if let sendTitle = sendTitle{
            menus.append(UIMenuItem(title: sendTitle, action: "sendAction:"))
        }
        else{
            menus.append(UIMenuItem(title: "Try Again", action: "sendAction:"))
        }
        
        UIMenuController.sharedMenuController().menuItems = menus
        
        UIMenuController.sharedMenuController().update()
        
        self.deleteBlock = deleteBlock
        self.sendBlock = sendBlock

    }
    
    public func deleteAction(sender:AnyObject){
        
        print("delete")
        deleteBlock()
        
    }
    
    public func sendAction(sender:AnyObject){
        
        print("send")
        sendBlock()
        
    }
    
    //MARK: Config methods

    
    public func configAsOutgoingMessage(){
        
        
        
    }
    
    public func configAsIncomingMessage(){
        
    }

}
