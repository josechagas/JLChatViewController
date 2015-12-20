//
//  ShowChatViewController.swift
//  JLChatViewController
//
//  Created by José Lucas Souza das Chagas on 07/12/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import JLChatViewController
class ShowChatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showChatButtonAction(sender: AnyObject) {
        
        /*
        if let vc = JLBundleController.jLChatFirstVC{
        
        vc.view.frame = self.view.frame
        
        /*let chatSegue = UIStoryboardSegue(identifier: "ChatListVCToChatVC", source: self, destination: vc)
        
        self.prepareForSegue(chatSegue, sender: nil)
        
        chatSegue.perform()*/
        
        let selectedChat = ClientChatSingleton.sharedInstance.listChats[indexPath.row]
        
        let firstNavVC = vc.viewControllers[0] as! MyChatViewController
        
        firstNavVC.currentChat = selectedChat
        
        firstNavVC.userTwo = firstNavVC.currentChat?.userTwo
        
        self.presentViewController(vc, animated: true, completion: nil)
        
        
        }
*/
        
        //use this for you present the JLChatViewController
        if let vc = JLBundleController.instantiateJLChatVC() as? MyViewController{
            
            vc.view.frame = self.view.frame
            
            let chatSegue = UIStoryboardSegue(identifier: "ChatListVCToChatVC", source: self, destination: vc, performHandler: { () -> Void in
                
                self.navigationController?.pushViewController(vc, animated: true)
                //self.presentViewController(vc, animated: true, completion: nil)
                
            })//UIStoryboardSegue(identifier: "ChatListVCToChatVC", source: self, destination: vc)
            
            
            
            chatSegue.perform()
            
            //self.navigationController?.pushViewController(vc, animated: true)
            
            //self.presentViewController(vc, animated: true, completion: nil)
            
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
