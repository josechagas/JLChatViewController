//
//  JLChatViewController.swift
//  JLChatViewController
//
//  Created by José Lucas Souza das Chagas on 28/11/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit

/**
This is the class that contains all basic methods and outlets that you need to work with JLChatVC file from JLChat.storyboard
*/
open class JLChatViewController: UIViewController {

    /**
     * This is your tableView with all changes that you need to work with it as chat.
     */
    @IBOutlet open weak var chatTableView: JLChatTableView!
    
    @IBOutlet weak var chatTableViewDistToBottom: NSLayoutConstraint!
    
    /**
     * use this to access the UI elements that you need to write and send your message.
     */
    @IBOutlet open weak var toolBar: JLChatToolBar!
    
    /**
     * Do not change this value if you do not know exactly what you are doing!
     *
     * Its used to control the toolBar position accordingly to changes on UI.
     */
    @IBOutlet open weak var toolBarDistToBottom: NSLayoutConstraint!
    
    
    @IBOutlet public weak var userTypingView: UIView!
    
    //user typing view constraints
    /**
     This is the constraint that represents the dist from 'userTypingView' bottom to 'JLChatToolBar'
     */
    @IBOutlet public weak var userTypingDistToToolBar: NSLayoutConstraint!
    /**
     This is the constraint that represents the width of 'userTypingView'
     its value is automatic set when you call loadTypingViewWithCustomView
     */
    @IBOutlet weak var userTypingViewWidth: NSLayoutConstraint!
    /**
     This is the constraint that represents the height of 'userTypingView'
     its value is automatic set when you call loadTypingViewWithCustomView
     */
    @IBOutlet weak var userTypingViewHeight: NSLayoutConstraint!
    
    
    /**
     The block that contains the code necessary to start and stop the animation of the typing view
     */
    fileprivate var animationBlock:((_ startAnimation:Bool)->())?
    
    fileprivate var reloadAddedMessages:Bool = false
    
    override open func viewDidLoad() {
                
        super.viewDidLoad()
        
        self.userTypingView.alpha = 0
        
        self.userTypingDistToToolBar.constant -= self.userTypingView.frame.height
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
    
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerKeyBoardNotifications()
        if let tabController = self.tabBarController{
            tabController.tabBar.isHidden = true
        }
        
    
    }
    
    open override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
        
        if reloadAddedMessages{
            self.chatTableView.reloadAddedMessages()
            reloadAddedMessages = false
        }
        
    }
    
    
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tabController = self.tabBarController{
            tabController.tabBar.isHidden = false
        }

    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reloadAddedMessages = true
        unregisterKeyBoardNotifications()
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        self.chatTableView.reloadAddedMessages()
        
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("JLChatViewController received memory warning")
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UserTypingView methods
    /**
    Call this method for you configure the UserTypingView 
    
    - parameter customView: The custom View that will represents that the user is typing a message. Value nil if you want to use the default view. This customView must have a configured size because it will be used to configure the constraints.
    
    - parameter animationBlock: The block that contains the code necessary to start and stop the animation that belongs to your customView
    
    */
    
    open func loadTypingViewWithCustomView(_ customView:UIView?,animationBlock:((_ startAnimation:Bool)->())?){
        
        var view:UIView!
        
        if let customView = customView{
            view = customView
            self.animationBlock = animationBlock
        }
        else{
            view = JLUserTypingView.loadViewFromNib()
            
            self.animationBlock = { (startAnimation) -> () in
                if startAnimation{
                    (view as! JLUserTypingView).startAnimation(0.8)
                }
                else{
                    (view as! JLUserTypingView).stopAnimation()
                }
            }
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.userTypingView.addSubview(view)
        
        self.userTypingViewWidth.constant = view.frame.width
        self.userTypingViewHeight.constant = view.frame.height
        
        let topDist = NSLayoutConstraint(item: self.userTypingView, attribute: NSLayoutAttribute.top, relatedBy: .equal, toItem: view, attribute:NSLayoutAttribute.top, multiplier: 1, constant: 0)
        
        self.userTypingView.addConstraint(topDist)
        
        let bottomDist = NSLayoutConstraint(item: self.userTypingView, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: view, attribute:NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        
        self.userTypingView.addConstraint(bottomDist)
        
        let leftDist = NSLayoutConstraint(item: self.userTypingView, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: view, attribute:NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        
        self.userTypingView.addConstraint(leftDist)
        
        let rightDist = NSLayoutConstraint(item: self.userTypingView, attribute: NSLayoutAttribute.trailing, relatedBy: .equal, toItem: view, attribute:NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        
        self.userTypingView.addConstraint(rightDist)
        
        

    }
    
    /**
     This method show the UserTypingView and start the animation
     */
    open func showUserTypingView(){
        
        //self.chatTableView.scrollChatToBottom(true,basedOnLastRow: nil)
        if let block = animationBlock{
            block(true)
            
        }
        
        if userTypingView.alpha == 0{
            self.userTypingDistToToolBar.constant = 0
            self.chatTableView.updateInsetsBottom(self.chatTableView.contentInset.bottom + self.userTypingView.frame.height,animated: true,duration: 0)
            
            //self.chatTableViewDistToBottom.constant = self.userTypingView.frame.height
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.userTypingView.alpha = 1
                self.view.layoutIfNeeded()
                
            }, completion: { (finished) -> Void in
                if finished{
                    self.chatTableView.scrollChatToBottom(true,basedOnLastRow: nil)
                }
            }) 
        }
        
    }
    /**
     This method hide the UserTypingView and stop the animation
     */
    open func hideUserTypingView(_ completion:(()->())?){
        
        if let block = animationBlock{
            block(false)
        }
        
        if userTypingView.alpha == 1{
            self.userTypingDistToToolBar.constant = -self.userTypingView.frame.height
            self.chatTableView.updateInsetsBottom(self.chatTableView.contentInset.bottom - self.userTypingView.frame.height,animated: true,duration: 0.3)
        }
        
        //self.chatTableViewDistToBottom.constant = 0
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            
            self.userTypingView.alpha = 0
            self.view.layoutIfNeeded()
            
        }, completion: { (finished) -> Void in
            if finished, let completion = completion{
                completion()
            }
        }) 

    }
    
    
    //MARK: - KeyBoard notifications
    
    
    /**
     This method register it to UIKeyboard notifications
     */
    fileprivate func registerKeyBoardNotifications(){
        
        NotificationCenter.default.addObserver(self, selector:#selector(JLChatViewController.showkeyBoardTarget(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(JLChatViewController.hideKeyBoardTarget(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    /**
     This method unregister it to UIKeyboard notifications
     */
    fileprivate func unregisterKeyBoardNotifications(){
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /**
     This is the selector for notification 'UIKeyboardWillShow'
     */
    func showkeyBoardTarget(_ notification:Notification){
        
        
        
        let info = (notification as NSNotification).userInfo as! [String:AnyObject]
        
        let keyBoardFrame = info[UIKeyboardFrameEndUserInfoKey]?.cgRectValue
        
        let keyBoadHeight = keyBoardFrame!.height
        
        self.toolBarDistToBottom.constant = keyBoadHeight
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
    
    
    /**
     This is the selector for notification 'UIKeyboardWillHide'
     */
    func hideKeyBoardTarget(_ notification:Notification){
        
        self.toolBarDistToBottom.constant = 0
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
}
