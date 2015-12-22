//
//  JLChatViewController.swift
//  JLChatViewController
//
//  Created by José Lucas Souza das Chagas on 28/11/15.
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit


public class JLChatViewController: UIViewController {

    @IBOutlet public weak var chatTableView: JLChatTableView!
    
    @IBOutlet public weak var toolBar: JLChatToolBar!
    
    @IBOutlet public weak var toolBarDistToBottom: NSLayoutConstraint!
        
    
    override public func viewDidLoad() {
                
        super.viewDidLoad()
        
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
        
        let indexPath = NSIndexPath(forRow: self.chatTableView.numberOfRowsInSection(0) - 1, inSection: 0)
        
        self.chatTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
    
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
    
    //MARK: Back button methods
    
    
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
    
    
    //MARK: Class func methods
    
       


}
