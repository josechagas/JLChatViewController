//
//  JLBundleController.swift
//  Pods
//
//  Created by José Lucas Souza das Chagas on 10/12/15.
//
//

import UIKit


public class JLBundleController {
    
    private(set) public static var jLChatSb:UIStoryboard? = nil


    class func getBundle()->NSBundle?{
        let podBundle = NSBundle(forClass: JLChatViewController.classForCoder())
        
        if let bundleURL = podBundle.URLForResource("JLChatViewController", withExtension: "bundle") {
            if let assetsBundle = NSBundle(URL: bundleURL) {
                return assetsBundle
            }
            return nil
        }
        return nil
    }
    
    public class func loadJLChatStoryboard(){
        
        let podBundle = NSBundle(forClass: JLChatViewController.classForCoder())
        
        if let bundleURL = podBundle.URLForResource("JLChatViewController", withExtension: "bundle") {
            
            if let assetsBundle = NSBundle(URL: bundleURL) {
                
                let storyboard = UIStoryboard(name: "JLChat", bundle: assetsBundle)
                
                self.jLChatSb = storyboard
            }
            
        }
        
    }
    
    /**
    Instantiate the initialViewController from JLChat.storyboard into jLChatFirstVC
    */
    public class func instantiateJLChatVC()->AnyObject?{
        
        if let jLChatStoryboard = jLChatSb{
            
            let jLChatFirstVC = jLChatStoryboard.instantiateInitialViewController()
            
            return jLChatFirstVC
        }
        return nil
    }


}
