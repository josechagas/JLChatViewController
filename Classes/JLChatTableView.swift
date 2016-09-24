//
//  JLChatTableView.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 29/11/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit

extension NSObject{
    /**
     Execute some operation on a serial queue specially to avoid data inconsistency
     */
    fileprivate func runBlockSinchronized(_ closure:()->()){
        let mySerialQueue = DispatchQueue(label: "sinchronization_Queue", attributes: [])
        
        mySerialQueue.sync {
            closure()
        }
    }
}

@objc public enum JLChatSectionHeaderViewKind:Int{
    /**
     use it for default date header view
     */
    case defaultDateView = 0
    
    /**
     use it for custom date header view
     */
    case customDateView = 1

    /**
     use it for another kind of header view you want to add,
     for example a header view that indicates the number of unread messages.

     */
    case customView = 2
}

/**
Implement this protocol for you define the UIMenuController items of the messages
*/
public protocol JLChatMessagesMenuDelegate{
    
    /**
    executed to discover if the UIMenuItem with title can be shown
    */
    func shouldShowMenuItemForCellAtIndexPath(_ title:String,indexPath:IndexPath)->Bool
    
    /**
    Define the title of the UIMenuItem that excutes the delete action.
    
    The default title is Delete.
     
    Return nil if you want to use the default title.
    */
    func titleForDeleteMenuItem()->String?
    
    /**
     Define the title of the UIMenuItem that excutes the send action.
     
     The default title is Try Again.
     
     Return nil if you want to use the default title.
     */
    func titleForSendMenuItem()->String?
    
    /**
     The action that delete message.
     */
    func performDeleteActionForCellAtIndexPath(_ indexPath:IndexPath)
    /**
     The action that tries to send again the message.
     */
    func performSendActionForCellAtIndexPath(_ indexPath:IndexPath)
    
}


/**
 * This is a public protocol that inherits from UITableViewDataSource
 *
 * You really have to implement it if you want to show the messages of your chat.
 *
 * Its function is really similar to UITableViewDataSource protocol function.
*/
@objc public protocol ChatDataSource{
    /**
     This method will be called always when its necessary to get the corresponding message of indexPath
     - parameter indexPath: The position of JLMessage required
     */
    
    func jlChatMessageAtIndexPath(_ indexPath:IndexPath)->JLMessage?
    
    /**
     Implement this method if your chat needs more than one section, the default section is the one for loading old messages indication
     
     - returns: Number of DateHeaderViews + CustomHeaderViews(CustomDateHeaderViews + OtherCustomViews)
     */
    @objc optional func numberOfDateAndCustomSectionsInJLChat(_ chat:JLChatTableView)->Int
    
    /**
     Implement this method if you implemented 'numberOfDateAndCustomSectionsInJLChat' to indicate the kind of header view for each section
     - parameter section: The section number of the header view
     */
    @objc optional func jlChatKindOfHeaderViewInSection(_ section:Int)->JLChatSectionHeaderViewKind
    
    /**
     Implement this method if your chat has some headerView of kind   JLChatSectionHeaderViewKind.CustomView to inform height of it
     - parameter section: The section of corresponding custom header view
     
     - returns: The corresponding height of custom header View
     */
    @objc optional func jlChatHeightForCustomHeaderInSection(_ section:Int)->CGFloat
    
    /**
     Implement this method if your chat has some headerView of kind  JLChatSectionHeaderViewKind.CustomView and/or JLChatSectionHeaderViewKind.CustomDateView, load your custom header views here
     - parameter section: The section of corresponding custom header view
     
     - returns: The corresponding view of custom header View
     */
    @objc optional func jlChatCustomHeaderInSection(_ section:Int)->UIView?
    
    /**
     The number of messages in corresponding section
     - parameter section: The section that have the header views with date for example
     - returns: The number of messages of the corresponding section
     */
    func jlChatNumberOfMessagesInSection(_ section:Int)->Int
    
    /**
     Implement this method to load the correct message cell for the indexPath
     - parameter indexPath: The indexPath for the cell
     - returns: The loaded cell
     */
    func jlChat(_ chat:JLChatTableView,MessageCellForRowAtIndexPath indexPath:IndexPath)->JLChatMessageCell

    /**
     This method will be called always when there is a message with messageKind = MessageKind.Custom
     */
    @objc optional func chat(_ chat: JLChatTableView, CustomMessageCellForRowAtIndexPath indexPath: IndexPath) -> JLChatMessageCell

    /**
     Implement this method if you want ot change the default title of section for loading old messages indication
     */
    @objc optional func titleForJLChatLoadingView()->String
    
    
}

/**
 Implement this protocol for you respond to touch events and for load events.
*/
public protocol ChatDelegate{
    
    /**
     Executed when it is necessary to load older messages.
     */
    func loadOlderMessages()
    /**
     Executed when there is a tap on any message.
     */
    func didTapMessageAtIndexPath(_ indexPath:IndexPath)
    
}


open class JLChatTableView: UITableView,ToolBarFrameDelegate,UITableViewDelegate,UITableViewDataSource {
    
    /**
     The id of the current user
     */
    open var myID:String!
    /**
     The 'JLChatMessagesMenuDelegate' instance.
     */
    open var messagesMenuDelegate:JLChatMessagesMenuDelegate?
    /**
     The 'ChatDelegate' instance.
     */
    open var chatDelegate:ChatDelegate?
    /**
     The 'ChatDataSource' instance.
     */
    open var chatDataSource:ChatDataSource?{
        didSet{
            self.dataSource = self
            self.delegate = self
            addTableHeader()
        }
    }
    
    
    
    /**
     A boolean value that indicates if should or not scroll to bottom when reloading the data
     */
    fileprivate var enableFirstScrollToBottom:Bool = true
    /**
     The calculated rows height to increase the performance when presenting them to user
     */
    fileprivate var calculatedRowsHeight:[Double:CGFloat] = [Double:CGFloat]()
    
    /**
     A boolean that indicates that the chat will search for unread messages and scroll to them to start showing the first one
     */
    fileprivate var checkForUnreadMessages:Bool = true
    /**
     The position of the first unread message added to chat
     */
    fileprivate var firstUnreadMessageIndexPath:IndexPath?
    
    
    //new messages part - start
    
