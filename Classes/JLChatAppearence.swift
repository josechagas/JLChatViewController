//
//  JLChatAppearence.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 30/11/15.  s.version.to_s
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit

open class JLChatAppearence: NSObject {
    
   
    //MARK: - Incoming messages
    static open fileprivate(set) var incomingBubbleImage:UIImage?
    
    static open fileprivate(set) var incomingBubbleLoadingImage:UIImage?
    
    static open fileprivate(set) var incomingBubbleImageMask:UIImage?
    
    static open fileprivate(set) var incomingBubbleColor:UIColor = UIColor(red: 0.2, green: 0.6, blue: 0.7, alpha: 1)
    
    static open fileprivate(set) var showIncomingSenderImage:Bool = true
    
    static open fileprivate(set) var incomingTextColor:UIColor = UIColor.black
    
    
    /**
     This method generates the bubble image applying the choosed color and capInsets
     - parameter image: image that will be used to generate bubble image
     - parameter edgesInsets: Choosed capInsets
     - returns : The generated bubble image
     */
    fileprivate class func generateBubbleImage(WithImage image:UIImage,Color color:UIColor, AndInsets edgesInsets:UIEdgeInsets)->UIImage{
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()
        
        // flip the image
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.translateBy(x: 0.0, y: -image.size.height)
        
        // multiply blend mode
        context?.setBlendMode(CGBlendMode.multiply)
        
        //fill rect with color
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        context?.clip(to: rect, mask: image.cgImage!)
        color.setFill()
        context?.fill(rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //apply cap insets
        return newImage!.resizableImage(withCapInsets: edgesInsets)
    }
    
    /**
     This method generates the bubble loading image applying the choosed color and capInsets
     - parameter image: image that will be used to generate bubble image
     - parameter edges: Choosed capInsets
     - returns : The generated bubble loading image
     */

    fileprivate class func generateBubbleLoadingImage(WithBubleImage image:UIImage!,edges:UIEdgeInsets)->UIImage{
        
        let color = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()
        
        // flip the image
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.translateBy(x: 0.0, y: -image.size.height)
        
        // multiply blend mode
        context?.setBlendMode(CGBlendMode.multiply)
        
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        context?.clip(to: rect, mask: image.cgImage!)
        color.setFill()
        context?.fill(rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!.resizableImage(withCapInsets: edges)
    }

    /**
     Call this method to configure the appearance of your incoming messages.
     - parameter incomingBubbleColor: The bubble color of incoming messages.
     - parameter showIncomingSenderImage: A bolean value that determines if the sender`s image will appear or not.
     - parameter incomingTextColor: The text color of incoming messages.

     */
    open class func configIncomingMessages(_ incomingBubbleColor:UIColor?,showIncomingSenderImage:Bool?,incomingTextColor:UIColor?){
        
        if let incomingBubbleColor = incomingBubbleColor{
            self.incomingBubbleColor = incomingBubbleColor
            
        }
        
        if let showIncomingSenderImage = showIncomingSenderImage{
            self.showIncomingSenderImage = showIncomingSenderImage
        }
        
        if let incomingTextColor = incomingTextColor{
            self.incomingTextColor = incomingTextColor
        }
        
        
        let edges = UIEdgeInsets(top: 16, left: 23, bottom: 16, right: 23)//UIEdgeInsets(top: 16, left: 28, bottom: 17, right: 16)
        
        if let bundle = JLBundleController.getBundle(){
            let defaultIncomingBubble = UIImage(named: "bubble_min_incoming", in: bundle, compatibleWith: nil)!

            incomingBubbleImage = generateBubbleImage(WithImage: defaultIncomingBubble,Color: self.incomingBubbleColor, AndInsets: edges)
            
            //mask
            incomingBubbleImageMask = UIImage(named: "bubble_min_mask_incoming", in: bundle, compatibleWith: nil)?.resizableImage(withCapInsets: edges)
            
            incomingBubbleLoadingImage = generateBubbleLoadingImage(WithBubleImage: defaultIncomingBubble, edges: edges)
        }

    }
    
    /**
     Call this method to configure the appearance of your incoming messages and use custom bubbles.
     
     Custom bubbles and masks normally are small images take a look on size of default ones, but it`s not necessary to have the same size.
     
     Supposing that someone will not understand what customBubbleInsets and bubbleMaskInsets are take a look here: `http://iosdevelopertips.com/user-interface/ios-5-uiimage-and-resizableimagewithcapinsets.html`

     
     - parameter customBubble: The image you want to use as your bubble image. I advise you to use images with 32x32 pixels
     
     - parameter customBubbleInsets: These are the values that you should use to garantee the correct expansion of your image without distorcing it.
     
     - parameter bubbleImageMask: The image you want to use to apply as a mask on image messages, this image can not have a transparent background. I advise you to use images with 32x32 pixels
     
     - parameter bubbleMaskInsets: These are the values that you should use to garantee the correct expansion of your image without distorcing it.

     - parameter incomingBubbleColor: The bubble color of incoming messages.
     
     - parameter showIncomingSenderImage: A bolean value that determines if the sender`s image will appear or not.
     
     - parameter incomingTextColor: The text color of incoming messages.
     
     */
    open class func configIncomingMessages(WithCustomBubbleImage customBubble:UIImage!,customBubbleInsets:UIEdgeInsets!,bubbleImageMask:UIImage!,bubbleMaskInsets:UIEdgeInsets!,incomingBubbleColor:UIColor?,showIncomingSenderImage:Bool?,incomingTextColor:UIColor?){
        
        if let incomingBubbleColor = incomingBubbleColor{
            self.incomingBubbleColor = incomingBubbleColor
            
        }
        
        if let showIncomingSenderImage = showIncomingSenderImage{
            self.showIncomingSenderImage = showIncomingSenderImage
        }
        
        if let incomingTextColor = incomingTextColor{
            self.incomingTextColor = incomingTextColor
        }
        
        incomingBubbleImage = generateBubbleImage(WithImage: customBubble,Color: self.incomingBubbleColor, AndInsets: customBubbleInsets)
        //mask
        incomingBubbleImageMask = bubbleImageMask.resizableImage(withCapInsets: bubbleMaskInsets)
        
        incomingBubbleLoadingImage = generateBubbleLoadingImage(WithBubleImage: customBubble, edges: customBubbleInsets)

        
    }
    //
    
    //MARK: - Outgoing messages
    static open fileprivate(set) var outgoingBubbleImage:UIImage?
    
    static open fileprivate(set) var outgoingBubbleLoadingImage:UIImage?
    
    static open fileprivate(set) var outgoingBubbleImageMask:UIImage?

    static open fileprivate(set) var outgoingBubbleColor:UIColor = UIColor(red: 0.18, green: 0.8, blue: 0.44, alpha: 1)
    
    static open fileprivate(set) var showOutgoingSenderImage:Bool = true

    static open fileprivate(set) var outGoingTextColor:UIColor = UIColor.white
    
    /**
     Call this method to configure the appearance of your outgoing messages.
     - parameter outgoingBubbleColor: The bubble color of outgoing messages.
     - parameter showOutgoingSenderImage: A bolean value that determines if the sender`s image will appear or not.
     - parameter outgoingTextColor: The text color of outgoing messages.
     
     */
    open class func configOutgoingMessages(_ outgoingBubbleColor:UIColor? ,showOutgoingSenderImage:Bool?,outgoingTextColor:UIColor?){
        
        if let outgoingBubbleColor = outgoingBubbleColor{
            self.outgoingBubbleColor = outgoingBubbleColor
        }
        
        if let showOutgoingSenderImage = showOutgoingSenderImage{
            self.showOutgoingSenderImage = showOutgoingSenderImage
        }
        
        if let outGoingTextColor = outgoingTextColor{
            self.outGoingTextColor = outGoingTextColor
        }
        
        
        let edges = UIEdgeInsets(top: 16, left: 23, bottom: 16, right: 23)//UIEdgeInsets(top: 16, left: 28, bottom: 17, right: 16)
        
        if let bundle = JLBundleController.getBundle(){
            
            let defaultOutgoingBubble = UIImage(named: "bubble_min", in: bundle, compatibleWith: nil)!
            
            outgoingBubbleImage = generateBubbleImage(WithImage: defaultOutgoingBubble, Color: self.outgoingBubbleColor, AndInsets: edges)
            //mask
            outgoingBubbleImageMask = UIImage(named: "bubble_min_mask", in: bundle, compatibleWith: nil)?.resizableImage(withCapInsets: edges)
            
            outgoingBubbleLoadingImage = generateBubbleLoadingImage(WithBubleImage: defaultOutgoingBubble, edges: edges)

        }
    }
    
    
    /**
     Call this method to configure the appearance of your outgoing messages and use custom bubbles.
     
     Custom bubbles and masks normally are small images take a look on size of default ones, but it`s not necessary to have the same size.
     
     Supposing that someone will not understand what customBubbleInsets and bubbleMaskInsets are take a look here: `http://iosdevelopertips.com/user-interface/ios-5-uiimage-and-resizableimagewithcapinsets.html`
     
     - parameter customBubble: The image you want to use as your bubble image. I advise you to use images with 32x32 pixels
     
     - parameter customBubbleInsets: These are the values that you should use to garantee the correct expansion of your image without distorcing it.
     
     - parameter bubbleImageMask: The image you want to use to apply as a mask on image messages, this image can not have a transparent background. I advise you to use images with 32x32 pixels
     
     - parameter bubbleMaskInsets: These are the values that you should use to garantee the correct expansion of your image without distorcing it.
     
     - parameter outgoingBubbleColor: The bubble color of outgoing messages.
     
     - parameter showOutgoingSenderImage: A bolean value that determines if the sender`s image will appear or not.
     
     - parameter outgoingTextColor: The text color of outgoing messages.
     
     */
    open class func configOutgoingMessages(WithCustomBubbleImage customBubble:UIImage!,customBubbleInsets:UIEdgeInsets!,bubbleImageMask:UIImage!,bubbleMaskInsets:UIEdgeInsets!,outgoingBubbleColor:UIColor?,showOutgoingSenderImage:Bool?,outgoingTextColor:UIColor?){
        
        if let outgoingBubbleColor = outgoingBubbleColor{
            self.outgoingBubbleColor = outgoingBubbleColor
        }
        
        if let showOutgoingSenderImage = showOutgoingSenderImage{
            self.showOutgoingSenderImage = showOutgoingSenderImage
        }
        
        if let outGoingTextColor = outgoingTextColor{
            self.outGoingTextColor = outGoingTextColor
        }
        
        
        outgoingBubbleImage = generateBubbleImage(WithImage: customBubble, Color: self.outgoingBubbleColor, AndInsets: customBubbleInsets)
        
        //mask
        outgoingBubbleImageMask = bubbleImageMask!.resizableImage(withCapInsets: bubbleMaskInsets)
        
        outgoingBubbleLoadingImage = generateBubbleLoadingImage(WithBubleImage: customBubble, edges: customBubbleInsets)
        
    }
    
    //MARK: - sender image
    
    static open fileprivate(set) var senderImageSize:CGSize = CGSize(width: 30, height: 30)
    
    static open fileprivate(set) var senderImageCornerRadius:CGFloat = 15
    
    static open fileprivate(set) var senderImageBackgroundColor:UIColor = UIColor.lightGray
    
    static open fileprivate(set) var senderImageDefaultImage:UIImage?
    
    
    /**
     Call this method if you want to make some change on sender image appearance,like change its size
     
     OPTIONAL CONFIG METHOD.
     
     - parameter senderImageSize: The size of sender image
     - parameter senderImageCornerRadius: The value of cornerRadius of image
     - parameter senderImageBackgroundColor: The background color of image
     - parameter senderImageDefaultImage: The default image to appear when user there is not an image
     
     */
    open class func configSenderImage(_ senderImageSize:CGSize?,senderImageCornerRadius:CGFloat?,senderImageBackgroundColor:UIColor?,senderImageDefaultImage:UIImage?){
        
        if let senderImageSize = senderImageSize{
            self.senderImageSize = senderImageSize
        }
        
        if let senderImageCornerRadius = senderImageCornerRadius{
            self.senderImageCornerRadius = senderImageCornerRadius
        }
        
        if let senderImageBackgroundColor = senderImageBackgroundColor{
            self.senderImageBackgroundColor = senderImageBackgroundColor
        }
        
        self.senderImageDefaultImage = senderImageDefaultImage
    }
    
    //MARK: SenderImage,Bubble Aligment and Text on Bubble alignment
    
    static open fileprivate(set) var horizontalDistBetweenImg_And_Bubble:CGFloat! = 0
    
    static open fileprivate(set) var vertivalDistBetweenImgBottom_And_BubbleBottom:CGFloat! = 0
    
    static open fileprivate(set) var outgoingTextAligment:UIEdgeInsets! = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 20)
    
    static fileprivate(set) var incomingTextAligment:UIEdgeInsets! = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 16)

