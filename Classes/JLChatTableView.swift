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
    private func runBlockSinchronized(closure:()->()){
        let mySerialQueue = dispatch_queue_create("sinchronization_Queue", DISPATCH_QUEUE_SERIAL)
        
        dispatch_sync(mySerialQueue) {
            closure()
        }
    }
}

@objc public enum JLChatSectionHeaderViewKind:Int{
    /**
     use it for default date header view
     */
    case DefaultDateView = 0
    
    /**
     use it for custom date header view
     */
    case CustomDateView = 1

    /**
     use it for another kind of header view you want to add,
     for example a header view that indicates the number of unread messages.

     */
    case CustomView = 2
}

/**
Implement this protocol for you define the UIMenuController items of the messages
*/
public protocol JLChatMessagesMenuDelegate{
    
    /**
    executed to discover if the UIMenuItem with title can be shown
    */
    func shouldShowMenuItemForCellAtIndexPath(title:String,indexPath:NSIndexPath)->Bool
    
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
    func performDeleteActionForCellAtIndexPath(indexPath:NSIndexPath)
    /**
     The action that tries to send again the message.
     */
    func performSendActionForCellAtIndexPath(indexPath:NSIndexPath)
    
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
    
    func jlChatMessageAtIndexPath(indexPath:NSIndexPath)->JLMessage?
    
    /**
     Implement this method if your chat needs more than one section, the default section is the one for loading old messages indication
     
     - returns: Number of DateHeaderViews + CustomHeaderViews(CustomDateHeaderViews + OtherCustomViews)
     */
    optional func numberOfDateAndCustomSectionsInJLChat(chat:JLChatTableView)->Int
    
    /**
     Implement this method if you implemented 'numberOfDateAndCustomSectionsInJLChat' to indicate the kind of header view for each section
     - parameter section: The section number of the header view
     */
    optional func jlChatKindOfHeaderViewInSection(section:Int)->JLChatSectionHeaderViewKind
    
    /**
     Implement this method if your chat has some headerView of kind   JLChatSectionHeaderViewKind.CustomView to inform height of it
     - parameter section: The section of corresponding custom header view
     
     - returns: The corresponding height of custom header View
     */
    optional func jlChatHeightForCustomHeaderInSection(section:Int)->CGFloat
    
    /**
     Implement this method if your chat has some headerView of kind  JLChatSectionHeaderViewKind.CustomView and/or JLChatSectionHeaderViewKind.CustomDateView, load your custom header views here
     - parameter section: The section of corresponding custom header view
     
     - returns: The corresponding view of custom header View
     */
    optional func jlChatCustomHeaderInSection(section:Int)->UIView?
    
    /**
     The number of messages in corresponding section
     - parameter section: The section that have the header views with date for example
     - returns: The number of messages of the corresponding section
     */
    func jlChatNumberOfMessagesInSection(section:Int)->Int
    
    /**
     Implement this method to load the correct message cell for the indexPath
     - parameter indexPath: The indexPath for the cell
     - returns: The loaded cell
     */
    func jlChat(chat:JLChatTableView,MessageCellForRowAtIndexPath indexPath:NSIndexPath)->JLChatMessageCell

    /**
     This method will be called always when there is a message with messageKind = MessageKind.Custom
     */
    optional func chat(chat: JLChatTableView, CustomMessageCellForRowAtIndexPath indexPath: NSIndexPath) -> JLChatMessageCell

    /**
     Implement this method if you want ot change the default title of section for loading old messages indication
     */
    optional func titleForJLChatLoadingView()->String
    
    
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
    func didTapMessageAtIndexPath(indexPath:NSIndexPath)
    
}


public class JLChatTableView: UITableView,ToolBarFrameDelegate,UITableViewDelegate,UITableViewDataSource {
    
    /**
     The id of the current user
     */
    public var myID:String!
    /**
     The 'JLChatMessagesMenuDelegate' instance.
     */
    public var messagesMenuDelegate:JLChatMessagesMenuDelegate?
    /**
     The 'ChatDelegate' instance.
     */
    public var chatDelegate:ChatDelegate?
    /**
     The 'ChatDataSource' instance.
     */
    public var chatDataSource:ChatDataSource?{
        didSet{
            self.dataSource = self
            self.delegate = self
        }
    }
    
    
    
