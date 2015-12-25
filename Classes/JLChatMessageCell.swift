//
//  JLChatMessageCell.swift
//  Pods
//
//  Created by José Lucas Souza das Chagas on 10/12/15.
//
//

import UIKit

public class JLChatMessageCell: UITableViewCell {
    
    /**
     This variable indicates if this cell is being reused.
     
     
     If value is true so you don't have to configure it again as outgoing or incoming message.
     
     If value is false so you have to configure it again as outgoing or incoming message.

    */
    public var cellAlreadyUsed:Bool = false


    public private(set) var isMenuConfigured:Bool = false
    
    internal var isOutgoingMessage:Bool = false
    
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
        
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: UIMenuControllerDidHideMenuNotification, object: nil)
        
        return super.resignFirstResponder()
    }
    
    
    
    /**
     The implementation of this method have to contain every code that is necessary to initialize the message cell.
     
     You must override this method.

    */
    public func initCell(message:JLMessage,thisIsNewMessage:Bool,showDate:Bool,isOutgoingMessage:Bool){
       
        self.isOutgoingMessage = isOutgoingMessage
        
    }

    
    //MARK: Status methods
    /**
    The implementation of this method have to contain every code that is necessary to update the message cell status accordingly to the message related to this cell.
    
    
    You must override this method.

    
    - parameter message: The 'JLMessage' instance related to its cell with its 'messageStatus' updated.
    */
    public func updateMessageStatus(message:JLMessage){
        
    }
    /**
     
     Present the 'errorButton'.
     
     You must override this method.
     */
    public func showErrorButton(animated:Bool){
        
    }
    /**
     Hide the 'errorButton'.
     
     You must override this method.
     */
    public func hideErrorButton(animated:Bool){
       
    }
    
    //MARK: MenuController methods
    
    func menuDismissed(notification:NSNotification){
        
        self.resignFirstResponder()
        
    }
    
    /**
     Use this method to configure the menu items of this cell 'UIMenuController'
     - parameter deleteTitle: the title of the menu item that indicates the delete action.
     - parameter senTitle: the title of menu item that indicates the try to send again action.
     - parameter deleteBlock: action that is executed when delete menu item is clicked.
     - parameter sendBlock: action that is executed when send menu item is clicked.

     */
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
    /**
    The implementation of this method have to contain every code that is necessary to configure the message cell as a outgoing message.
    
    You must override this method.
    */
    public func configAsOutgoingMessage(){
        
        
        
    }
    /**
     The implementation of this method have to contain every code that is necessary to configure the message cell as a incoming message.
     
     You must override this method.

     */
    public func configAsIncomingMessage(){
        
    }

}