    /**
     Call this method to make customizations on sender image and bubble aligment
     
     OPTIONAL CONFIG METHOD.
     
     - parameter horizontalDistBetweenImg_And_Bubble: Represents the horizontal distance between sender`s image side and bubble side
     
     - parameter vertivalDistBetweenImgBottom_And_BubbleBottom: Represents the vertival distance between sender`s image bottom and bubble bottom. This value must not be negative 
     */
    open class func configAligment(_ horizontalDistBetweenImg_And_Bubble:CGFloat,vertivalDistBetweenImgBottom_And_BubbleBottom:CGFloat){
        
        self.horizontalDistBetweenImg_And_Bubble = horizontalDistBetweenImg_And_Bubble
        self.vertivalDistBetweenImgBottom_And_BubbleBottom = vertivalDistBetweenImgBottom_And_BubbleBottom
        
    }

    /**
     Call this method if you are using some custom bubbles and because of it you need to change text aligment.
     
     OPTIONAL CONFIG METHOD.
     
     - parameter IncomingMessTextAlig: The aligment of text on incoming messages
     - parameter AndOutgoingMessTextAlig: The aligment of text on outgoing messages

     */
    open class func configTextAlignmentOnBubble(IncomingMessTextAlig incomingAligment:UIEdgeInsets,AndOutgoingMessTextAlig outgoingAligment:UIEdgeInsets ){
        