    /**
     A boolean value that indicates if should or not scroll to bottom when reloading the data
     */
    private var enableFirstScrollToBottom:Bool = true
    /**
     The calculated rows height to increase the performance when presenting them to user
     */
    private var calculatedRowsHeight:[Int:CGFloat] = [Int:CGFloat]()
    
    /**
     A boolean that indicates that the chat will search for unread messages and scroll to them to start showing the first one
     */
    private var checkForUnreadMessages:Bool = true
    /**
     The position of the first unread message added to chat
     */
    private var firstUnreadMessageIndexPath:NSIndexPath?
    
    
    //new messages part - start
    
    /**
     Method that will be called after adding a new message
     */
    private var addNewMessageCompletion:(()->())?
    /**
     Boolean that indicates that is or not adding a new message
     */
    private var addingNewMessage:Bool = false
    
    /**
     Saves the reference for changes on datasource because sometimes to add a new message is necessary to execute some other methods first so its necessary to save it and at the right time execute it
     */
    private var changesOnDataSourceHandler:(()->())?
    
    /**
     The number of new messages that will be added at once
     */
    private var quantOfNewMess:Int = 0
    
    /**
     Boolean that indicates that is or not scrolling to bottom to add a new message
     */
    private var scrollingToAddANewMessage:Bool = false
    
    /**
     Boolean that indicates that is or not scrolling to bottom
     */
    private var scrollingToBottom:Bool = false

