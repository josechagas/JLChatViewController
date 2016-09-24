//
//  MyViewController.swift
//  JLChatViewController
//
//  Created by José Lucas on 12/07/2015.
//  Copyright (c) 2015 José Lucas. All rights reserved.
//
//JLChatViewController/JLChatViewController_Example-Bridging-Header.h

import UIKit
import JLChatViewController

enum ID:String{//used only for the example
    case myID = "0"
    case otherID = "1"
}


class MyViewController:JLChatViewController,ChatDataSource,ChatToolBarDelegate,JLChatMessagesMenuDelegate,ChatDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    fileprivate var validMessID:Double = 0
    
    var nextValidMessID:Double{
        validMessID += 1
        return validMessID - 1
    }
        
    var messagesBySection:[[JLMessage]] = [[JLMessage]]()//newer messages are on last sections and on a section newer message is on last position
        
    var addedFile:AnyObject? // The file that was added ,for example an image

    /**
     This is a Custom picker controller used to get some file from gallery or from camera
     */
    var pickerController:CustomImagePickerController = CustomImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configPicker()
        loadMessages()
        configChat()
        loadTypingViewWithCustomView(nil, animationBlock: nil)
        configToolBar()
        addAnswerMeBarButton()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //used only for the example
    func loadMessages(){
        var id = ID.myID.rawValue
        
        for i in 0..<20{
            
            id = arc4random()%2 == 0 ? ID.myID.rawValue : ID.otherID.rawValue
            
            let newMessage:JLMessage
            if arc4random()%4 == 0{
                newMessage = JLImageMessage(identifier: nextValidMessID,senderID: id, messageDate: Date(), senderImage: id == ID.otherID.rawValue ?  UIImage(named: "imagem") : nil, relatedImage: UIImage(named: "imagem2"))
            }
            else{

                newMessage = JLTextMessage(identifier: nextValidMessID,text: "teste \(i)", senderID: id, messageDate: Date(), senderImage: id == ID.otherID.rawValue ?  UIImage(named: "imagem") : nil) as JLMessage
            }
            if i > 17{
                newMessage.messageRead = false
            }

            addOnMessagesBySectionNewMessage(newMessage)
        }
        
        let newMessage = JLTextMessage(identifier: nextValidMessID,text: "teste  sdas'dbfoasbdfbsdfasdkf;basd;fkbask;fbkdsfbksbfs;kdjfb;kasdbjfkasbdfk;asdbf;bsd;fkbsad;kbfsjkfb;absd;kfbas;dkfb;skdbf;asdfjabksdbfas;dfakdsbf;sdkfb;asjdkfb;skbfjkbs;dfk;asdjfskdfbjasf;sdjf;bskdbfa;djfdkf agora vai , so testando", senderID: id, messageDate: Date(), senderImage: id == ID.otherID.rawValue ?  UIImage(named: "imagem") : nil) as JLMessage
        newMessage.messageRead = false

        addOnMessagesBySectionNewMessage(newMessage)
    }
    
    //used only for the example
    func loadOldMessages(){
        
        self.chatTableView.addOldMessages(21) { 
            
            var id = ID.myID.rawValue
            
            var lastOlderDate:Date! = Date()
            if self.messagesBySection.count > 0{
                for section in self.messagesBySection{
                    if section.count > 0{
                        lastOlderDate = section[0].messageDate
                        break
                    }
                }
            }
            
            for i in 0..<20{
                
                id = arc4random()%2 == 0 ? ID.myID.rawValue : ID.otherID.rawValue
                
                let currentOldMessageDate = Date(timeIntervalSince1970: lastOlderDate.timeIntervalSince1970 - 0.01*3600)
                let oldMessage = JLTextMessage(identifier: self.nextValidMessID, text: "teste velhas\(i)", senderID: id, messageDate: currentOldMessageDate, senderImage: id == ID.otherID.rawValue ?  UIImage(named: "imagem") : nil) as JLMessage
                if i > 15{
                    lastOlderDate = Date(timeIntervalSince1970: currentOldMessageDate.timeIntervalSince1970 - 1*3600)

                }
                else{
                    lastOlderDate = Date(timeIntervalSince1970: currentOldMessageDate.timeIntervalSince1970 - 0.5*3600)
                }
                self.addOnMessagesBySectionOldMessage(oldMessage)
            }
            
            let oldMessage = JLTextMessage(identifier: self.nextValidMessID, text: "teste  sdas'dbfoasbdfbsdfasdkf;basd;fkbask;fbkdsfbksbfs;kdjfb;kasdbjfkasbdfk;asdbf;bsd;fkbsad;kbfsjkfb;absd;kfbas;dkfb;skdbf;asdfjabksdbfas;dfakdsbf;sdkfb;asjdkfb;skbfjkbs;dfk;asdjfskdfbjasf;sdjf;bskdbfa;djfdkf agora vai , so testando", senderID: id, messageDate: Date(timeIntervalSince1970: lastOlderDate.timeIntervalSince1970 - 3*3600), senderImage: id == ID.otherID.rawValue ?  UIImage(named: "imagem") : nil)
            
            self.addOnMessagesBySectionOldMessage(oldMessage)
            
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Simulating receiving message methods
    
    func addAnswerMeBarButton(){
        let button = UIBarButtonItem(title: "answer me", style: UIBarButtonItemStyle.plain, target: self, action:#selector(MyViewController.answerMeAction(_:)))
        
        self.navigationItem.rightBarButtonItem = button
    }
    
    func sortOtherUserNewMessage()->[IndexPath]{
        var indexPaths:[IndexPath] = [IndexPath]()
        
        let sort = arc4random()%6
        
        var newerDate:Date! = Date()
        
        if self.messagesBySection.count > 0{
            if self.messagesBySection.last!.count > 0{
                newerDate = self.messagesBySection.last!.last!.messageDate
            }
        }
        
        if sort == 0{//text message
            let text = "This is a small message"

            let date = Date(timeIntervalSince1970: newerDate.timeIntervalSince1970 + 3*3600)
            indexPaths.append( self.addOnMessagesBySectionNewMessage(JLTextMessage(identifier: nextValidMessID, text: text, senderID: ID.otherID.rawValue,messageDate: date, senderImage: UIImage(named: "imagem"))))
            
        }
        else if sort == 1{//text message
            let text = "This is a message a little bigger! ;)"
            
            let date = Date(timeIntervalSince1970: newerDate.timeIntervalSince1970 + 3*3600)
            indexPaths.append( self.addOnMessagesBySectionNewMessage(JLTextMessage(identifier: nextValidMessID, text: text, senderID: ID.otherID.rawValue,messageDate: date, senderImage: UIImage(named: "imagem"))) )
        }
        else if sort == 2{//text message
            let text = "Hey This is JLChatViewController, a pods made to help everybody to be faster when developing some app with a nice chat, with many resources to customize, like color, form of bubbles, font, custom sections and an easy way for you to create your own messages cells I hope it will really help you."
            
            let date = Date(timeIntervalSince1970: newerDate.timeIntervalSince1970 + 3*3600)
            indexPaths.append( self.addOnMessagesBySectionNewMessage(JLTextMessage(identifier: nextValidMessID, text: text, senderID: ID.otherID.rawValue,messageDate: date, senderImage: UIImage(named: "imagem"))) )
        }
        else if sort == 3{//Product message
            let date = Date(timeIntervalSince1970: newerDate.timeIntervalSince1970 + 0.2*3600)
            
           indexPaths.append( self.addOnMessagesBySectionNewMessage(ProductMessage(identifier: nextValidMessID, senderID: ID.otherID.rawValue, messageDate: date, senderImage: UIImage(named: "imagem"), text: "Produto", relatedImage: UIImage(named: "imagem")!, productPrice: nil)))
            
        }
        else if sort == 4{//text message
            let date = Date(timeIntervalSince1970: newerDate.timeIntervalSince1970 + 1*3600)
            
            
            indexPaths.append( self.addOnMessagesBySectionNewMessage(JLTextMessage(identifier: nextValidMessID, text: "a", senderID: ID.otherID.rawValue,messageDate: date, senderImage: UIImage(named: "imagem"))))
            
        }
        else{//Image message
            let date = Date(timeIntervalSince1970: newerDate.timeIntervalSince1970 + 0.1*3600)
            
            let newerMessage = JLImageMessage(identifier: nextValidMessID, senderID: ID.otherID.rawValue, messageDate: date, senderImage: UIImage(named: "imagem"), relatedImage: nil)
            
            let index = addOnMessagesBySectionNewMessage(newerMessage)

            indexPaths.append(index)
        }
        
        return indexPaths
    }
    
    func answerMeAction(_ sender:AnyObject){
        self.showUserTypingView()
        let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
       
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.hideUserTypingView { () -> () in
                
                //let indexPaths = self.sortOtherUserNewMessage()
                
                self.chatTableView.addNewMessages(1, changesHandler: { 
                    self.sortOtherUserNewMessage()
                    }, completionHandler: { 
                        if let section = self.removeUnreadHeaderIfNecessary(){
                            self.chatTableView.removeChatSection(section,messagesOfSection: [])
                        }
                })
            }
        }
        
       
        
        
    }
    
    //MARK: - Chat messages by section methods
    /*
     This MARK have methods that will help you to work with your messages separating them by sections based on messages date, adding new and or old messages , removing messages
     */
    
    
    /**
     Return the number of messages by section on 'messagesBySection'
    */
    func numberOfMessagesRelatedToSection(_ section:Int)->Int{
        
        if self.messagesBySection.count > section{
            return self.messagesBySection[section].count
        }
        return 0
        
    }
    
    /**
     Return the message at indexPath
    */
    func messageRelatedToIndexPath(_ indexPath:IndexPath)->JLMessage?{
        if messagesBySection.count <= (indexPath as NSIndexPath).section || messagesBySection[(indexPath as NSIndexPath).section].count <= (indexPath as NSIndexPath).row{
            return nil
        }
        return messagesBySection[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
    }
    
    /**
     Changes the state of unread messages to read
     */
    func markMessagesAsRead(){
        if messagesBySection.last!.count > 0 {
            let lastPos = messagesBySection.last!.count - 1
            if lastPos > 0{
                if messagesBySection.last![lastPos - 1].messageRead == false  && messagesBySection.last!.last!.messageRead == true{
                    for section in (0..<messagesBySection.count).reversed(){
                        messagesBySection[section].forEach({ (message) in
                            message.messageRead = true
                        })
                    }
                }
            }
            else if messagesBySection.last!.last!.messageRead == true{
                for section in (0..<messagesBySection.count).reversed(){
                    messagesBySection[section].forEach({ (message) in
                        message.messageRead = true
                    })
                }
            }
            
        }
        
    }
    /**
     Returns the number of unread messages on chat
     */
    func numberOfUnreadMessages()->Int{
        var quant = 0
        if messagesBySection.last!.count > 0 && messagesBySection.last!.last!.messageRead == false{
            for section in (0..<messagesBySection.count).reversed(){
                if self.messagesBySection[section].count == 0{
                    break
                }
                else{
                    messagesBySection[section].forEach({ (message) in
                        if message.messageRead == false{
                            quant += 1
                        }
                        else{
                            return
                        }
                    })
                }
            }
            
        }
        return quant
    }
    
    /**
     Remove the message at indexPath from 'messagesBySection'
    */
    func removeMessageRelatedToIndexPath(_ indexPath:IndexPath){

        if self.messagesBySection[(indexPath as NSIndexPath).section].count == 1{
            var relatedMessages = [JLMessage]()
            relatedMessages.append(self.messagesBySection[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row])
            
            self.messagesBySection.remove(at: (indexPath as NSIndexPath).section)
            
            if let section = removeUnreadHeaderIfNecessary(){
                self.chatTableView.removeMessagesCells(nil, AndSections: [(indexPath as NSIndexPath).section,section],WithRelatedMessages: relatedMessages)
            }
            else{
                self.chatTableView.removeChatSection((indexPath as NSIndexPath).section,messagesOfSection: relatedMessages)
            }
        }
        else{
            let message = self.messagesBySection[(indexPath as NSIndexPath).section].remove(at: (indexPath as NSIndexPath).row)
            self.chatTableView.removeMessageCellAtIndexPath(indexPath, relatedMessage: message)
        }

    }
    
    
    /**
     This method adds a new message on 'messagesBySection' variable at the end of the newer section
     - returns : IndexPath of new message
     */
    func addOnMessagesBySectionNewMessage(_ newMessage:JLMessage)->IndexPath{
        
        var addedUnreadHeader:Bool = false
        
        if newMessage.messageRead == false{
            if let _ = addUnreadHeaderIfNecessary(){
                addedUnreadHeader = true
            }
        }
       
        if addedUnreadHeader{//adds on other section because the section of unread messages does not have messages it is like a divider
            messagesBySection.append([newMessage])//creates and add on section
        }
        else if messagesBySection.count > 0{
            var lastSection = messagesBySection.last!
            if lastSection.count == 0{//its a unread section
                lastSection = messagesBySection[messagesBySection.count - 2]
            }
            
            let olderMessageDate = lastSection.last!.messageDate.timeIntervalSince1970/3600.0
            let newerMessageDate = newMessage.messageDate.timeIntervalSince1970/3600.0
            /**
             This is the time diference necessary to create a new date section
             change it as you prefer, normally other chats use a bigger value
              
             OBS: a value too small might cause problems with performance
             */
            if newerMessageDate - olderMessageDate <= 2.0/*hours*/{
                messagesBySection[messagesBySection.count - 1].append(newMessage)
                
                return IndexPath(row: messagesBySection.last!.count - 1, section: messagesBySection.count - 1)
            }
            else{//belongs to new section
                messagesBySection.append([newMessage])//creates and add on section
            }
        }
        else{
            messagesBySection.append([newMessage])//creates and add on section
        }
        
        return IndexPath(row: 0, section: messagesBySection.count - 1)

    }
    
    /**
     This method adds an old message on 'messagesBySection' variable at the begining of older section
     */
    func addOnMessagesBySectionOldMessage(_ oldMessage:JLMessage)->IndexPath{
        if messagesBySection.count > 0{
            
            let olderMessageDate = oldMessage.messageDate.timeIntervalSince1970/3600.0
            
            var newerMessageDate:Double = 0
            //search for the older addeed message that is newer than 'oldMessage'
            for section in messagesBySection{
                if section.count > 0{
                    newerMessageDate = section[0].messageDate.timeIntervalSince1970/3600.0
                    break
                }
            }
            /**
             This is the time diference necessary to create a new date section
             change it as you prefer, normally other chats use a bigger value
             
             OBS: a value too small might cause problems with performance
             */
            if newerMessageDate - olderMessageDate <= 2.0/*hours*/{
                messagesBySection[0].insert(oldMessage, at: 0)
            }
            else{//belongs to new section
                messagesBySection.insert([oldMessage], at: 0)//creates and add on section
            }
            
        }
        else{
            messagesBySection.append([oldMessage])//creates and add on section
        }
        return IndexPath(row: 0, section: 0)

    }

    
    func isThereUnreadSection()->Bool{
        for messages in messagesBySection.reversed(){
            if messages.count == 0{
                return true
            }
        }
        return false
    }
    
    /**
     Add an unread section on 'messagesBySection' if necessary
     - returns: equal nil if did not added the section or not equal to nil if added now and its value if the number of the unread section
     */
    func addUnreadHeaderIfNecessary()->Int?{
        if !isThereUnreadSection(){
            messagesBySection.append([])
            return messagesBySection.count - 1
        }
        return nil
    }
    
    /**
     Removes if necessary the uread section and returns the number of the section if it was removed
     */
    func removeUnreadHeaderIfNecessary()->Int?{
        
        if let lastSection = self.messagesBySection.last{
            if lastSection.count == 0{//unread message
                let section = self.messagesBySection.count - 1
                self.messagesBySection.removeLast()
                return section
            }
            else{
                if lastSection.last!.messageRead == true{//if the last one is true so there is not unread messages
                    //search and remove the unread header view
                    for i in (0..<self.messagesBySection.count - 1).reversed(){
                        if self.messagesBySection[i].count == 0{
                            self.messagesBySection.remove(at: i)
                            return i
                        }
                    }
                }
            }
        }
        return nil
        
    }

    
    //MARK: - ChatTableView methods
    
    func configChat(){
        
        registerCustomCells()
        
        self.chatTableView.chatDataSource = self
        self.chatTableView.messagesMenuDelegate = self
        self.chatTableView.chatDelegate = self
        
        self.chatTableView.myID = ID.myID.rawValue
                
        
        /**
         To see chat with deferent appearance uncoment another config
         */
        
        
        configDefault()
        //bubbleConfigOne()
        //bubbleConfigTwo()
        //bubbleConfigThree()
        
    }
    func configDefault(){
        //2-start
        JLChatAppearence.configIncomingMessages(nil, showIncomingSenderImage: true, incomingTextColor: nil)
        
        JLChatAppearence.configOutgoingMessages(nil, showOutgoingSenderImage: true, outgoingTextColor: nil)
        //2-end
        
        JLChatAppearence.configErrorButton(nil, selectedStateImage: nil)
    }
    
    func bubbleConfigOne(){
        //2-start
        JLChatAppearence.configIncomingMessages(UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1), showIncomingSenderImage: true, incomingTextColor: UIColor.white)
        
        JLChatAppearence.configOutgoingMessages(UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1), showOutgoingSenderImage: false, outgoingTextColor: UIColor.white)
        //2-end
        
        JLChatAppearence.configSenderImage(nil, senderImageCornerRadius: nil, senderImageBackgroundColor: nil, senderImageDefaultImage: UIImage(named: "userImage(By Madebyoliver)"))
        
        JLChatAppearence.configChatFont(UIFont(name: "Futura", size: 16)!)
        
        JLChatAppearence.configErrorButton(nil, selectedStateImage: nil)
    }
    
    func bubbleConfigTwo(){
        //Custom 1-start
        JLChatAppearence.configIncomingMessages(WithCustomBubbleImage: UIImage(named: "custom-incomingBubble"), customBubbleInsets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14), bubbleImageMask: UIImage(named: "custom-incomingBubbleMask"), bubbleMaskInsets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14), incomingBubbleColor: UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1), showIncomingSenderImage: true, incomingTextColor: UIColor.white)
        
        JLChatAppearence.configOutgoingMessages(WithCustomBubbleImage: UIImage(named: "custom-outgoingBubble"), customBubbleInsets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14), bubbleImageMask: UIImage(named: "custom-outgoingBubbleMask"), bubbleMaskInsets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14), outgoingBubbleColor: nil, showOutgoingSenderImage: false, outgoingTextColor: nil)
        
        JLChatAppearence.configAligment(5, vertivalDistBetweenImgBottom_And_BubbleBottom: 10)
        
        
        JLChatAppearence.configErrorButton(nil, selectedStateImage: nil)

    }
    
    func bubbleConfigThree(){
        //Custom 2-start
        JLChatAppearence.configIncomingMessages(WithCustomBubbleImage: UIImage(named: "custom-incomingBubble_2"), customBubbleInsets: UIEdgeInsets(top: 3, left: 7, bottom: 10, right: 3), bubbleImageMask: UIImage(named: "custom-incomingBubbleMask_2"), bubbleMaskInsets: UIEdgeInsets(top: 3, left: 7, bottom: 10, right: 3), incomingBubbleColor: nil, showIncomingSenderImage: false, incomingTextColor: nil)
        
        JLChatAppearence.configOutgoingMessages(WithCustomBubbleImage: UIImage(named: "custom-outgoingBubble_2"), customBubbleInsets: UIEdgeInsets(top: 3, left: 3, bottom: 10, right: 7), bubbleImageMask: UIImage(named: "custom-outgoingBubbleMask_2"), bubbleMaskInsets: UIEdgeInsets(top: 3, left: 3, bottom: 10, right: 7), outgoingBubbleColor: nil, showOutgoingSenderImage: false, outgoingTextColor: nil)
        
        JLChatAppearence.configAligment(5, vertivalDistBetweenImgBottom_And_BubbleBottom: 10)
        
        JLChatAppearence.configTextAlignmentOnBubble(IncomingMessTextAlig: UIEdgeInsets(top: 8, left: 10, bottom: 13, right: 8), AndOutgoingMessTextAlig: UIEdgeInsets(top: 8, left: 8, bottom: 13, right: 10))
        //Custom 2-end
        
        JLChatAppearence.configErrorButton(nil, selectedStateImage: nil)

    }
    
    
    func registerCustomCells(){
        
        self.chatTableView.register(UINib(nibName: "OutgoingProductMessageCell", bundle: Bundle.main), forCellReuseIdentifier: "outgoingProductCell")
        
        self.chatTableView.register(UINib(nibName: "IncomingProductMessageCell", bundle: Bundle.main), forCellReuseIdentifier: "incomingProductCell")

        self.chatTableView.register(UINib(nibName: "CustomChatDateView", bundle:Bundle.main), forHeaderFooterViewReuseIdentifier: "CustomDateView")
        
        self.chatTableView.register(UINib(nibName: "UnreadMessHeaderView", bundle:Bundle.main), forHeaderFooterViewReuseIdentifier: "UnreadView")

    }
  


    
    //MARK: ChatDataSource
    
    func numberOfDateAndCustomSectionsInJLChat(_ chat: JLChatTableView) -> Int {
        return messagesBySection.count
    }
    
    func jlChatKindOfHeaderViewInSection(_ section: Int) -> JLChatSectionHeaderViewKind {
        //you can change it to see the diference
        if  self.messagesBySection[section].count == 0{
            return JLChatSectionHeaderViewKind.customView
        }

        //return JLChatSectionHeaderViewKind.CustomDateView
        return JLChatSectionHeaderViewKind.defaultDateView
    }
    
    func jlChatNumberOfMessagesInSection(_ section: Int) -> Int {
        return numberOfMessagesRelatedToSection(section)
    }
    
    func jlChatMessageAtIndexPath(_ indexPath: IndexPath) -> JLMessage? {
        return messageRelatedToIndexPath(indexPath)
    }
    
    func jlChat(_ chat: JLChatTableView, MessageCellForRowAtIndexPath indexPath: IndexPath) -> JLChatMessageCell {
        
        let mess = chatTableView.chatMessageForRowAtIndexPath(indexPath)
        
        if mess is JLImageMessageCell{
            if let message = messageRelatedToIndexPath(indexPath) as? JLImageMessage , message.senderID == ID.otherID.rawValue{
                //Its here just to simulate the interval of loading the image
                let delayTime = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    
                    let imageMess = mess as! JLImageMessageCell
                    
                    imageMess.addImage(UIImage(named: "imagem2")!)
                    
                    message.relatedImage = UIImage(named: "imagem2")!
                    
                }
            }
        }
        
        /* this is here for testing error to send
        if self.chatTableView.numberOfSections - 1 == indexPath.section{
            let delayTime2 = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
            
            dispatch_after(delayTime2, dispatch_get_main_queue()) {
                let message = self.messageRelatedToIndexPath(indexPath)!
            
                message.updateMessageSendStatus(MessageSendStatus.ErrorToSend)
                self.chatTableView.updateMessageStatusOfCellAtIndexPath(indexPath, message: message)
            }
        }
 
        */
        self.markMessagesAsRead()
        
        return mess

    }
    
    
    func chat(_ chat: JLChatTableView, CustomMessageCellForRowAtIndexPath indexPath: IndexPath) -> JLChatMessageCell {
        
        let message = self.messageRelatedToIndexPath(indexPath)!
        
        var cell:JLChatMessageCell!
        if message.senderID == self.chatTableView.myID{
            cell = self.chatTableView.dequeueReusableCell(withIdentifier: "outgoingProductCell") as! ProductMessageCell
        }
        else{
            cell = self.chatTableView.dequeueReusableCell(withIdentifier: "incomingProductCell") as! ProductMessageCell
            
        }
        
        return cell
        
    }
    
    func titleForJLChatLoadingView() -> String {
        return "JLChatViewController-Messages"
    }
    
    
    //MARK: Custom header View methods optional methods

    func jlChatCustomHeaderInSection(_ section: Int) -> UIView? {
        
        if numberOfMessagesRelatedToSection(section) == 0{//unread header view
            if let view = self.chatTableView.dequeueReusableHeaderFooterView(withIdentifier: "UnreadView") as? UnreadMessHeaderView{
                let quant = numberOfUnreadMessages()
                if quant > 0{
                    view.numberOfMessLabel.text = "\(quant) unread \(quant > 1 ? "messages": "message")"
                }
                
                return view
            }
            else{
                return nil
            }
        }
        else{
            if let view = self.chatTableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomDateView") as? CustomChatDateView{
                view.dateLabel.text = nil
                if let firstMessageOfSection = self.messageRelatedToIndexPath(IndexPath(row: 0, section: section)){
                    view.dateLabel.text = firstMessageOfSection.generateStringFromDate()

                }
                
                
                return view
            }
            else{
                return nil
            }
        }
        
    }
    
    func jlChatHeightForCustomHeaderInSection(_ section: Int) -> CGFloat {
        if self.numberOfMessagesRelatedToSection(section) == 0{//unread section
            return 25
        }
        return 21
    }
    
    //MARK: ChatDelegate
    
    
    func loadOlderMessages() {
        
        let delayTime = DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
       
            self.loadOldMessages()
            
        }
        
    }
    
  
    func didTapMessageAtIndexPath(_ indexPath: IndexPath) {
        print("tocou na mensagem")
        
    }
    
    //MARK: - Messages menu delegate methods
    
    func shouldShowMenuItemForCellAtIndexPath(_ title: String, indexPath: IndexPath) -> Bool {
        
        if title == "Deletar"{
            return true
        }
        
        else if title == "Enviar novamente"{

            if let message = self.messageRelatedToIndexPath(indexPath){
                if message.messageStatus == MessageSendStatus.errorToSend{
                    return true
                }
            }
        }
        return false
    }
    
    func titleForDeleteMenuItem() -> String? {
        return "Deletar"
    }
    
    func titleForSendMenuItem() -> String? {
        return "Enviar novamente"
    }
    
    func performDeleteActionForCellAtIndexPath(_ indexPath: IndexPath) {
        self.removeMessageRelatedToIndexPath(indexPath)

    }
    
    func performSendActionForCellAtIndexPath(_ indexPath: IndexPath) {
        
        let message =  self.messageRelatedToIndexPath(indexPath)!
        
        message.updateMessageSendStatus(MessageSendStatus.sent)

        self.chatTableView.updateMessageStatusOfCellAtIndexPath(indexPath, message: message)
    }
    
    //MARK: - ChatToolBar methods
    
    func configToolBar(){
        toolBar.configToolInputText(UIFont(name: "Helvetica", size: 16)!, textColor: UIColor.black, placeHolder: "Mensagem")
        
        toolBar.toolBarDelegate = self
        
        toolBar.toolBarFrameDelegate = self.chatTableView
        
        toolBar.configLeftButton(nil, image: UIImage(named: "paperclip-icon"))
        toolBar.configRightButton("send", image:nil)

        
    }
    
    func didTapLeftButton() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let galleryButton = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default) { (action) in
            //se ainda nao tiver um arquivo adicionado adiciona um
            self.pickerController.getImageFromGallery(self, allowsEditing: true)
        }
        
        let cameraButton = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) { (action) in
            //se ainda nao tiver um arquivo adicionado adiciona um
            self.pickerController.getImageFromCamera(self, captureMode: UIImagePickerControllerCameraCaptureMode.photo, allowsEditing: true)
        }

        
        let productFileButton = UIAlertAction(title: "Product", style: UIAlertActionStyle.default) { (action) in
            //se ainda nao tiver um arquivo adicionado adiciona um
            
            self.addedFile = ProductMessage(identifier: self.nextValidMessID, senderID: self.chatTableView.myID, messageDate: Date(), senderImage: UIImage(named: "imagem"), text: "What a good makeup!!!", relatedImage: UIImage(named: "imagem")!, productPrice: nil)
            
            self.toolBar.inputText.addFile(JLFile(title: "Product", image: UIImage(named: "imagem")))

        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel,handler: nil)
        
        alertController.addAction(galleryButton)
        alertController.addAction(cameraButton)
        alertController.addAction(productFileButton)
        alertController.addAction(cancel)

        self.present(alertController, animated: true, completion: nil)

    }
    
 
    
    func didTapRightButton() {
        var newMessages:[JLMessage] = [JLMessage]()
        var quant:Int = 0
        //ver se existe algum arquivo adicionado e se tiver envia
        if self.toolBar.thereIsSomeFileAdded(),let addedFile = self.addedFile{
            
            if addedFile is UIImage{
                let newMessage = JLImageMessage(identifier: nextValidMessID, senderID: self.chatTableView.myID,messageDate:Date(), senderImage: nil, relatedImage: addedFile as? UIImage)
                newMessages.append(newMessage)
                quant += 1

            }
            else if addedFile is ProductMessage{
                let prodMessage = addedFile as! ProductMessage
                newMessages.append(prodMessage)
                quant += 1

            }
            
            self.addedFile = nil
            
        }
        
        if self.toolBar.inputText.thereIsSomeText(){
            let message = JLTextMessage(identifier: nextValidMessID, text: self.toolBar.inputText.text, senderID: self.chatTableView.myID,messageDate:Date(), senderImage: nil)
            newMessages.append(message)

            quant += 1
            
        }
        
        self.chatTableView.addNewMessages(quant, changesHandler: {
            for message in newMessages{
                self.addOnMessagesBySectionNewMessage(message)
            }
            }, completionHandler: {
                if let section = self.removeUnreadHeaderIfNecessary(){
                    self.chatTableView.removeChatSection(section,messagesOfSection: [])
                }
        })
        
    }
    
    //MARK: - PickerImage methods
    
    func configPicker(){
        self.pickerController = CustomImagePickerController()
        self.pickerController.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [String : Any]){
        
        self.addedFile = pickerController.getEditedSelectedImageFrom(info)
        
        picker.dismiss(animated: true, completion: nil)
        
        self.toolBar.inputText.addFile(JLFile(title: "Image", image: (addedFile as! UIImage)))
        
        
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}

