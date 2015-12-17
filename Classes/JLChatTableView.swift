//
//  JLChatTableView.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 29/11/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit


public protocol JLChatMessagesMenuDelegate{
    
    func shouldShowMenuItemForCellAtIndexPath(title:String,indexPath:NSIndexPath)->Bool
    
    func titleForDeleteMenuItem()->String?
    
    func titleForSendMenuItem()->String?
    
    func performDeleteActionForCellAtIndexPath(indexPath:NSIndexPath)
    
    func performSendActionForCellAtIndexPath(indexPath:NSIndexPath)
    
}


/**
This is a public protocol that inherits from UITableViewDataSource
*/
public protocol ChatDataSource:UITableViewDataSource{
    
    /**
    This method will be called always when there is a message with messageKind = MessageKind.Custom 
    */
    func chat(chat: JLChatTableView, customMessageCellForRowAtIndexPath indexPath: NSIndexPath) -> JLChatMessageCell
    
    
}


public protocol ChatDelegate{
    
    func loadOlderMessages()
    func didTapMessageAtIndexPath(indexPath:NSIndexPath)
    
}



public class JLChatTableView: UITableView,ToolBarFrameDelegate,UITableViewDelegate {

    
    private var cells:[Int:UITableViewCell]! =  [Int:UITableViewCell]()

    
    public var myID:String!
    public var messagesMenuDelegate:JLChatMessagesMenuDelegate?
    public var chatDelegate:ChatDelegate?
    public var chatDataSource:ChatDataSource?{
        didSet{
            self.dataSource = chatDataSource 
        }
    }
    
    
    private var addedNewMessage:Bool = true
    private var blockLoadOldMessages:Bool = false//avoid to do multiples requesitions for old messages
    
    
    