    /**
     Method that will be called after adding a new message
     */
    fileprivate var addNewMessageCompletion:(()->())?
    /**
     Boolean that indicates that is or not adding a new message
     */
    fileprivate var addingNewMessage:Bool = false
    
    /**
     Saves the reference for changes on datasource because sometimes to add a new message is necessary to execute some other methods first so its necessary to save it and at the right time execute it
     */
    fileprivate var changesOnDataSourceHandler:(()->())?
    
    /**
     The number of new messages that will be added at once
     */
    fileprivate var quantOfNewMess:Int = 0
    
    /**
     Boolean that indicates that is or not scrolling to bottom to add a new message
     */
    fileprivate var scrollingToAddANewMessage:Bool = false
    
    /**
     Boolean that indicates that is or not scrolling to bottom
     */
    fileprivate var scrollingToBottom:Bool = false

    //new messages part - end

    
    //old messages part - start
    /**
     Bolean value that indicates when its loading old messages its specially to avoid load of older messages when its already loading
     */
    fileprivate var isLoadingOldMessages:Bool = false
    //old messages part - end
    
    
    // operations of deletion insertion and update queue - start
    /**
     Boolean value that indicates when its executing some insertion, deletion or update operation
     */
    fileprivate var isExecutingSomeOperation:Bool = false
    typealias ChatClosureType = () -> ()
    fileprivate var messageAddQueue:[ChatClosureType] = [ChatClosureType]()
    // operations of deletion insertion and update queue - end
    
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)

        self.initChatTableView()

    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initChatTableView()
        
    }
    
    /**
     Execute the next action presented on 'completionQueue'
     - parameter afterDelay: a delay in seconds to execute the next job
     */
    fileprivate func runNextJob(_ afterDelay:Double){
        ///-------------------
        self.runBlockSinchronized({
            if self.messageAddQueue.count > 0{
                self.isExecutingSomeOperation = true
                let function = self.messageAddQueue.remove(at: 0)
                let delayInSeconds = afterDelay
                let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: popTime) {
                    function()
                }
            }
            else{
                self.isExecutingSomeOperation = false
            }
        })
        
        
        ///--------------------

    }
    
    //MARK: - Config Update and Reload type methods
    
    fileprivate func initChatTableView(){
        
        self.rowHeight = UITableViewAutomaticDimension
        self.estimatedRowHeight = 60
        self.estimatedSectionHeaderHeight = 71
        
        self.register(UINib(nibName: "JLChatDateView", bundle: JLBundleController.getBundle()), forHeaderFooterViewReuseIdentifier: "DateView")
        
    }
    
   
    
    /**
     This method adds the Table header view that has the title of chat and indicates when its loading old messages
     */
    fileprivate func addTableHeader(){
        
        let view = JLBundleController.getBundle()!.loadNibNamed("JLChatLoadingView", owner: self, options: nil)?[0] as! JLChatLoadingView
        
        if let titleFunc = chatDataSource?.titleForJLChatLoadingView{
            view.loadingTextLabel.text = titleFunc()
        }
        else{
            view.loadingTextLabel.text = "JLChatViewController"
        }
        
        view.activityIndicator.stopAnimating()

        self.tableHeaderView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.frame.width, height: 71)))
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.tableHeaderView?.addSubview(view)
        
        
        //CONSTRAINTS
        
        let topDist = NSLayoutConstraint(item: self.tableHeaderView!, attribute: NSLayoutAttribute.top, relatedBy: .equal, toItem: view, attribute:NSLayoutAttribute.top, multiplier: 1, constant: 0)
        
        self.tableHeaderView?.addConstraint(topDist)
        
        let bottomDist = NSLayoutConstraint(item: self.tableHeaderView!, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: view, attribute:NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        
        self.tableHeaderView?.addConstraint(bottomDist)
        
        let leftDist = NSLayoutConstraint(item: self.tableHeaderView!, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: view, attribute:NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        
        self.tableHeaderView?.addConstraint(leftDist)
        
        let rightDist = NSLayoutConstraint(item: self.tableHeaderView!, attribute: NSLayoutAttribute.trailing, relatedBy: .equal, toItem: view, attribute:NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        
        self.tableHeaderView?.addConstraint(rightDist)

    }
    
    //rows height
    
    fileprivate func invalidateheightsForCells(){
        calculatedRowsHeight.forEach { (key,value) in
            calculatedRowsHeight[key] = 0
        }
    }
    
    /**
     This method get message id and its related cell height and save it to save cpu usage later
     - parameter message: The message instance
     - parameter height: The calculated height of related cell
     */
    fileprivate func addHeightForCellAtIndexPath(_ message:JLMessage,height:CGFloat){
        calculatedRowsHeight[message.id] = height
    }
    
    /**
     This method check for unreadMessage if necessary
     
     ATTENTION: Calling this method out of 'chatMessageForRowAtIndexPath' might be dangerous
     
     - parameter message:The message that is being reloaded or added on 'chatMessageForRowAtIndexPath'
     - parameter indexPath: The indexPath of 'message'
     */
    fileprivate func checkForUnreadMessage(_ message:JLMessage,CurrentIndexPath indexPath:IndexPath){
        
        if let unreadIndex = firstUnreadMessageIndexPath{
            if message.messageRead == false && ((unreadIndex as NSIndexPath).row > (indexPath as NSIndexPath).row || (unreadIndex as NSIndexPath).section > (indexPath as NSIndexPath).section) {
                firstUnreadMessageIndexPath = indexPath
            }
        }
        else if checkForUnreadMessages{
            firstUnreadMessageIndexPath = message.messageRead == false ? indexPath : nil
            if !message.messageRead{
                checkForUnreadMessages = false
                self.enableFirstScrollToBottom = false
            }
            
        }
        
    }
    
    //
    /**
     Use it to add messages that you sent and that you received.
     
     Never use it to add old messages inside chat tableView.
    */
    @available(*,deprecated,renamed: "addNewMessages",message: "This method is deprecated use addNewMessages(quant:Int) instead")
    open func addNewMessage(_ quant:Int){
        self.addNewMessages(quant,changesHandler: {},completionHandler: nil)
    }
   
    /**
     Use it to add messages that you sent and that you received.
     
     Never use it to add old messages inside chat tableView.
     
     - parameter indexPaths: The indexpaths where the new messages will be added
     - parameter changesHandler: A closure that should contain all insertions on your data structure of messages
     - parameter completionHandler: Method that will be called at the end of adding a new message
     */
    open func addNewMessages(_ quant:Int,changesHandler:@escaping ()->(),completionHandler:(()->())?){

        if quant > 0{
            if isExecutingSomeOperation{
                self.runBlockSinchronized({ 
                    self.messageAddQueue.append({
                        print("running add new messages from completionqueue")
                        self.tryToAddNewMessagesNow(quant,changesHandler: changesHandler)
                        self.addNewMessageCompletion = completionHandler
                    })
                })
            }
            else{
                self.tryToAddNewMessagesNow(quant,changesHandler: changesHandler)
                self.addNewMessageCompletion = completionHandler
            }
        }
    }
    
    /**
     Pass nil on quant if its a new try for a older add of new message
     */
    fileprivate func tryToAddNewMessagesNow(_ quant:Int?,changesHandler:(()->())?){
        
        if let quant = quant{
            self.runBlockSinchronized({
                self.quantOfNewMess = quant
                self.isExecutingSomeOperation = true
            })
        }
        
        if let changesHandler = changesHandler{
            self.changesOnDataSourceHandler = changesHandler
        }
        
        if contentSize.height - self.contentOffset.y <= self.bounds.height {//its on bottom
            if !scrollingToBottom && !scrollingToAddANewMessage{
                //its on bottom and its stopped just add
                print("mode 1.0")
                scrollingToAddANewMessage = false
               
                self.addingNewMessage = true
                
                //contabiliza as novas mensagens
                /*to calc indexPaths
                var newIndexPaths:[NSIndexPath] = [NSIndexPath]()

                let oldNumberOfSections = self.numberOfSections
                var newNumberOfSections = 0
                */
                if let function = changesOnDataSourceHandler{
                    runBlockSinchronized({
                        
                        function()
                        self.changesOnDataSourceHandler = nil
                        
                        /* to calc indexPaths
                        newNumberOfSections = self.dataSource!.numberOfSectionsInTableView!(self)
                        
                        for section in (0..<newNumberOfSections).reverse(){
                            for row in (0..<self.dataSource!.tableView(self, numberOfRowsInSection: section)).reverse(){
                         
                                if newIndexPaths.count == self.quantOfNewMess{
                                    break
                                }
                                newIndexPaths.append(NSIndexPath(forRow: row, inSection: section))

                            }
                            
                            if newIndexPaths.count == self.quantOfNewMess{
                                break
                            }
                        }*/
                    })
                    
                    self.runNextJob(0.5)
                }
                
                /*to calc indexPaths
                let quantOfNewSections = newNumberOfSections - oldNumberOfSections

                self.beginUpdates()
                for newSection in 0..<quantOfNewSections{
                    self.insertSections(NSIndexSet(index: oldNumberOfSections + newSection), withRowAnimation: UITableViewRowAnimation.Bottom)
                }
                
                self.insertRowsAtIndexPaths(newIndexPaths, withRowAnimation: UITableViewRowAnimation.Bottom)
                self.endUpdates()
                 */
                self.reloadData()
                
                runAddNewMessagesCompletion(AfterDelay: 0.8)
                
            }
            else{
                //its on bottom and its scrolling in some way
                print("mode 1.1")

                scrollingToAddANewMessage = false
                
                let delayInSeconds = 0.5
                let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: popTime) {
                    self.addingNewMessage = true
                    
                    //contabiliza as novas mensagens
                    if let function = self.changesOnDataSourceHandler{
                        self.runBlockSinchronized({
                            function()
                            self.changesOnDataSourceHandler = nil
                        })
                        
                        self.runNextJob(0.5)
                    }
                    
                    self.reloadData()
                    
                }
                runAddNewMessagesCompletion(AfterDelay: 0.8)
            }
           
        }
        else {//its not on bottom
            
            if !scrollingToBottom && !scrollingToAddANewMessage{
                //its not on bottom and its stopped scrolToBottom
                print("mode 2.0")

                scrollingToAddANewMessage = true
                self.scrollChatToBottom(true,basedOnLastRow: true)
            }
            else{
                //its not on bottom and its scrolling in some way
                print("mode 2.1")
                
                scrollingToAddANewMessage = true
            }
            
        }
    }
    
    
    /**
     This method executes the add new messages completion block
     - parameter delay: a time interval to wait for execute the corresponding block
     */
    fileprivate func runAddNewMessagesCompletion(AfterDelay delay:Double){
        let popTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            if let completion = self.addNewMessageCompletion{
                self.runBlockSinchronized({
                    completion()
                    self.addNewMessageCompletion = nil
                })
            }
        }
    }
    
    /**
     Call this method to reload added messages when changes that might cause error on contentSize, cell height, for example : change orientation, app return from background
     */
    func reloadAddedMessages(){
        invalidateheightsForCells()
        self.enableFirstScrollToBottom = true
        //self.checkForUnreadMessages = true
        self.reloadData()
    }
    /**
     Use it to add old messages inside chat tableView.
     
     ATTENTION: Do not call this method if you won't add messages.
     
     - parameter quant: the number of messages that will be added.
     
     */
    @available(*,deprecated,renamed: "addOldMessages",message: "This method is deprecated use addNewMessages(quant:Int,changesHandler:()->()) instead")
    open func addOldMessages(_ quant:Int){
        self.addOldMessages(quant, changesHandler: {})
    }
    
    /**
     Use it to add old messages inside chat tableView.
     
     ATTENTION: Do not call this method if you won't add messages.
     
     - parameter quant: the number of messages that will be added.
     - parameter changesHandler: A closure that should contain all insertions on your data structure of messages
     */
    open func addOldMessages(_ quant:Int,changesHandler:@escaping ()->()){
        
        if quant > 0{
            if isExecutingSomeOperation{
                self.runBlockSinchronized({
                    self.messageAddQueue.append({
                        print("running add old messages from completionqueue")
                        self.tryToAddOldMessages(quant,changesHandler: changesHandler)
                    })
                })
            }
            else{
                self.tryToAddOldMessages(quant,changesHandler: changesHandler)
            }
        }
        
    }

    /**
     It execute all of the stuffes that add old messages on chat
     
     Never call this method out of addOldMessages method
     */
    fileprivate func tryToAddOldMessages(_ quant:Int,changesHandler:()->()){
        
        
        
        var lastNumbOfSections:Int = 0
        let sectionZeroQuant:Int = self.chatDataSource!.jlChatNumberOfMessagesInSection(0)
        if let function = self.chatDataSource!.numberOfDateAndCustomSectionsInJLChat{
            lastNumbOfSections = function(self)
        }
        
        //contabiliza as novas mensagens
        runBlockSinchronized({
            self.isExecutingSomeOperation = true
            changesHandler()
            
        })
        
        var actualNumbOfSections:Int = 0
        if let function = self.chatDataSource!.numberOfDateAndCustomSectionsInJLChat{
            actualNumbOfSections = function(self)
        }
        //this is the older section 0, before adding old messages
        let lastSectionZeroQuant:Int = self.chatDataSource!.jlChatNumberOfMessagesInSection(actualNumbOfSections - lastNumbOfSections)

        
        enableFirstScrollToBottom = false// putting it to false because it will be true when you try to add old messages for the first time when you started the chat with zero messages
        
    
        var lastTopVisibleCellIndexPath:IndexPath?
        if let visibleIndexPaths = self.indexPathsForVisibleRows , visibleIndexPaths.count > 0{
            lastTopVisibleCellIndexPath = visibleIndexPaths[0]
        }
        
        
        self.reloadData()

        if let indexPath = lastTopVisibleCellIndexPath{
            let newSection = (indexPath as NSIndexPath).section + (actualNumbOfSections - lastNumbOfSections)
            let newRow = (indexPath as NSIndexPath).section > 0 ? (indexPath as NSIndexPath).row : (indexPath as NSIndexPath).row + (lastSectionZeroQuant - sectionZeroQuant)

            let lastTopCellNewIndexPath = IndexPath(row: newRow, section: newSection)

            self.scrollToRow(at: lastTopCellNewIndexPath, at: UITableViewScrollPosition.top, animated: false)
        }
        //stop the activity because ended the load
        forceToFinishLoadingAnimation()
        
        runNextJob(2.0)
    }
    
    /**
     Use this method when some kind of error when trying to load old messages happend and you just want to stop the animation
    */
    open func forceToFinishLoadingAnimation(){
        if let header = self.tableHeaderView!.subviews[0] as? JLChatLoadingView{
            header.activityIndicator.stopAnimating()
        }
        isLoadingOldMessages = false
    }
    
    /**
     Use this method when you want to update the message cell of 'ChatTableView' status
     - parameter indexPath: the indexPath of the cell that you want to update the status.
     
     - parameter message: The message that corresponds to the cell at indexPath 'indexPath'
     with its status already updated.
     */
    open func updateMessageStatusOfCellAtIndexPath(_ indexPath:IndexPath,message:JLMessage){
        
        let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            if let cell = self.cellForRow(at: indexPath) as? JLChatMessageCell{
                cell.updateMessageStatus(message)
            }
        }
    }
    
    
    /**
     Use this method to remove from 'ChatTableView' the message at indexPath
     - parameter indexPath: the indexPath of the message that you want to remove from 'ChatTableView'.
    */
    @available(*,deprecated,renamed: "removeMessagesCellsAtIndexPaths",message: "This method is deprecated use removeMessagesCellsAtIndexPaths instead")
    open func removeMessage(_ indexPath:IndexPath){
        let message:JLMessage? = self.chatDataSource!.jlChatMessageAtIndexPath(indexPath)
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            if let cell = self.cellForRow(at: indexPath){
                cell.alpha = 0
            }
            
        }) { (finished) -> Void in
            if finished{
                if let message = message{
                    self.calculatedRowsHeight.removeValue(forKey: message.id)
                }
                self.reloadData()
            }
        }
    }
    
    /**
     Use this method to remove from 'ChatTableView' a message at some indexPath ANIMATED.
     
     For more than message use 'removeMessagesCells'.
     
     - parameter indexPath: the indexPaths of the messages that you want to remove from 'ChatTableView'.
     - parameter relatedMessage: The messages that corresponds to cells you want to remove from chat
     */
    open func removeMessageCellAtIndexPath(_ indexPath:IndexPath,relatedMessage:JLMessage!){
        //self.calculatedRowsHeight.removeValueForKey(relatedMessage.hash)
        //self.beginUpdates()
        //self.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        //self.endUpdates()
        
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            if let cell = self.cellForRow(at: indexPath){
                cell.alpha = 0
            }
            
        }) { (finished) -> Void in
            if finished{
                self.calculatedRowsHeight.removeValue(forKey: relatedMessage.id)
                self.reloadData()
            }
        }
        /*
        if let indexPathsVisibles = self.indexPathsForVisibleRows{
            let contains = indexPathsVisibles.filter({ (element) -> Bool in
                return indexPath.row == element.row && indexPath.section == element.section
            }).count > 0
            
            if contains{
                if let cell = self.cellForRowAtIndexPath(indexPath){
                    UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                        
                        cell.alpha = 0
                        
                    }) { (finished) -> Void in
                        if finished {
                            self.reloadData()
                        }
                    }
                    if let rect = frameMadeByRowsInRange(NSRange(location: indexPath.row, length: 1), AndSection: indexPath.section){
                        
                        moveChatItemsToCoverFrame(rect)
                        
                    }
                    return
                }
            }
            
            let section = indexPath.section
            let row = indexPath.row
            
            let popTime = dispatch_time(DISPATCH_TIME_NOW,
                                        Int64(0.25 * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                var lastVisibleIndexPath:NSIndexPath?
                
                if let visibleOnes = self.indexPathsForVisibleRows where visibleOnes.count > 0{
                    lastVisibleIndexPath = visibleOnes.last!
                    //adjusting because of remotion of some section
                    if section == lastVisibleIndexPath!.section && row <= lastVisibleIndexPath!.row{
                        lastVisibleIndexPath = NSIndexPath(forRow: lastVisibleIndexPath!.row - 1, inSection: section)
                    }
                }
                
                self.reloadData()
                //self.deleteSections(NSIndexSet(index: section), withRowAnimation: UITableViewRowAnimation.None)
                if let indexPath = lastVisibleIndexPath{
                    self.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                }
            }
        }*/
    }
    
    /**
     Call this method if you want to remove some section ANIMATED.
     
     For more than one section use 'removeMessagesCells'.
     
     - parameter section: The section number that you want to remove
     - parameter messagesOfSection: the messages that belongs to this section and will be removed to.
     */
    open func removeChatSection(_ section:Int,messagesOfSection:[JLMessage]?){
        
        if let messages = messagesOfSection{
            for message in messages{
                self.calculatedRowsHeight.removeValue(forKey: message.id)
            }
        }
        else if self.numberOfRows(inSection: section) > 0{
            self.calculatedRowsHeight.removeAll()
        }
        
        if self.numberOfSections > self.dataSource!.numberOfSections!(in: self){
            self.beginUpdates()
            self.deleteSections(IndexSet(integer: section), with: UITableViewRowAnimation.fade)
            self.endUpdates()
        }
        
 
        /*
        if let headerView = self.headerViewForSection(section){
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                headerView.alpha = 0
                for i in 0..<self.numberOfRowsInSection(section){
                    if let cell = self.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: section)){
                        cell.alpha = 0
                    }
                }
            }) { (finished) -> Void in
                if finished && !self.addingNewMessage{
                    self.reloadData()
                }
            }
            if let rect = frameMadeByRowsInRange(NSRange(location: 0, length: self.numberOfRowsInSection(section)), AndSection: section){
                
                moveChatItemsToCoverFrame(rect)
                
            }
        }
        else{
            
            let popTime = dispatch_time(DISPATCH_TIME_NOW,
                                        Int64(0.25 * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                var lastVisibleIndexPath:NSIndexPath?
                
                if let visibleOnes = self.indexPathsForVisibleRows where visibleOnes.count > 0{
                    lastVisibleIndexPath = visibleOnes.last!
                    //adjusting because of remotion of some section
                    if section == lastVisibleIndexPath!.section && section > 0{
                        lastVisibleIndexPath = NSIndexPath(forRow: self.numberOfRowsInSection(section - 1), inSection: section - 1)
                    }
                    else if section < lastVisibleIndexPath!.section{
                        lastVisibleIndexPath = NSIndexPath(forRow: lastVisibleIndexPath!.row, inSection: lastVisibleIndexPath!.section - 1)
                    }
                }
                self.reloadData()
                if let indexPath = lastVisibleIndexPath{
                    self.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                }
            }
        }
        */
        
    }
    
    /**
     Call this method if you want to remove more than one element from chat at once ANIMATED.
     
     - parameter rowsIndexPath: An array that contains the indexPaths of messages you want to delete.
     - parameter sections: An array that contains the position of sections you want to delete.
     - parameter relatedMessages: The messages related to rowsIndexPath and to sections.
     */
    open func removeMessagesCells(_ rowsIndexPath:[IndexPath]?,AndSections sections:[Int]?,WithRelatedMessages relatedMessages:[JLMessage]?){
        if let messages = relatedMessages{
            for message in messages{
                self.calculatedRowsHeight.removeValue(forKey: message.id)
            }
        }
        else{
            self.calculatedRowsHeight.removeAll()
        }
        
        var indexPaths = [IndexPath]()
        var sectionsNumber = [Int]()
        if let rowsIndexs = rowsIndexPath{
            indexPaths = rowsIndexs
        }
        
        if let sec = sections{
            sectionsNumber = sec
        }
        
        self.beginUpdates()
        self.deleteRows(at: indexPaths, with: UITableViewRowAnimation.fade)
        for i in sectionsNumber{
            self.deleteSections(IndexSet(integer: i), with: UITableViewRowAnimation.fade)
        }
        self.endUpdates()

    }
    
    
    
    fileprivate func frameMadeByRowsInRange(_ rowsRange:NSRange?,AndSection section:Int)->CGRect?{
        
        var initialRow = 0
        var totalRows = 0
        
        if let rowsRange = rowsRange{
            initialRow = rowsRange.location
            totalRows = rowsRange.length + rowsRange.location < self.numberOfRows(inSection: section) ? rowsRange.length + rowsRange.location : self.numberOfRows(inSection: section)
        }
        
        var totalHeight:CGFloat = 0
        var initialRowFrame:CGRect?
        for row in initialRow..<totalRows{
            if let cell = self.cellForRow(at: IndexPath(row: row, section: section)){
                if let _ = initialRowFrame{
                    
                }
                else{
                    initialRowFrame = cell.frame
                }
                totalHeight += cell.frame.height
            }
        }
        
        if totalRows == self.numberOfRows(inSection: section){
            if let header = self.headerView(forSection: section){
                if let _ = initialRowFrame{
                    
                }
                else{
                    initialRowFrame = header.frame
                }
                
                totalHeight += header.frame.height + 0.1//footer
            }
            
        }
        
        if let _ = initialRowFrame{
            return CGRect(origin: initialRowFrame!.origin, size: CGSize(width: initialRowFrame!.width, height: totalHeight))
        }
        return nil
    }
    
    /**
     Call this method to animated move the items(rows, sections header and footers) to cover the frame occuped by some row at indexPath
     
     - parameter choosedIndexPath: The indexPath of the row to cover the frame
     */
    fileprivate func moveChatItemsToCoverFrame(_ frame:CGRect!){
        
        if frame.height > 0{
            
            var beforeCellMoveBy = CGFloat(0)
            var afterCellMoveBy = CGFloat(0)
            
            let yPosition:CGFloat = frame.origin.y
            
            if self.contentSize.height > self.bounds.height{
                if self.contentOffset.y < frame.height/2{
                    beforeCellMoveBy = 0
                    afterCellMoveBy = -frame.height
                }
                else if self.contentSize.height - (self.bounds.height + self.contentOffset.y) < frame.height/2{
                    beforeCellMoveBy = frame.height
                    afterCellMoveBy = 0
                }
                else{
                    afterCellMoveBy = -frame.height
                    /*if self.contentSize.height - (self.bounds.height + self.contentOffset.y) > self.contentOffset.y{
                        beforeCellMoveBy = frame.height
                    }
                    else{
                        afterCellMoveBy = -frame.height
                    }*/
                    
                }
            }
            else{
                afterCellMoveBy = -frame.height
            }
            
            for i in 0..<self.numberOfSections{
                //for headers
                if let sectionHeader = self.headerView(forSection: i){
                    sectionHeader.layer.delegate = self//.layer
                    UIView.animateKeyframes(withDuration: 0.25, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
                        
                        if sectionHeader.frame.origin.y < yPosition{
                            sectionHeader.frame.origin = CGPoint(x: sectionHeader.frame.origin.x, y: sectionHeader.frame.origin.y + beforeCellMoveBy)
                        }
                        else{
                            sectionHeader.frame.origin = CGPoint(x: sectionHeader.frame.origin.x, y: sectionHeader.frame.origin.y + afterCellMoveBy)
                        }
                        
                        }, completion: { (finished) in
                            
                    })
                    
                }
                //for footers
                if let sectionFooter = self.footerView(forSection: i){
                    sectionFooter.layer.delegate = self//.layer
                    UIView.animateKeyframes(withDuration: 0.25, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
                        
                        if sectionFooter.frame.origin.y < yPosition{
                            sectionFooter.frame.origin = CGPoint(x: sectionFooter.frame.origin.x, y: sectionFooter.frame.origin.y + beforeCellMoveBy)
                        }
                        else{
                            sectionFooter.frame.origin = CGPoint(x: sectionFooter.frame.origin.x, y: sectionFooter.frame.origin.y + afterCellMoveBy)
                        }
                        
                        }, completion: { (finished) in
                            
                    })
                    
                }
            }
            
            //for rows
            if let indexPaths = self.indexPathsForVisibleRows{
                for indexPath in indexPaths{
                    if let cell = self.cellForRow(at: indexPath){
                        cell.layer.delegate = self//.layer
                        UIView.animateKeyframes(withDuration: 0.25, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
                            
                            if cell.frame.origin.y < yPosition{
                                cell.frame.origin = CGPoint(x: cell.frame.origin.x, y: cell.frame.origin.y + beforeCellMoveBy)
                            }
                            else if cell.frame.origin.y > yPosition{
                                cell.frame.origin = CGPoint(x: cell.frame.origin.x, y: cell.frame.origin.y + afterCellMoveBy)
                            }
                            
                            }, completion: { (finished) in
                                
                        })
                        
                    }
                }
 
            }
         }
    }

    /**
     This method configure the menu items and actions for each cell if the 'JLChatMenuDelegate' id implemented
     
     - parameter cell: The cell that will be configured
     - parameter indexPath: the indexpath that contain this cell
     */
    fileprivate func configMenuItemsOfCell(_ cell:JLChatMessageCell, ForRowAtIndexPath indexPath:IndexPath){
        if let delegate = self.messagesMenuDelegate {
            
            let deleteTitle = delegate.titleForDeleteMenuItem()
            let sendTitle = delegate.titleForSendMenuItem()
            
            cell.sendMenuEnabled = { () -> Bool in
                if let correctIndexPath = self.indexPath(for: cell) , !self.isExecutingSomeOperation{
                    if let sendTitle = sendTitle{
                        return delegate.shouldShowMenuItemForCellAtIndexPath(sendTitle, indexPath: correctIndexPath)
                    }
                    return delegate.shouldShowMenuItemForCellAtIndexPath("Try Again", indexPath: correctIndexPath)
                }
                return false
                
            }
            
            cell.deleteMenuEnabled = { () -> Bool in
                if let correctIndexPath = self.indexPath(for: cell) , !self.isExecutingSomeOperation{
                    if let deleteTitle = deleteTitle{
                        return delegate.shouldShowMenuItemForCellAtIndexPath(deleteTitle, indexPath: correctIndexPath)
                    }
                    return delegate.shouldShowMenuItemForCellAtIndexPath("Delete", indexPath: indexPath)
                }
                return false
            }
            
            
            
            cell.configMenu(deleteTitle, sendTitle: sendTitle, deleteBlock: { () -> () in
                if let correctIndexPath = self.indexPath(for: cell){
                    delegate.performDeleteActionForCellAtIndexPath(correctIndexPath)
                }
                
                }, sendBlock: { () -> () in
                    if let correctIndexPath = self.indexPath(for: cell){
                        delegate.performSendActionForCellAtIndexPath(correctIndexPath)
                    }
            })
            
        }
    }
    
    /**
     Animates the addition of new message
     
     - parameter cell: The instance of cell to animate addition
     - parameter indexPath: The indexpath of corresponding cell
     - parameter completionHandler: A block of code to be executed after animating the last new message cell
     */
    fileprivate func animateAdditionOfNewMessageCell(_ cell:JLChatMessageCell,AtIndexPath indexPath:IndexPath,completionHandler:@escaping ()->()){
        let lastSectionNumber = self.numberOfSections - 1
        
        for number in (0..<quantOfNewMess).reversed(){
            //let index = newIndexPaths[number]
            let lastRowAtSection = self.numberOfRows(inSection: lastSectionNumber) - 1
            if (indexPath as NSIndexPath).row == lastRowAtSection - number && (indexPath as NSIndexPath).section == lastSectionNumber{//newer message
                //Animate it's  appearance
                cell.contentView.alpha = 0
                print("animando aparicao da menssagem \((indexPath as NSIndexPath).row)")
                let delayInSeconds = 0.4
                let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: popTime) {
                    //print("animando no willDisplayCEll")
                    UIView.animate(withDuration: 0.6, animations: {
                        cell.contentView.alpha = 1
                        }, completion: { (finished) in
                            if finished{
                                if number == 0{//this is the real last message
                                    self.addingNewMessage = false
                                    completionHandler()
                                }
                            }
                            
                    })
                }
                break
            }
            
        }
    }
 
    //MARK: - ScrollView methods
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollingToBottom = false
        
        //was scrolling to add a new message and its on bottom
        if scrollingToAddANewMessage && contentSize.height - self.contentOffset.y <= self.bounds.height{
            self.tryToAddNewMessagesNow(nil, changesHandler: nil)
        }
    }
    
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingToBottom = false
        if self.contentOffset.y <= 0 - (self.contentInset.top){//its on top or bouncing on top
            if !isLoadingOldMessages{
                
                if let header = self.tableHeaderView!.subviews[0] as? JLChatLoadingView{
                    
                    header.activityIndicator.startAnimating()
                    
                    self.isLoadingOldMessages = true
                    
                    self.chatDelegate?.loadOlderMessages()
                }
            }
        }
    }
    
    //MARK: - Delegate
    
    //MARK: header methods
    
    
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let lastSectionNumber = self.numberOfSections - 1
        if addingNewMessage && lastSectionNumber == section && self.numberOfRows(inSection: section) == 1{
            let delayInSeconds = 0.1
            view.alpha = 0
            let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: popTime) {
                UIView.animate(withDuration: 1, animations: {
                    view.alpha = 1
                })
            }

        }
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
  
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if let _ = chatDataSource{
            if let sectionKindFunc = self.chatDataSource!.jlChatKindOfHeaderViewInSection{
                if sectionKindFunc(section) != JLChatSectionHeaderViewKind.defaultDateView{
                    if let viewHeighFunc = self.chatDataSource!.jlChatHeightForCustomHeaderInSection{
                        return viewHeighFunc(section)
                    }
                    else{
                        print("\n\n\n ERROR\n You are using custom date view , so implement the method jlChatHeightForCustomHeaderInSection of ChatDataSource")
                        
                        abort()
                    }
                    
                }
            }
            else{
                print("\n\n\n ERROR\n You are saying that you have some date and or custom header views on JLChat , so implement the method jlChatKindOfSection of ChatDataSource")
                
                abort()
                
            }

        }
        return 21
    }
    
    
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let _ = chatDataSource{
            
            if let sectionKindFunc = self.chatDataSource!.jlChatKindOfHeaderViewInSection{
                switch sectionKindFunc(section){
                case JLChatSectionHeaderViewKind.customView, JLChatSectionHeaderViewKind.customDateView:
                    if let customViewFunc = self.chatDataSource!.jlChatCustomHeaderInSection{
                        return customViewFunc(section)
                    }
                    else{
                        print("\n\n\n ERROR\n You are using custom date view , so implement the method jlChatCustomHeaderInSection of ChatDataSource")
                        abort()
                    }
                    
                //case JLChatSectionHeaderViewKind.DefaultDateView:
                default:
                    if let view = self.dequeueReusableHeaderFooterView(withIdentifier: "DateView") as? JLChatDateView{
                        if let firstMessageOfSection = self.chatDataSource!.jlChatMessageAtIndexPath(IndexPath(row: 0, section: section)){
                            view.dateLabel.text = firstMessageOfSection.generateStringFromDate()
                        }
                        return view
                    }
                }
                
            }
            else{
                print("\n\n\n ERROR\n You are saying that you have some date and or custom header views on JLChat , so implement the method jlChatKindOfSection of ChatDataSource")
                
                abort()
                
                
            }

        }
        
        return nil
    }

    
    //MARK: Cell methods
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let message = self.chatDataSource!.jlChatMessageAtIndexPath(indexPath){
            if let value = calculatedRowsHeight[message.id] , value != 0{
                return value
            }
        }
        return 60
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let message = self.chatDataSource!.jlChatMessageAtIndexPath(indexPath){
            if let value = calculatedRowsHeight[message.id] , value != 0{
                print("calculated \((indexPath as NSIndexPath).row)")
                return value
            }
        }
        print("not calculated \((indexPath as NSIndexPath).row)")
        return UITableViewAutomaticDimension
    }
    
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.deselectRow(at: indexPath, animated: true)
       
        self.chatDelegate?.didTapMessageAtIndexPath(indexPath)

    }
    
    
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cellToReturn = cell as! JLChatMessageCell
        
        configMenuItemsOfCell(cellToReturn, ForRowAtIndexPath: indexPath)
        
        
        let lastSectionNumber = self.numberOfSections - 1
        
        if addingNewMessage{
            animateAdditionOfNewMessageCell(cellToReturn, AtIndexPath: indexPath,completionHandler: {
                //execute the next job after 0.25 seconds
                //self.runNextJob(0.25)
            })
        }
        
        if let index = firstUnreadMessageIndexPath{
            if ((indexPath as NSIndexPath).row == (index as NSIndexPath).row && (indexPath as NSIndexPath).section == (index as NSIndexPath).section){
                firstUnreadMessageIndexPath = nil
            }
        }
        else if ((indexPath as NSIndexPath).row == self.numberOfRows(inSection: lastSectionNumber) - 1 && (indexPath as NSIndexPath).section == lastSectionNumber){
            self.enableFirstScrollToBottom = false
        }

        
        if let message = self.chatDataSource!.jlChatMessageAtIndexPath(indexPath){
            self.addHeightForCellAtIndexPath(message, height:cellToReturn.frame.height)
        }
    }

    
    //MARK: -  Datasource

    open func numberOfSections(in tableView: UITableView) -> Int {
        
        if let function = self.chatDataSource!.numberOfDateAndCustomSectionsInJLChat{
            return function(self)
        }
        return 0

    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatDataSource!.jlChatNumberOfMessagesInSection(section)
    }
    
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.chatDataSource!.jlChat(self, MessageCellForRowAtIndexPath: indexPath)
        
        return cell
    }
    
    /**
    Call this method to make all basic configuration and creation of your message cell
    
    - parameter indexPath: The indexPath of the cell on chat tableView.
    - returns: The created message cell.
    */
    open func chatMessageForRowAtIndexPath(_ indexPath: IndexPath)->JLChatMessageCell{
        
        let lastSectionNumber = self.numberOfSections - 1
        
        let message = chatDataSource!.jlChatMessageAtIndexPath(indexPath)!
        
        //Check for unread messages when necessary
        checkForUnreadMessage(message, CurrentIndexPath: indexPath)
        //
        
        // configuration part
        let thisIsTheNewMessage:Bool = (addingNewMessage && (indexPath as NSIndexPath).row == self.numberOfRows(inSection: lastSectionNumber) - 1 && (indexPath as NSIndexPath).section == lastSectionNumber)
        
        let isOutgoingMessage = message.senderID == self.myID
        
        var identifier:String!
        
        if message.messageKind == MessageKind.text{
            identifier = isOutgoingMessage ? "outgoingTextCell" : "incomingTextCell"
        }
        else if message.messageKind == MessageKind.image{
            identifier = isOutgoingMessage ? "outgoingImageCell" : "incomingImageCell"
            
        }
        else{
            identifier = "custom"
        }
        
        var cellToReturn:JLChatMessageCell!
        
        if identifier == "custom"{
            if let customMess = self.chatDataSource!.chat{
                cellToReturn = customMess(self, indexPath)
            }
            else{
                print("\n\n\n ERROR\n You have one or more messages with messageKind property equal to MessageKind.Custom, so implement the method chat(chat: JLChatTableView, CustomMessageCellForRowAtIndexPath indexPath: NSIndexPath) of ChatDataSource")
                
                abort()
            }
        }
        else{
            
            cellToReturn = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! JLChatMessageCell
            
            
        }
        
        cellToReturn.initCell(message, isOutgoingMessage: isOutgoingMessage)
        
        //cellToReturn.initCell(message, thisIsNewMessage:thisIsTheNewMessage,isOutgoingMessage: isOutgoingMessage)
        
        //scroll position organization part
        positionScrollProperly(UsingIndexPath: indexPath)

        return cellToReturn
    }
    
    
    @available(*, deprecated,renamed: "chatMessageForRowAtIndexPath", message: "This method is deprecated use `chatMessageForRowAtIndexPath(indexPath: NSIndexPath)` instead ")
    open func chatMessageForRowAtIndexPath(_ indexPath: IndexPath,message:JLMessage)->JLChatMessageCell{
        return chatMessageForRowAtIndexPath(indexPath)
    }
    
    //MARK: - Custom scroll positioning methods
    
    /**
     Position the scroll properly if there is unread message,'addingNewMessage' is TRUE or if 'enableFirstScrollToBottom' is TRUE
     
     ATTENTION: Do not call this method out of 'chatMessageForRowAtIndexPath' method
     
     - parameter indexPath: The indexPath of message that is being reloaded or added on 'chatMessageForRowAtIndexPath'
     */
    fileprivate func positionScrollProperly(UsingIndexPath indexPath:IndexPath){
        
        if let unReadMessindexPath = firstUnreadMessageIndexPath{
            let delayInSeconds = 0.01
            let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: popTime) {
                self.scrollToRow(at: unReadMessindexPath, at: UITableViewScrollPosition.middle, animated: false)
            }
        }
        else if addingNewMessage{
            
            let lastSectionNumber = self.numberOfSections - 1
            if (indexPath as NSIndexPath).row >= self.numberOfRows(inSection: lastSectionNumber) - (1 + quantOfNewMess) && (indexPath as NSIndexPath).section == lastSectionNumber{//newer message
                let delayInSeconds = 0.34
                let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: popTime) {
                    self.scrollChatToBottom(true,basedOnLastRow: false)
                }
                
            }
            
        }
        else if enableFirstScrollToBottom{
            if let visibleIndexPaths = self.indexPathsForVisibleRows , visibleIndexPaths.count > 0{
                let delayInSeconds = 0.01
                let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: popTime) {
                    self.scrollChatToBottom(false,basedOnLastRow: false)
                }
            }
        }
    }
    
    /**
     This method scroll chat to bottom.

     Do not call this method wihout studying the library.
     
     - parameter animated:True if you want to animate the scrolling and false if not.
     - parameter basedOnLastRow: A boolean that indicates to do the scroll using scrollToRowAtIndexPath or not use it for really big distances, pass nil on this parameter if you do not want to decide it
     */
    open func scrollChatToBottom(_ animated:Bool,basedOnLastRow:Bool?){
        
        //when scrolling with animated false, it should not be changed to true because this kind of scroll only hanpen on configuration moment.
        scrollingToBottom = animated
        
        let chatContentheight = self.contentSize.height
        let lastSectionNumber = numberOfSections - 1
        if let basedOnLastRow = basedOnLastRow{
            if basedOnLastRow{
                print("to bottom with scrollToRow")
                let indexPath = IndexPath(row:self.numberOfRows(inSection: lastSectionNumber) - 1, section:lastSectionNumber)
                self.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
            }
            else{
                print("to bottom with scrollToRect")
                self.scrollRectToVisible(CGRect(x: 0, y: chatContentheight - 1, width: 1, height: 1), animated: animated)
            }
        }
        else{
            if chatContentheight - self.contentOffset.y <= self.bounds.size.height + 100{//se estiver no bottom ou a uma distancia de no maximo 100 do bottom
                print("to bottom with scrollToRect")
                self.scrollRectToVisible(CGRect(x: 0, y: chatContentheight - 1, width: 1, height: 1), animated: animated)
            }
            else{
                print("to bottom with scrollToRow")
                let indexPath = IndexPath(row:self.numberOfRows(inSection: lastSectionNumber) - 1, section: lastSectionNumber)
                self.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
            }
            
        }
        
        //}
        
    }
    
    
    
    //MARK: - ToolBarFrameDelegate methods
    
    
    open func haveToUpdateInsetsBottom(_ bottom: CGFloat,scrollToBottom:Bool) {
        
        updateInsetsBottom(bottom,animated: false,duration: 0)
        
        if scrollToBottom{
            self.scrollChatToBottom(true,basedOnLastRow: nil)
        }
        
    }
    
    open func updateInsetsBottom(_ bottom:CGFloat,animated:Bool,duration:TimeInterval){
        
        let actualInsets = self.contentInset

        if animated{
            UIView.animate(withDuration: duration, animations: {
                self.contentInset = UIEdgeInsets(top: actualInsets.top, left: actualInsets.left, bottom: bottom, right: actualInsets.right)
                self.scrollIndicatorInsets = self.contentInset
                
            }, completion: { (finished) in
                if finished{
                    let numberOfRows = self.numberOfSections
                    
                    if numberOfRows > 0 && self.contentSize.height - self.contentOffset.y <= self.bounds.size.height{//if there is rows and it`s on bottom
                        self.scrollChatToBottom(true,basedOnLastRow: nil)
                    }
                }
            }) 
        }
        else{
            self.contentInset = UIEdgeInsets(top: actualInsets.top, left: actualInsets.left, bottom: bottom, right: actualInsets.right)
            self.scrollIndicatorInsets = self.contentInset
            
            let numberOfRows = self.numberOfSections
            
            if numberOfRows > 0 && self.contentSize.height - self.contentOffset.y <= self.bounds.size.height{//if there is rows and it`s on bottom
                self.scrollChatToBottom(true,basedOnLastRow: nil)
            }

        }
    }
   
    
    
}
