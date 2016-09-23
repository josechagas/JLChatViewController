//
//  ShowChatViewController.swift
//  JLChatViewController
//
//  Created by José Lucas Souza das Chagas on 07/12/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import QuartzCore
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
    
    @IBAction func showChatButtonAction(_ sender: AnyObject) {
        
        //use this for you present the JLChatViewController
        if let vc = JLBundleController.instantiateJLChatVC() as? MyViewController{
            
            vc.view.frame = self.view.frame
            
            let chatSegue = UIStoryboardSegue(identifier: "ChatListVCToChatVC", source: self, destination: vc, performHandler: { () -> Void in
                
                self.navigationController?.pushViewController(vc, animated: true)

                
            })
            
            self.prepare(for: chatSegue, sender: nil)
            
            chatSegue.perform()
            
            
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
