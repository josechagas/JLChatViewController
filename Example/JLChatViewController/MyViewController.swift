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


class MyViewController: JLChatViewController,ChatDataSource,ChatToolBarDelegate,JLChatMessagesMenuDelegate,ChatDelegate {

    
   
    var messages:[JLMessage] = [JLMessage]()
    
    var addedFile:AnyObject? // o arquivo que foi adicionado , como uma imagem

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMessages()
        configChat()
        configToolBar()
        
        addAnswerMeBarButton()
        

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func loadMessages(){
        
        for i in 0..<19{
            
            let newMessage = JLMessage(text: "teste \(i)", senderID: ID.myID.rawValue, messageDate: NSDate(), senderImage: UIImage(named: "imagem"))
            
            self.messages.insert(newMessage, atIndex: 0)
        }
        
        let newMessage = JLMessage(text: "teste  sdas'dbfoasbdfbsdfasdkf;basd;fkbask;fbkdsfbksbfs;kdjfb;kasdbjfkasbdfk;asdbf;bsd;fkbsad;kbfsjkfb;absd;kfbas;dkfb;skdbf;asdfjabksdbfas;dfakdsbf;sdkfb;asjdkfb;skbfjkbs;dfk;asdjfskdfbjasf;sdjf;bskdbfa;djfdkf", senderID: ID.myID.rawValue, messageDate: NSDate(), senderImage: UIImage(named: "imagem"))
        
        self.messages.insert(newMessage, atIndex: 0)
        
        
        let newerMessage = JLMessage(senderID: ID.myID.rawValue, messageDate: NSDate(), senderImage: UIImage(named: "imagem"), relatedImage: nil)
        
        self.messages.insert(newerMessage, atIndex: 0)
    }
    