    //new messages part - end

    
    //old messages part - start
    /**
     Bolean value that indicates when its loading old messages its specially to avoid load of older messages when its already loading
     */
    private var isLoadingOldMessages:Bool = false
    //old messages part - end
    
    
    // operations of deletion insertion and update queue - start
    /**
     Boolean value that indicates when its executing some insertion, deletion or update operation
     */
    private var isExecutingSomeOperation:Bool = false
    typealias ChatClosureType = () -> ()
    private var messageAddQueue:[ChatClosureType] = [ChatClosureType]()
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
    private func runNextJob(afterDelay:Double){
        ///-------------------
        self.runBlockSinchronized({
            if self.messageAddQueue.count > 0{
                self.isExecutingSomeOperation = true
                let function = self.messageAddQueue.removeAtIndex(0)
                let delayInSeconds = afterDelay
                let popTime = dispatch_time(DISPATCH_TIME_NOW,Int64(delayInSeconds * Double(NSEC_PER_SEC)))
                dispatch_after(popTime, dispatch_get_main_queue()) {
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
    
    private func initChatTableView(){
        
        self.rowHeight = UITableViewAutomaticDimension
        self.estimatedRowHeight = 60
        self.estimatedSectionHeaderHeight = 71
        
        self.registerNib(UINib(nibName: "JLChatDateView", bundle: JLBundleController.getBundle()), forHeaderFooterViewReuseIdentifier: "DateView")

        addTableHeader()
        
    }
    
   
    
    /**
     This method adds the Table header view that has the title of chat and indicates when its loading old messages
     */
    private func addTableHeader(){
        
        let view = JLBundleController.getBundle()!.loadNibNamed("JLChatLoadingView", owner: self, options: nil)[0] as! JLChatLoadingView
        
        if let titleFunc = chatDataSource?.titleForJLChatLoadingView{
            view.loadingTextLabel.text = titleFunc()
        }
        else{
            view.loadingTextLabel.text = "JLChatViewController"
        }
        
        view.activityIndicator.stopAnimating()

        self.tableHeaderView = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: self.frame.width, height: 71)))
        
        self.tableHeaderView?.addSubview(view)
        
    }
    
    //rows height
    
    private func invalidateheightsForCells(){
        calculatedRowsHeight.forEach { (key,value) in
            calculatedRowsHeight[key] = 0
        }
    }
    
    private func addHeightForCellAtIndexPath(messageHash:Int,height:CGFloat){
        calculatedRowsHeight[messageHash] = height
    }
    
    /**
     This method check for unreadMessage if necessary
     
     ATTENTION: Calling this method out of 'chatMessageForRowAtIndexPath' might be dangerous
     
     - parameter message:The message that is being reloaded or added on 'chatMessageForRowAtIndexPath'
     - parameter indexPath: The indexPath of 'message'
     */
    private func checkForUnreadMessage(message:JLMessage,CurrentIndexPath indexPath:NSIndexPath){
        
        if let unreadIndex = firstUnreadMessageIndexPath{
            if message.messageRead == false && (unreadIndex.row > indexPath.row || unreadIndex.section > indexPath.section) {
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
    @available(*,deprecated,renamed="addNewMessages(quant:Int)",message="This method is deprecated use addNewMessages(quant:Int) instead")
    public func addNewMessage(quant:Int){
        self.addNewMessages(quant,changesHandler: {},completionHandler: nil)
    }
   
    /**
     Use it to add messages that you sent and that you received.
     
     Never use it to add old messages inside chat tableView.
     
     - parameter indexPaths: The indexpaths where the new messages will be added
     - parameter changesHandler: A closure that should contain all insertions on your data structure of messages
     - parameter completionHandler: Method that will be called at the end of adding a new message
     */
    public func addNewMessages(quant:Int,changesHandler:()->(),completionHandler:(()->())?){

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
    private func tryToAddNewMessagesNow(quant:Int?,changesHandler:(()->())?){
        
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
                let popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            Int64(delayInSeconds * Double(NSEC_PER_SEC)))
                dispatch_after(popTime, dispatch_get_main_queue()) {
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
    private func runAddNewMessagesCompletion(AfterDelay delay:Double){
        let popTime = dispatch_time(DISPATCH_TIME_NOW,
                                    Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) {
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
    @available(*,deprecated,renamed="addOldMessages(quant:Int,changesHandler:()->())",message="This method is deprecated use addNewMessages(quant:Int,changesHandler:()->()) instead")
    public func addOldMessages(quant:Int){
        self.addOldMessages(quant, changesHandler: {})
    }
    
    /**
     Use it to add old messages inside chat tableView.
     
     ATTENTION: Do not call this method if you won't add messages.
     
     - parameter quant: the number of messages that will be added.
     - parameter changesHandler: A closure that should contain all insertions on your data structure of messages
     */
    public func addOldMessages(quant:Int,changesHandler:()->()){
        
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
    private func tryToAddOldMessages(quant:Int,changesHandler:()->()){
        
        
        
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
        
    
        var lastTopVisibleCellIndexPath:NSIndexPath?
        if let visibleIndexPaths = self.indexPathsForVisibleRows where visibleIndexPaths.count > 0{
            lastTopVisibleCellIndexPath = visibleIndexPaths[0]
        }
        
        
        self.reloadData()

        if let indexPath = lastTopVisibleCellIndexPath{
            let newSection = indexPath.section + (actualNumbOfSections - lastNumbOfSections)
            let newRow = indexPath.section > 0 ? indexPath.row : indexPath.row + (lastSectionZeroQuant - sectionZeroQuant)

            let lastTopCellNewIndexPath = NSIndexPath(forRow: newRow, inSection: newSection)

            self.scrollToRowAtIndexPath(lastTopCellNewIndexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        }
        //stop the activity because ended the load
        forceToFinishLoadingAnimation()
        
        runNextJob(2.0)
    }
    
    /**
     Use this method when some kind of error when trying to load old messages happend and you just want to stop the animation
    */
    public func forceToFinishLoadingAnimation(){
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
    public func updateMessageStatusOfCellAtIndexPath(indexPath:NSIndexPath,message:JLMessage){
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            if let cell = self.cellForRowAtIndexPath(indexPath) as? JLChatMessageCell{
                cell.updateMessageStatus(message)
            }
        }
    }
    
    
    /**
     Use this method to remove from 'ChatTableView' the message at indexPath
     - parameter indexPath: the indexPath of the message that you want to remove from 'ChatTableView'.
    */
    @available(*,deprecated,renamed="removeMessagesCellsAtIndexPaths(indexPaths:[NSIndexPath],relatedMessages:[JLMessage]!)",message="This method is deprecated use removeMessagesCellsAtIndexPaths instead")
    public func removeMessage(indexPath:NSIndexPath){
        let message:JLMessage? = self.chatDataSource!.jlChatMessageAtIndexPath(indexPath)
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            if let cell = self.cellForRowAtIndexPath(indexPath){
                cell.alpha = 0
            }
            
        }) { (finished) -> Void in
            if finished{
                if let message = message{
                    self.calculatedRowsHeight.removeValueForKey(message.hash)
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
    public func removeMessageCellAtIndexPath(indexPath:NSIndexPath,relatedMessage:JLMessage!){
        //self.calculatedRowsHeight.removeValueForKey(relatedMessage.hash)
        //self.beginUpdates()
        //self.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        //self.endUpdates()
        
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            if let cell = self.cellForRowAtIndexPath(indexPath){
                cell.alpha = 0
            }
            
        }) { (finished) -> Void in
            if finished{
                self.calculatedRowsHeight.removeValueForKey(relatedMessage.hash)
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
    public func removeChatSection(section:Int,messagesOfSection:[JLMessage]?){
        
        if let messages = messagesOfSection{
            for message in messages{
                self.calculatedRowsHeight.removeValueForKey(message.hash)
            }
        }
        else if self.numberOfRowsInSection(section) > 0{
            self.calculatedRowsHeight.removeAll()
        }
        
        if self.numberOfSections > self.dataSource!.numberOfSectionsInTableView!(self){
            self.beginUpdates()
            self.deleteSections(NSIndexSet(index: section), withRowAnimation: UITableViewRowAnimation.Fade)
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
    public func removeMessagesCells(rowsIndexPath:[NSIndexPath]?,AndSections sections:[Int]?,WithRelatedMessages relatedMessages:[JLMessage]?){
        if let messages = relatedMessages{
            for message in messages{
                self.calculatedRowsHeight.removeValueForKey(message.hash)
            }
        }
        else{
            self.calculatedRowsHeight.removeAll()
        }
        
        var indexPaths = [NSIndexPath]()
        var sectionsNumber = [Int]()
        if let rowsIndexs = rowsIndexPath{
            indexPaths = rowsIndexs
        }
        
        if let sec = sections{
            sectionsNumber = sec
        }
        
        self.beginUpdates()
        self.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        for i in sectionsNumber{
            self.deleteSections(NSIndexSet(index: i), withRowAnimation: UITableViewRowAnimation.Fade)
        }
        self.endUpdates()

    }
    
    
    
    private func frameMadeByRowsInRange(rowsRange:NSRange?,AndSection section:Int)->CGRect?{
        
        var initialRow = 0
        var totalRows = 0
        
        if let rowsRange = rowsRange{
            initialRow = rowsRange.location
            totalRows = rowsRange.length + rowsRange.location < self.numberOfRowsInSection(section) ? rowsRange.length + rowsRange.location : self.numberOfRowsInSection(section)
        }
        
        var totalHeight:CGFloat = 0
        var initialRowFrame:CGRect?
        for row in initialRow..<totalRows{
            if let cell = self.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: section)){
                if let _ = initialRowFrame{
                    
                }
                else{
                    initialRowFrame = cell.frame
                }
                totalHeight += cell.frame.height
            }
        }
        
        if totalRows == self.numberOfRowsInSection(section){
            if let header = self.headerViewForSection(section){
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
    private func moveChatItemsToCoverFrame(frame:CGRect!){
        
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
                if let sectionHeader = self.headerViewForSection(i){
                    sectionHeader.layer.delegate = self.layer
                    UIView.animateKeyframesWithDuration(0.25, delay: 0, options: UIViewKeyframeAnimationOptions.CalculationModeLinear, animations: {
                        
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
                if let sectionFooter = self.footerViewForSection(i){
                    sectionFooter.layer.delegate = self.layer
                    UIView.animateKeyframesWithDuration(0.25, delay: 0, options: UIViewKeyframeAnimationOptions.CalculationModeLinear, animations: {
                        
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
                    if let cell = self.cellForRowAtIndexPath(indexPath){
                        cell.layer.delegate = self.layer
                        UIView.animateKeyframesWithDuration(0.25, delay: 0, options: UIViewKeyframeAnimationOptions.CalculationModeLinear, animations: {
                            
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
    private func configMenuItemsOfCell(cell:JLChatMessageCell, ForRowAtIndexPath indexPath:NSIndexPath){
        if let delegate = self.messagesMenuDelegate {
            
            let deleteTitle = delegate.titleForDeleteMenuItem()
            let sendTitle = delegate.titleForSendMenuItem()
            
            cell.sendMenuEnabled = { () -> Bool in
                if let correctIndexPath = self.indexPathForCell(cell) where !self.isExecutingSomeOperation{
                    if let sendTitle = sendTitle{
                        return delegate.shouldShowMenuItemForCellAtIndexPath(sendTitle, indexPath: correctIndexPath)
                    }
                    return delegate.shouldShowMenuItemForCellAtIndexPath("Try Again", indexPath: correctIndexPath)
                }
                return false
                
            }
            
            cell.deleteMenuEnabled = { () -> Bool in
                if let correctIndexPath = self.indexPathForCell(cell) where !self.isExecutingSomeOperation{
                    if let deleteTitle = deleteTitle{
                        return delegate.shouldShowMenuItemForCellAtIndexPath(deleteTitle, indexPath: correctIndexPath)
                    }
                    return delegate.shouldShowMenuItemForCellAtIndexPath("Delete", indexPath: indexPath)
                }
                return false
            }
            
            
            
            cell.configMenu(deleteTitle, sendTitle: sendTitle, deleteBlock: { () -> () in
                if let correctIndexPath = self.indexPathForCell(cell){
                    delegate.performDeleteActionForCellAtIndexPath(correctIndexPath)
                }
                
                }, sendBlock: { () -> () in
                    if let correctIndexPath = self.indexPathForCell(cell){
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
    private func animateAdditionOfNewMessageCell(cell:JLChatMessageCell,AtIndexPath indexPath:NSIndexPath,completionHandler:()->()){
        let lastSectionNumber = self.numberOfSections - 1
        
        for number in (0..<quantOfNewMess).reverse(){
            //let index = newIndexPaths[number]
            let lastRowAtSection = self.numberOfRowsInSection(lastSectionNumber) - 1
            if indexPath.row == lastRowAtSection - number && indexPath.section == lastSectionNumber{//newer message
                //Animate it's  appearance
                cell.contentView.alpha = 0
                print("animando aparicao da menssagem \(indexPath.row)")
                let delayInSeconds = 0.4
                let popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            Int64(delayInSeconds * Double(NSEC_PER_SEC)))
                dispatch_after(popTime, dispatch_get_main_queue()) {
                    //print("animando no willDisplayCEll")
                    UIView.animateWithDuration(0.6, animations: {
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
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.scrollingToBottom = false
        
        //was scrolling to add a new message and its on bottom
        if scrollingToAddANewMessage && contentSize.height - self.contentOffset.y <= self.bounds.height{
            self.tryToAddNewMessagesNow(nil, changesHandler: nil)
        }
    }
    
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
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
    
    
    public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let lastSectionNumber = self.numberOfSections - 1
        if addingNewMessage && lastSectionNumber == section && self.numberOfRowsInSection(section) == 1{
            let delayInSeconds = 0.1
            view.alpha = 0
            let popTime = dispatch_time(DISPATCH_TIME_NOW,
                                        Int64(delayInSeconds * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                UIView.animateWithDuration(1, animations: {
                    view.alpha = 1
                })
            }

        }
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
  
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if let _ = chatDataSource{
            if let sectionKindFunc = self.chatDataSource!.jlChatKindOfHeaderViewInSection{
                if sectionKindFunc(section) != JLChatSectionHeaderViewKind.DefaultDateView{
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
    
    
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let _ = chatDataSource{
            
            if let sectionKindFunc = self.chatDataSource!.jlChatKindOfHeaderViewInSection{
                switch sectionKindFunc(section){
                case JLChatSectionHeaderViewKind.CustomView, JLChatSectionHeaderViewKind.CustomDateView:
                    if let customViewFunc = self.chatDataSource!.jlChatCustomHeaderInSection{
                        return customViewFunc(section)
                    }
                    else{
                        print("\n\n\n ERROR\n You are using custom date view , so implement the method jlChatCustomHeaderInSection of ChatDataSource")
                        abort()
                    }
                    
                //case JLChatSectionHeaderViewKind.DefaultDateView:
                default:
                    if let view = self.dequeueReusableHeaderFooterViewWithIdentifier("DateView") as? JLChatDateView{
                        if let firstMessageOfSection = self.chatDataSource!.jlChatMessageAtIndexPath(NSIndexPath(forRow: 0, inSection: section)){
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
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let message = self.chatDataSource!.jlChatMessageAtIndexPath(indexPath){
            if let value = calculatedRowsHeight[message.hash] where value != 0{
                return value
            }
        }
        return 60
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let message = self.chatDataSource!.jlChatMessageAtIndexPath(indexPath){
            if let value = calculatedRowsHeight[message.hash] where value != 0{
                print("calculated \(indexPath.row)")
                return value
            }
        }
        print("not calculated \(indexPath.row)")
        return UITableViewAutomaticDimension
    }
    
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.deselectRowAtIndexPath(indexPath, animated: true)
       
        self.chatDelegate?.didTapMessageAtIndexPath(indexPath)

    }
    
    
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
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
            if (indexPath.row == index.row && indexPath.section == index.section){
                firstUnreadMessageIndexPath = nil
            }
        }
        else if (indexPath.row == self.numberOfRowsInSection(lastSectionNumber) - 1 && indexPath.section == lastSectionNumber){
            self.enableFirstScrollToBottom = false
        }

        
        if let message = self.chatDataSource!.jlChatMessageAtIndexPath(indexPath){
            self.addHeightForCellAtIndexPath(message.hash, height:cellToReturn.frame.height)
        }
    }

    
    //MARK: -  Datasource

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if let function = self.chatDataSource!.numberOfDateAndCustomSectionsInJLChat{
            return function(self)
        }
        return 0

    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatDataSource!.jlChatNumberOfMessagesInSection(section)
    }
    
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.chatDataSource!.jlChat(self, MessageCellForRowAtIndexPath: indexPath)
        
        return cell
    }
    
    /**
    Call this method to make all basic configuration and creation of your message cell
    
    - parameter indexPath: The indexPath of the cell on chat tableView.
    - returns: The created message cell.
    */
    public func chatMessageForRowAtIndexPath(indexPath: NSIndexPath)->JLChatMessageCell{
        
        let lastSectionNumber = self.numberOfSections - 1
        
        let message = chatDataSource!.jlChatMessageAtIndexPath(indexPath)!
        
        //Check for unread messages when necessary
        checkForUnreadMessage(message, CurrentIndexPath: indexPath)
        //
        
        // configuration part
        let thisIsTheNewMessage:Bool = (addingNewMessage && indexPath.row == self.numberOfRowsInSection(lastSectionNumber) - 1 && indexPath.section == lastSectionNumber)
        
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
            if let customMess = self.chatDataSource!.chat{
                cellToReturn = customMess(self, CustomMessageCellForRowAtIndexPath: indexPath)
            }
            else{
                print("\n\n\n ERROR\n You have one or more messages with messageKind property equal to MessageKind.Custom, so implement the method chat(chat: JLChatTableView, CustomMessageCellForRowAtIndexPath indexPath: NSIndexPath) of ChatDataSource")
                
                abort()
            }
        }
        else{
            
            cellToReturn = self.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! JLChatMessageCell
            
            
        }
        
        
        cellToReturn.initCell(message, thisIsNewMessage:thisIsTheNewMessage,isOutgoingMessage: isOutgoingMessage)
        
        //scroll position organization part
        positionScrollProperly(UsingIndexPath: indexPath)

        return cellToReturn
    }
    
    
    @available(*, deprecated,renamed="chatMessageForRowAtIndexPath(indexPath: NSIndexPath)", message="This method is deprecated use `chatMessageForRowAtIndexPath(indexPath: NSIndexPath)` instead ")
    public func chatMessageForRowAtIndexPath(indexPath: NSIndexPath,message:JLMessage)->JLChatMessageCell{
        return chatMessageForRowAtIndexPath(indexPath)
    }
    
    //MARK: - Custom scroll positioning methods
    
    /**
     Position the scroll properly if there is unread message,'addingNewMessage' is TRUE or if 'enableFirstScrollToBottom' is TRUE
     
     ATTENTION: Do not call this method out of 'chatMessageForRowAtIndexPath' method
     
     - parameter indexPath: The indexPath of message that is being reloaded or added on 'chatMessageForRowAtIndexPath'
     */
    private func positionScrollProperly(UsingIndexPath indexPath:NSIndexPath){
        
        if let unReadMessindexPath = firstUnreadMessageIndexPath{
            let delayInSeconds = 0.01
            let popTime = dispatch_time(DISPATCH_TIME_NOW,
                                        Int64(delayInSeconds * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                self.scrollToRowAtIndexPath(unReadMessindexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
            }
        }
        else if addingNewMessage{
            
            let lastSectionNumber = self.numberOfSections - 1
            if indexPath.row >= self.numberOfRowsInSection(lastSectionNumber) - (1 + quantOfNewMess) && indexPath.section == lastSectionNumber{//newer message
                let delayInSeconds = 0.34
                let popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            Int64(delayInSeconds * Double(NSEC_PER_SEC)))
                dispatch_after(popTime, dispatch_get_main_queue()) {
                    self.scrollChatToBottom(true,basedOnLastRow: false)
                }
                
            }
            
        }
        else if enableFirstScrollToBottom{
            if let visibleIndexPaths = self.indexPathsForVisibleRows where visibleIndexPaths.count > 0{
                let delayInSeconds = 0.01
                let popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            Int64(delayInSeconds * Double(NSEC_PER_SEC)))
                dispatch_after(popTime, dispatch_get_main_queue()) {
                    self.scrollChatToBottom(false,basedOnLastRow: false)
                }
            }
        }
    }
    
    /**
     This method scroll chat to bottom.
     - parameter animated:True if you want to animate the scrolling and false if not.
     - parameter basedOnLastRow: A boolean that indicates to do the scroll using scrollToRowAtIndexPath or not use it for really big distances, pass nil on this parameter if you do not want to decide it
     */
    func scrollChatToBottom(animated:Bool,basedOnLastRow:Bool?){
        
        //when scrolling with animated false, it should not be changed to true because this kind of scroll only hanpen on configuration moment.
        scrollingToBottom = animated
        
        let chatContentheight = self.contentSize.height
        let lastSectionNumber = numberOfSections - 1
        if let basedOnLastRow = basedOnLastRow{
            if basedOnLastRow{
                print("to bottom with scrollToRow")
                let indexPath = NSIndexPath(forRow:self.numberOfRowsInSection(lastSectionNumber) - 1, inSection:lastSectionNumber)
                self.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
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
                let indexPath = NSIndexPath(forRow:self.numberOfRowsInSection(lastSectionNumber) - 1, inSection: lastSectionNumber)
                self.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
            }
            
        }
        
        //}
        
    }
    
    
    
    //MARK: - ToolBarFrameDelegate methods
    
    
    public func haveToUpdateInsetsBottom(bottom: CGFloat,scrollToBottom:Bool) {
        
        updateInsetsBottom(bottom,animated: false,duration: 0)
        
        if scrollToBottom{
            self.scrollChatToBottom(true,basedOnLastRow: nil)
        }
        
    }
    
    public func updateInsetsBottom(bottom:CGFloat,animated:Bool,duration:NSTimeInterval){
        
        let actualInsets = self.contentInset

        if animated{
            UIView.animateWithDuration(duration, animations: {
                self.contentInset = UIEdgeInsets(top: actualInsets.top, left: actualInsets.left, bottom: bottom, right: actualInsets.right)
                self.scrollIndicatorInsets = self.contentInset
                
            }) { (finished) in
                if finished{
                    let numberOfRows = self.numberOfSections
                    
                    if numberOfRows > 0 && self.contentSize.height - self.contentOffset.y <= self.bounds.size.height{//if there is rows and it`s on bottom
                        self.scrollChatToBottom(true,basedOnLastRow: nil)
                    }
                }
            }
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
