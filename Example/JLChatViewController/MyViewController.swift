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


class MyViewController: JLChatViewController,ChatDataSource,ChatToolBarDelegate,ChatMessagesMenuDelegate,ChatDelegate {

   
    var messages:[Message] = [Message]()
    
    var addedFile:AnyObject? // o arquivo que foi adicionado , como uma imagem

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backButton.title = "close"
        loadMessages()
        configChat()
        configToolBar()
        
        addAnswerMeBarButton()
        

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func loadMessages(){
        
        for i in 0..<19{
            
            let newMessage = Message(text: "teste \(i)", senderID: ID.myID.rawValue, messageDate: NSDate(), senderImage: UIImage(named: "imagem"))
            
            self.messages.insert(newMessage, atIndex: 0)
        }
        
        let newMessage = Message(text: "teste  sdas'dbfoasbdfbsdfasdkf;basd;fkbask;fbkdsfbksbfs;kdjfb;kasdbjfkasbdfk;asdbf;bsd;fkbsad;kbfsjkfb;absd;kfbas;dkfb;skdbf;asdfjabksdbfas;dfakdsbf;sdkfb;asjdkfb;skbfjkbs;dfk;asdjfskdfbjasf;sdjf;bskdbfa;djfdkf", senderID: ID.myID.rawValue, messageDate: NSDate(), senderImage: UIImage(named: "imagem"))
        
        self.messages.insert(newMessage, atIndex: 0)
        
    }
    
    func loadOldMessages(){
        
        
        for i in 0..<20{
            
            let newMessage = Message(text: "teste velhas\(i)", senderID: ID.myID.rawValue, messageDate: NSDate(), senderImage: UIImage(named: "imagem"))
            
            self.messages.append(newMessage)
        }
        
        let newMessage = Message(text: "teste  sdas'dbfoasbdfbsdfasdkf;basd;fkbask;fbkdsfbksbfs;kdjfb;kasdbjfkasbdfk;asdbf;bsd;fkbsad;kbfsjkfb;absd;kfbas;dkfb;skdbf;asdfjabksdbfas;dfakdsbf;sdkfb;asjdkfb;skbfjkbs;dfk;asdjfskdfbjasf;sdjf;bskdbfa;djfdkf", senderID: ID.myID.rawValue, messageDate: NSDate(), senderImage: UIImage(named: "imagem"))
        
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
            self.messages.insert(Message(text: text, senderID: ID.otherID.rawValue,messageDate: NSDate(), senderImage: nil) , atIndex: 0)
            
        }
        else if sort == 1{
            self.messages.insert(ProductMessage(senderID: ID.otherID.rawValue, messageDate: NSDate(), senderImage: UIImage(named: "imagem"), text: "Produto", relatedImage: UIImage(named: "imagem")!, productPrice: nil), atIndex: 0)
        }
        else{
            self.messages.insert(Message(senderID: ID.otherID.rawValue,messageDate: NSDate(), senderImage:nil, relatedImage: UIImage(named: "imagem")!), atIndex: 0)
            
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
                
        ChatAppearence.configIncomingMessages(nil, showIncomingSenderImage: true, incomingTextColor: nil)
        
        ChatAppearence.configOutgoingMessages(nil, showOutgoingSenderImage: true, outgoingTextColor: nil)
        
        
        ChatAppearence.configChatFont(nil) { (indexPath) -> Bool in
            
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
        
        return chatTableView.chatMessageForRowAtIndexPath(indexPath, message: self.messages[correctPosition])
    }
    
    
    func chat(chat: ChatTableView, customMessageCellForRowAtIndexPath indexPath: NSIndexPath) -> ChatMessageCell {
        
        let correctPosition = self.messages.count - 1 - indexPath.row

        let message = self.messages[correctPosition]
        
        var cell:ChatMessageCell!
        if message.senderID == self.chatTableView.myID{
            cell = self.chatTableView.dequeueReusableCellWithIdentifier("outgoingProductCell") as! ProductMessageCell
        }
        else{
            cell = self.chatTableView.dequeueReusableCellWithIdentifier("incomingProductCell") as! ProductMessageCell

        }
        
        
        return cell
        
    }
    
    //MARK: ChatDelegate
    
    
    func loadOlderMessages() {
        

        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
       
            self.loadOldMessages()
            
        }
        
        
    }
    
    //https://www.google.com.br/search?client=safari&rls=en&q=adding+new+elements+into+a+tableView+without+making+scroll+to+top&ie=UTF-8&oe=UTF-8&gfe_rd=cr&ei=C9VsVsjfD4ik8wfH9IK4DA
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
        //self.messages.removeAtIndex(correctPosition)
        //self.chatTableView.removeMessage(indexPath)

        self.messages[correctPosition].updateMessageSendStatus(MessageSendStatus.ErrorToSend)
        self.chatTableView.updateMessageStatusOfCellAtIndexPath(indexPath, message: self.messages[correctPosition])
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
        /*addedFile = UIImage(named: "imagem")
        
        self.toolBar.inputText.addFile(File(title: "imagem", image: addedFile as? UIImage))*/
        
        self.addedFile = ProductMessage(senderID: self.chatTableView.myID, messageDate: NSDate(), senderImage: UIImage(named: "imagem"), text: "belo batom rosa!!!", relatedImage: UIImage(named: "imagem")!, productPrice: nil)
        
        self.toolBar.inputText.addFile(File(title: "Produto", image: UIImage(named: "imagem")))
        
    }
    
    func didTapRightButton() {
        
        //ver se existe algum arquivo adicionado e se tiver envia
        if self.toolBar.thereIsSomeFileAdded(),let addedFile = addedFile{
            
            if addedFile is UIImage{
                self.messages.insert(Message(senderID: self.chatTableView.myID,messageDate:NSDate(), senderImage: UIImage(named: "imagem"), relatedImage: addedFile as! UIImage), atIndex: 0)

            }
            else if addedFile is ProductMessage{
                
                self.messages.insert(addedFile as! ProductMessage, atIndex: 0)
                
            }
            
            self.addedFile = nil
        }
        
        
        if self.toolBar.inputText.thereIsSomeText(){
            self.messages.insert(Message(text: self.toolBar.inputText.text, senderID: self.chatTableView.myID,messageDate:NSDate(), senderImage: UIImage(named:"imagem")), atIndex: 0)
        }
        
        
        self.chatTableView.addNewMessage()
        
    }

    
}

