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

    @IBOutlet weak var someView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showChatButtonAction(sender: AnyObject) {
        
        //use this for you present the JLChatViewController
        if let vc = JLBundleController.instantiateJLChatVC() as? MyViewController{
            
            vc.view.frame = self.view.frame
            
            let chatSegue = UIStoryboardSegue(identifier: "ChatListVCToChatVC", source: self, destination: vc, performHandler: { () -> Void in
                
                self.navigationController?.pushViewController(vc, animated: true)

                
            })
            
            self.prepareForSegue(chatSegue, sender: nil)
            
            chatSegue.perform()
            
            
        }
        /*
        someView.layer.delegate = self.view.layer
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            print("terminou")
        }
        CATransaction.setDisableActions(false)
        CATransaction.setAnimationDuration(3.0)
        
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
        //someView.layer.frame = CGRect(origin: someView.layer.frame.origin, size: CGSize(width: 100, height: 120))
        //someView.layer.position = CGPointZero
        //someView.layer.bounds.size = CGSize(width: 200, height: 100)
        someView.alpha = 0
        CATransaction.commit()
        */
        /*
        let animation = CABasicAnimation()
        animation.keyPath = "bounds.size.height"
        animation.fromValue =  someView.layer.bounds.height
        animation.toValue =  someView.layer.bounds.height+100
        animation.duration = 1
        animation.byValue = 1
        animation.fillMode =  kCAFillModeBackwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        someView.layer.addAnimation(animation, forKey:nil)
         */
        
        /*position
        let animation = CABasicAnimation()
        animation.keyPath = "position.x"
        animation.fromValue =  someView.layer.position.x
        animation.toValue =  someView.layer.position.x+100
        animation.duration = 1
        animation.byValue = 1
        animation.fillMode =  kCAFillModeBackwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        someView.layer.addAnimation(animation, forKey:nil)
        */
        
        /*
        transition
        let transition = CATransition()
        transition.type = kCATransitionFade//kCATransitionReveal//kCATransitionFade
        transition.subtype = kCATransitionFromBottom
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear/*kCAMediaTimingFunctionEaseInEaseOut*/)
        
        transition.fillMode = kCAFillModeRemoved
        transition.duration = 2
        transition.startProgress = 0
        transition.endProgress = 1
        someView.layer.addAnimation(transition, forKey: nil)

        someView.layer.backgroundColor = UIColor.blueColor().CGColor
        */
        /*
        let frameAnimation = CAKeyframeAnimation()
        frameAnimation.keyPath = "position"
        
        //frameAnimation.values = [ NSValue(CGSize: CGSize(width: 50, height: 100)),NSValue(CGSize: CGSize(width: 50, height: 50)),NSValue(CGSize: CGSize(width: 50, height: 0))]
        
        //frameAnimation.additive = false
        //frameAnimation.values = [NSValue(CGPoint: CGPoint(x: someView.layer.position.x, y: someView.layer.position.y)), NSValue(CGPoint: CGPoint(x: someView.layer.position.x, y: someView.layer.position.y + 50)),NSValue(CGPoint: CGPoint(x: someView.layer.position.x, y: someView.layer.position.y - 50))]

        frameAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        frameAnimation.duration = 2
        
        
        frameAnimation.values = [NSValue(CGPoint: CGPoint(x: 0, y: 0)), NSValue(CGPoint: CGPoint(x: 0, y: 50)),NSValue(CGPoint: CGPoint(x: 0, y: -50))]
        frameAnimation.additive = true
        
        someView.layer.addAnimation(frameAnimation, forKey: nil)
        */
        
        //someView.layer.position = CGPoint(x: someView.layer.position.x+100, y: 0) //= CGRect(origin: header.frame.origin, size: CGSize(width: header.frame.width, height: 0))
        //self.reloadData()
        //someView.layoutIfNeeded()

        
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