    private var quant:Int = 0//this the number of old messages that will be added
    private var isLoadingOldMessages:Bool = false
    private var loadedOldMessagesButNotShowing:Bool = false
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)

        self.initChatTableView()

    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initChatTableView()
    }
    
    
    public override func didChangeValueForKey(key: String) {
        
        
        if key == "contentSize"{
            
            if addedNewMessage{
                
                
                if self.numberOfSections == 0 || self.numberOfRowsInSection(0) == 0{
                    return
                }
                else{
                    let chatContentheight = self.contentSize.height
                    self.scrollRectToVisible(CGRect(x: 0, y: chatContentheight - 1, width: 1, height: 1), animated: false)
                }
              
            }
            
        }
    }
    
    
    
    private func addObserver(){
        
        self.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
        
    }

    
       
    private func initChatTableView(){
            
        self.rowHeight = UITableViewAutomaticDimension
        self.estimatedRowHeight = 50
        self.estimatedSectionHeaderHeight = 50
        self.delegate = self
        
        //self.transform = CGAffineTransformMakeScale(1, -1)//CGAffineTransformInvert(self.transform)
        
        self.registerNib(UINib(nibName: "JLChatLoadingView", bundle: JLBundleController.getBundle()), forHeaderFooterViewReuseIdentifier: "LoadingView")
        
        self.addObserver()
    }
    //Use it to add messages that you sent and that you received
    //Never use it to add old messages inside chat tableView
    public func addNewMessage(){
        
        addedNewMessage = true
        
        self.reloadData()
        
    }
    
    public func addOldMessages(quant:Int){
        
        self.quant = quant
        
        if self.contentOffset.y <= -10{
            
            blockLoadOldMessages = true
            
            self.reloadData()
            
            self.loadedOldMessagesButNotShowing = false
            
            self.scrollToRowAtIndexPath(NSIndexPath(forRow: quant, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
            
        }
        else{
            self.loadedOldMessagesButNotShowing = true
            
            if let header = self.headerViewForSection(0) as? JLChatLoadingView{
                header.activityIndicator.stopAnimating()
            }
            
        }
        
        isLoadingOldMessages = false
    }
    
    
    public func removeMessage(indexPath:NSIndexPath){
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            if let cell = self.cellForRowAtIndexPath(indexPath){
                cell.alpha = 0
            }
            
            }) { (finished) -> Void in
                self.reloadData()
                
        }

    }
    
    public func updateMessageStatusOfCellAtIndexPath(indexPath:NSIndexPath,message:JLMessage){
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            let cell = self.cellForRowAtIndexPath(indexPath) as! JLChatMessageCell
            cell.updateMessageStatus(message)
        }
    }
    
    //MARK: - Delegate
    
    //MARK: header

   
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if self.contentSize.height > self.bounds.height{
            let view = self.dequeueReusableHeaderFooterViewWithIdentifier("LoadingView") as! JLChatLoadingView
            view.activityIndicator.stopAnimating()
            return view
        }
        return nil
        
    }

    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if self.contentOffset.y <= 0 - (self.contentInset.top){
            
            if !blockLoadOldMessages && !isLoadingOldMessages{
                
                if loadedOldMessagesButNotShowing{
                    self.addOldMessages(quant)
                }
                else{
                    let header = self.headerViewForSection(0) as! JLChatLoadingView
                    
                    header.activityIndicator.startAnimating()
                    
                    self.chatDelegate?.loadOlderMessages()

                }
                
                self.blockLoadOldMessages = true
                
                self.isLoadingOldMessages = true
                
            }
            
        }
        else if self.contentOffset.y >= -(self.contentInset.top + 40){
            print("entrou dois")
            blockLoadOldMessages = false
        }
        


    }
    
    public func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        
        if self.contentOffset.y <= 0 - (self.contentInset.top + 40){
            print("entrou um")
            
            blockLoadOldMessages = false

        }
        
    }
    
    
    //MARK: tap on message
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.deselectRowAtIndexPath(indexPath, animated: true)

        self.chatDelegate?.didTapMessageAtIndexPath(indexPath)
        
        
    }
    
    
    
    //MARK: -  Datasource
    
    private func saveReferenceOfCell(cell:UITableViewCell,position:Int){
        
        self.cells[position] = cell
    }
    
    public func chatMessageForRowAtIndexPath(indexPath: NSIndexPath,message:JLMessage)->JLChatMessageCell{
        
        let thisIsNewMessage:Bool = (addedNewMessage && indexPath.row == self.numberOfRowsInSection(0) - 1)
        
        let isOutgoingMessage = message.senderID == self.myID
        
        var identifier:String!
        
        if message.messageKind == MessageKind.Text{
            identifier = isOutgoingMessage ? "outgoingTextCell" : "incomingTextCell"
        }
        else if message.messageKind == MessageKind.Image{
            identifier = isOutgoingMessage ? "outgoingImageCell" : "incomingImageCell"

        }
        else{
            
            identifier = "custom"
        }

        var cellToReturn:JLChatMessageCell!
        
        if identifier == "custom"{
            cellToReturn = self.chatDataSource?.chat(self, customMessageCellForRowAtIndexPath: indexPath)
        }
        else{
            cellToReturn = self.dequeueReusableCellWithIdentifier(identifier) as! JLChatMessageCell
        }
        
        
        cellToReturn.initCell(message, thisIsNewMessage: thisIsNewMessage,showDate: JLChatAppearence.shouldShowMessageDateAtIndexPath(indexPath: indexPath),isOutgoingMessage: isOutgoingMessage)
        
        
        
        if let delegate = self.messagesMenuDelegate{
            
            let deleteTitle = delegate.titleForDeleteMenuItem()
            let sendTitle = delegate.titleForSendMenuItem()
            
            cellToReturn.sendMenuEnabled = { () -> Bool in
                
                if let sendTitle = sendTitle{
                    return delegate.shouldShowMenuItemForCellAtIndexPath(sendTitle, indexPath: indexPath)
                }
                return delegate.shouldShowMenuItemForCellAtIndexPath("Try Again", indexPath: indexPath)

            }
            
            cellToReturn.deleteMenuEnabled = { () -> Bool in
                
                if let deleteTitle = deleteTitle{
                    return delegate.shouldShowMenuItemForCellAtIndexPath(deleteTitle, indexPath: indexPath)
                }
                return delegate.shouldShowMenuItemForCellAtIndexPath("Delete", indexPath: indexPath)
                
            }

            
            
            cellToReturn.configMenu(deleteTitle, sendTitle: sendTitle, deleteBlock: { () -> () in
                delegate.performDeleteActionForCellAtIndexPath(indexPath)
                
                }, sendBlock: { () -> () in
                    delegate.performSendActionForCellAtIndexPath(indexPath)
            })

            
        }

        
        self.saveReferenceOfCell(cellToReturn, position: indexPath.row)
        
        if thisIsNewMessage {
            
            print(" antes de animar\(indexPath.row)")

            cellToReturn.alpha = 0
            
            UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                
                cellToReturn.alpha = 1
                
                }) { (finished) -> Void in
                    print(" apos animar\(indexPath.row)")
                    self.scrollChatToBottom(true)
                    self.addedNewMessage = false
                    
            }
            
        }
        
        
        return cellToReturn
        
    }
    
    private func scrollChatToBottom(animated:Bool){
        
        if self.numberOfSections == 0 || self.numberOfRowsInSection(0) == 0{
            return
        }
        
        let chatContentheight = self.contentSize.height
        
       
        if chatContentheight > self.bounds.height{
            
            self.scrollRectToVisible(CGRect(x: 0, y: chatContentheight - 1, width: 1, height: 1), animated: animated)

        }
        else{
         
            let indexPath = NSIndexPath(forRow: self.numberOfRowsInSection(0) - 1, inSection: 0)
            
            self.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)


        }
        
       
    }
    
    
    
       
    
    //MARK: - ToolBarFrameDelegate methods
    
    
    public func haveToUpdateInsetsBottom(bottom: CGFloat,scrollToBottom:Bool) {
                
        let actualInsets = self.contentInset
        
        self.contentInset = UIEdgeInsets(top: actualInsets.top, left: actualInsets.left, bottom: bottom, right: actualInsets.right)
        
        self.scrollIndicatorInsets = self.contentInset
        
        
        
        let numberOfRows = self.numberOfRowsInSection(0)

        if numberOfRows > 0 && scrollToBottom{
           
            self.scrollChatToBottom(false)
        }
        
    }
    
    
   
    
    
}