    func loadOldMessages(){
        
        
        for i in 0..<20{
            
            let newMessage = JLMessage(text: "teste velhas\(i)", senderID: ID.myID.rawValue, messageDate: NSDate(), senderImage: UIImage(named: "imagem"))
            
            self.messages.append(newMessage)
        }
        
        let newMessage = JLMessage(text: "teste  sdas'dbfoasbdfbsdfasdkf;basd;fkbask;fbkdsfbksbfs;kdjfb;kasdbjfkasbdfk;asdbf;bsd;fkbsad;kbfsjkfb;absd;kfbas;dkfb;skdbf;asdfjabksdbfas;dfakdsbf;sdkfb;asjdkfb;skbfjkbs;dfk;asdjfskdfbjasf;sdjf;bskdbfa;djfdkf", senderID: ID.myID.rawValue, messageDate: NSDate(), senderImage: UIImage(named: "imagem"))
        
        self.messages.append(newMessage)

        
        self.chatTableView.addOldMessages(20)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Simulating receiving message methods
    
    func addAnswerMeBarButton(){
        let button = UIBarButtonItem(title: "answer me", style: UIBarButtonItemStyle.Plain, target: self, action: "answerMeAction:")
        
        self.navigationItem.rightBarButtonItem = button
    }
    
    func answerMeAction(sender:AnyObject){
        let text = "asdas sadas eee f fs fsf4 af aeee vamos la carai"
        
        let sort = arc4random()%3
        
        if sort == 0{
            self.messages.insert(JLMessage(text: text, senderID: ID.otherID.rawValue,messageDate: NSDate(), senderImage: nil) , atIndex: 0)
            
        }
        else if sort == 1{
            self.messages.insert(ProductMessage(senderID: ID.otherID.rawValue, messageDate: NSDate(), senderImage: UIImage(named: "imagem"), text: "Produto", relatedImage: UIImage(named: "imagem")!, productPrice: nil), atIndex: 0)
        }
        else{
            self.messages.insert(JLMessage(senderID: ID.otherID.rawValue,messageDate: NSDate(), senderImage:UIImage(named: "imagem")!, relatedImage: nil), atIndex: 0)
            
        }
        
        
        self.chatTableView.addNewMessage()
        
    }

    
    //MARK: - ChatTableView methods
    
    func configChat(){
        
        registerCustomCells()
        
        self.chatTableView.chatDataSource = self
        self.chatTableView.messagesMenuDelegate = self
        self.chatTableView.chatDelegate = self
        
        self.chatTableView.myID = ID.myID.rawValue
                
        JLChatAppearence.configIncomingMessages(nil, showIncomingSenderImage: true, incomingTextColor: nil)
        
        JLChatAppearence.configOutgoingMessages(nil, showOutgoingSenderImage: true, outgoingTextColor: nil)
        
        
        JLChatAppearence.configChatFont(nil) { (indexPath) -> Bool in
            
            if indexPath.row % 3 == 0{
                return true
            }
            return false
        }
        
        
    }
    
    func registerCustomCells(){
        
        self.chatTableView.registerNib(UINib(nibName: "OutgoingProductMessageCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "outgoingProductCell")
        
        self.chatTableView.registerNib(UINib(nibName: "IncomingProductMessageCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "incomingProductCell")

        
    }
    //MARK: ChatDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let correctPosition = self.messages.count - 1 - indexPath.row
        
        let message = self.messages[correctPosition]
        
        let mess = chatTableView.chatMessageForRowAtIndexPath(indexPath, message: message)

        if mess is JLImageMessageCell{
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                
                let imageMess = mess as! JLImageMessageCell
                
                imageMess.addImage(UIImage(named: "imagem")!)
                
                //imageMess.messageImageView.image = UIImage(named: "imagem")!
                
                message.relatedImage = UIImage(named: "imagem")!
            
            }
        }
        
        return mess
    
    }
    
    
    func chat(chat: JLChatTableView, customMessageCellForRowAtIndexPath indexPath: NSIndexPath) -> JLChatMessageCell {
        
        let correctPosition = self.messages.count - 1 - indexPath.row

        let message = self.messages[correctPosition]
        
        var cell:JLChatMessageCell!
        if message.senderID == self.chatTableView.myID{
            cell = self.chatTableView.dequeueReusableCellWithIdentifier("outgoingProductCell") as! ProductMessageCell
        }
        else{
            cell = self.chatTableView.dequeueReusableCellWithIdentifier("incomingProductCell") as! ProductMessageCell

        }
        
        
        return cell
        
    }
    
    func titleforChatLoadingHeaderView() -> String? {
        return "JLChatViewController"
    }
    
    //MARK: ChatDelegate
    
    
    func loadOlderMessages() {
        

        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
       
            self.loadOldMessages()
            
        }
        
        
    }
    
  
    func didTapMessageAtIndexPath(indexPath: NSIndexPath) {
        print("tocou na mensagem")
    }
    
    //MARK: - Messages menu delegate methods
    
    func shouldShowMenuItemForCellAtIndexPath(title: String, indexPath: NSIndexPath) -> Bool {
        
        if title == "Deletar"{
            return true
        }
        
        else if title == "Enviar novamente"{
            let correctPosition = self.messages.count - 1 - indexPath.row
            let message = self.messages[correctPosition]
            
            if message.messageStatus == MessageSendStatus.ErrorToSend{
                return true
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
    
    func performDeleteActionForCellAtIndexPath(indexPath: NSIndexPath) {
        
        
        let correctPosition = self.messages.count - 1 - indexPath.row
        self.messages.removeAtIndex(correctPosition)
        self.chatTableView.removeMessage(indexPath)

    }
    
    func performSendActionForCellAtIndexPath(indexPath: NSIndexPath) {
        
        let correctPosition = self.messages.count - 1 - indexPath.row

        self.messages[correctPosition].updateMessageSendStatus(MessageSendStatus.Sent)
        self.chatTableView.updateMessageStatusOfCellAtIndexPath(indexPath, message: self.messages[correctPosition])
        
    }
    
    //MARK: - ChatToolBar methods
    
    func configToolBar(){
        toolBar.configToolInputText(UIFont(name: "Helvetica", size: 16)!, textColor: UIColor.blackColor(), placeHolder: "Mensagem")
        
        toolBar.toolBarDelegate = self
        
        toolBar.toolBarFrameDelegate = self.chatTableView
        
    }
    
    func didTapLeftButton() {
        
        //se ainda nao tiver um arquivo adicionado adiciona um
                
        self.addedFile = ProductMessage(senderID: self.chatTableView.myID, messageDate: NSDate(), senderImage: UIImage(named: "imagem"), text: "belo batom rosa!!!", relatedImage: UIImage(named: "imagem")!, productPrice: nil)
        
        self.toolBar.inputText.addFile(JLFile(title: "Produto", image: UIImage(named: "imagem")))
        
    }
    
    func didTapRightButton() {
        
        //ver se existe algum arquivo adicionado e se tiver envia
        if self.toolBar.thereIsSomeFileAdded(),let addedFile = addedFile{
            
            if addedFile is UIImage{
                self.messages.insert(JLMessage(senderID: self.chatTableView.myID,messageDate:NSDate(), senderImage: UIImage(named: "imagem"), relatedImage: addedFile as? UIImage), atIndex: 0)

            }
            else if addedFile is ProductMessage{
                
                self.messages.insert(addedFile as! ProductMessage, atIndex: 0)
                
            }
            
            self.addedFile = nil
        }
        
        
        if self.toolBar.inputText.thereIsSomeText(){
            self.messages.insert(JLMessage(text: self.toolBar.inputText.text, senderID: self.chatTableView.myID,messageDate:NSDate(), senderImage: UIImage(named:"imagem")), atIndex: 0)
        }
        
        
        self.chatTableView.addNewMessage()
        
    }

    
}

