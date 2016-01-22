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
    
    @IBOutlet weak var userTypingDistToToolBar: NSLayoutConstraint!
    
    var animationBlock:((startAnimation:Bool)->())?
    
    override public func viewDidLoad() {
                
        super.viewDidLoad()
        
        self.userTypingView.alpha = 0
        
        self.userTypingDistToToolBar.constant -= self.userTypingView.frame.height
        self.view.layoutIfNeeded()
    
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
        
        if self.chatTableView.numberOfRowsInSection(0) > 0{
            let indexPath = NSIndexPath(forRow: self.chatTableView.numberOfRowsInSection(0) - 1, inSection: 0)
            
            self.chatTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        }
    
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tabController = self.tabBarController{
            tabController.tabBar.hidden = false
        }

    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UserTypingView methods
    
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
        
        let topDist = NSLayoutConstraint(item: self.userTypingView, attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: view, attribute:NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        
        self.userTypingView.addConstraint(topDist)
        
        let bottomDist = NSLayoutConstraint(item: self.userTypingView, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: view, attribute:NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        
        self.userTypingView.addConstraint(bottomDist)
        
        let leftDist = NSLayoutConstraint(item: self.userTypingView, attribute: NSLayoutAttribute.Leading, relatedBy: .Equal, toItem: view, attribute:NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        
        self.userTypingView.addConstraint(leftDist)
        
        let rightDist = NSLayoutConstraint(item: self.userTypingView, attribute: NSLayoutAttribute.Trailing, relatedBy: .Equal, toItem: view, attribute:NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        
        self.userTypingView.addConstraint(rightDist)


    }
    
    
    public func showUserTypingView(){
        
        if let block = animationBlock{
            block(startAnimation: true)

        }
        
        self.userTypingDistToToolBar.constant = 0
        UIView.animateWithDuration(0.1, animations: { () -> Void in

            self.view.layoutIfNeeded()

            }) { (finished) -> Void in
                UIView.animateWithDuration(0.4) { () -> Void in
                    self.userTypingView.alpha = 1
                }

        }
        
    }
    
    public func hideUserTypingView(){
        if let block = animationBlock{
            block(startAnimation: false)
            
        }
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.userTypingView.alpha = 0
            }) { (finished) -> Void in
                self.userTypingDistToToolBar.constant = -self.userTypingView.frame.height
                self.view.layoutIfNeeded()
        }
        
    }
    
    
    //MARK: - KeyBoard notifications
    
    func registerKeyBoardNotifications(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showkeyBoardTarget:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideKeyBoardTarget:", name: UIKeyboardWillHideNotification, object: nil)
        
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
