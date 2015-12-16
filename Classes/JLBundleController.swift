//
//  JLBundleController.swift
//  Pods
//
//  Created by José Lucas Souza das Chagas on 10/12/15.
//
//

import UIKit


public class JLBundleController {
    
    private(set) public static var jLChatFirstVC:UINavigationController? = nil
    
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
    
    private class func getStoryboard()->UIStoryboard?{
        
        let podBundle = NSBundle(forClass: JLChatViewController.classForCoder())
        
        if let bundleURL = podBundle.URLForResource("JLChatViewController", withExtension: "bundle") {
            
            if let assetsBundle = NSBundle(URL: bundleURL) {
                
                let storyboard = UIStoryboard(name: "JLChat", bundle: assetsBundle)
                
                return storyboard
            }
            
        }
        
        return nil
    }
    
    /**
    Instantiate the initialViewController from JLChat.storyboard into jLChatFirstVC
    */
    public class func loadJLChatNavigation(){
        
        if let jLChatStoryboard = JLBundleController.getStoryboard(){
            
            jLChatFirstVC = jLChatStoryboard.instantiateInitialViewController() as? UINavigationController
            
        }
        
    }


}