        self.incomingTextAligment = incomingAligment
        self.outgoingTextAligment = outgoingAligment
        
    }
    
    
    //MARK: - message font and date view
    static open fileprivate(set) var chatFont:UIFont = UIFont(name: "Helvetica", size: 16)!
    /**
     Call this method to configure the font and the logic to show the message date.
     
     - parameter font: The font of your chat
     - parameter shouldShowMessageDateAtIndexPath: A block with what is necessary to determine when present the date of the message.
     */
    @available(*,deprecated,renamed: "configChatFont",message:"This method is deprecated use configChatFont(font:UIFont?,useCustomDateView:Bool) instead")
    open class func configChatFont(_ font:UIFont?,shouldShowMessageDateAtIndexPath:((_ indexPath:IndexPath)->Bool)?){
        
        /*if let font = font{
            chatFont = font
        }
        if let dateBlock = shouldShowMessageDateAtIndexPath{
            self.shouldShowMessageDateAtIndexPath = dateBlock
        }*/
        if let font = font{
            configChatFont(font)
        }
    }
    
    /**
     Call this method to configure the font and to say if you want to use or not a custom Date Header View.
     
     OPTIONAL CONFIG METHOD.
     - parameter font: The font of your chat
     - parameter useCustomDateView: True if you want to use your own DateView and False if not
     */
    open class func configChatFont(_ font:UIFont){
        chatFont = font
    }
    
    
    //MARK: - Error Button
    
    static open fileprivate(set) var normalStateErrorButtonImage:UIImage!
    static open fileprivate(set) var selectedStateErrorButtonImage:UIImage!
    
    /**
     Call this method to pre-load the default error button images or to use custom ones.
     
     This method is important because it will make easier for you to use the default images because they are on another bundle.
     
     - parameter normalStateImage: The image for error button on state normal
     - parameter selectedStateImage: The image for error button on state selected
     */
    open class func configErrorButton(_ normalStateImage:UIImage?,selectedStateImage:UIImage?){
        if let bundle = JLBundleController.getBundle(){
            
            if let img = normalStateImage{
                normalStateErrorButtonImage = img
            }
            else{
                normalStateErrorButtonImage = UIImage(named: "alert9Normal", in: bundle, compatibleWith: nil)!
            }
            
            
            if let img = selectedStateImage{
                selectedStateErrorButtonImage = img
            }
            else{
                selectedStateErrorButtonImage = UIImage(named: "alert9Selected", in: bundle, compatibleWith: nil)!
            }
            
        }
        else{
            print("Error when trying to get pods bundle")
        }
    }
}
