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
public class JLChatViewController: UIViewController {

    /**
     * This is your tableView with all changes that you need to work with it as chat.
     */
    @IBOutlet public weak var chatTableView: JLChatTableView!
    
    @IBOutlet weak var chatTableViewDistToBottom: NSLayoutConstraint!
    
    /**
     * use this to access the UI elements that you need to write and send your message.
     */
    @IBOutlet public weak var toolBar: JLChatToolBar!
    
    /**
     * Do not change this value if you do not know exactly what you are doing!
     *
     * Its used to control the toolBar position accordingly to changes on UI.
     */
    @IBOutlet public weak var toolBarDistToBottom: NSLayoutConstraint!
    
    
    @IBOutlet weak var userTypingView: UIView!
    
    //user typing view constraints
    @IBOutlet weak var userTypingDistToToolBar: NSLayoutConstraint!
    
    @IBOutlet weak var userTypingViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var userTypingViewHeight: NSLayoutConstraint!
    
    
    /**
     The block that contains the code necessary to start and stop the animation of the typing view
     */
    private var animationBlock:((startAnimation:Bool)->())?
    
    private var reloadAddedMessages:Bool = false
    
    override public func viewDidLoad() {
                
        super.viewDidLoad()
        
        self.userTypingView.alpha = 0
        
        self.userTypingDistToToolBar.constant -= self.userTypingView.frame.height
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
    
        self.registerKeyBoardNotifications()
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabController = self.tabBarController{
            tabController.tabBar.hidden = true
        }
        
    
    }
    
    public override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(animated)
        
        if reloadAddedMessages{
            self.chatTableView.reloadAddedMessages()
            reloadAddedMessages = false
        }
        
    }
    
    
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tabController = self.tabBarController{
            tabController.tabBar.hidden = false
        }

    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        reloadAddedMessages = true
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.chatTableView.reloadAddedMessages()
        
    }
    
    override public func didReceiveMemoryWarning() {
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
    
    public func loadTypingViewWithCustomView(customView:UIView?,animationBlock:((startAnimation:Bool)->())?){
        
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
        
        let topDist = NSLayoutConstraint(item: self.userTypingView, attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: view, attribute:NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        
        self.userTypingView.addConstraint(topDist)
        
        let bottomDist = NSLayoutConstraint(item: self.userTypingView, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: view, attribute:NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        
        self.userTypingView.addConstraint(bottomDist)
        
        let leftDist = NSLayoutConstraint(item: self.userTypingView, attribute: NSLayoutAttribute.Leading, relatedBy: .Equal, toItem: view, attribute:NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        
        self.userTypingView.addConstraint(leftDist)
        
        let rightDist = NSLayoutConstraint(item: self.userTypingView, attribute: NSLayoutAttribute.Trailing, relatedBy: .Equal, toItem: view, attribute:NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        
        self.userTypingView.addConstraint(rightDist)
        
        

    }
    
    /**
     This method show the UserTypingView and start the animation
     */
    public func showUserTypingView(){
        
        //self.chatTableView.scrollChatToBottom(true,basedOnLastRow: nil)
        if let block = animationBlock{
            block(startAnimation: true)
            
        }
        
        if userTypingView.alpha == 0{
            self.userTypingDistToToolBar.constant = 0
            self.chatTableView.updateInsetsBottom(self.chatTableView.contentInset.bottom + self.userTypingView.frame.height,animated: true,duration: 0)
            
            //self.chatTableViewDistToBottom.constant = self.userTypingView.frame.height
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.userTypingView.alpha = 1
                self.view.layoutIfNeeded()
                
            }) { (finished) -> Void in
                if finished{
                    self.chatTableView.scrollChatToBottom(true,basedOnLastRow: nil)
                }
            }
        }
        
    }
    /**
     This method hide the UserTypingView and stop the animation
     */
    public func hideUserTypingView(completion:(()->())?){
        
        if let block = animationBlock{
            block(startAnimation: false)
        }
        
        if userTypingView.alpha == 1{
            self.userTypingDistToToolBar.constant = -self.userTypingView.frame.height
            self.chatTableView.updateInsetsBottom(self.chatTableView.contentInset.bottom - self.userTypingView.frame.height,animated: true,duration: 0.3)
        }
        
        //self.chatTableView.scrollChatToBottom(true, basedOnLastRow: nil)
        
        //self.chatTableViewDistToBottom.constant = 0
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            
            self.userTypingView.alpha = 0
            self.view.layoutIfNeeded()
            
        }) { (finished) -> Void in
            if finished, let completion = completion{
                completion()
            }
        }

    }
    
    
    //MARK: - KeyBoard notifications
    
    
    
    func registerKeyBoardNotifications(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(JLChatViewController.showkeyBoardTarget(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(JLChatViewController.hideKeyBoardTarget(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    
    func showkeyBoardTarget(notification:NSNotification){
        
        
        
        let info = notification.userInfo as! [String:AnyObject]
        
        let keyBoardFrame = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
        
        let keyBoadHeight = keyBoardFrame!.height
        
        self.toolBarDistToBottom.constant = keyBoadHeight
        
        UIView.animateWithDuration(0.2) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    func hideKeyBoardTarget(notification:NSNotification){
        
        self.toolBarDistToBottom.constant = 0
        
        UIView.animateWithDuration(0.2) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
}
