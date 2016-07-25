//
//  JLChatAppearence.swift
//  ChatViewController
//
//  Created by José Lucas Souza das Chagas on 30/11/15.  s.version.to_s
//  Copyright © 2015 José Lucas Souza das Chagas. All rights reserved.
//

import UIKit

public class JLChatAppearence: NSObject {
    
   
    //MARK: - Incoming messages
    static public private(set) var incomingBubbleImage:UIImage?
    
    static public private(set) var incomingBubbleLoadingImage:UIImage?
    
    static public private(set) var incomingBubbleImageMask:UIImage?
    
    static public private(set) var incomingBubbleColor:UIColor = UIColor(red: 0.2, green: 0.6, blue: 0.7, alpha: 1)
    
    static public private(set) var showIncomingSenderImage:Bool = true
    
    static public private(set) var incomingTextColor:UIColor = UIColor.blackColor()
    
    
    /**
     This method generates the bubble image applying the choosed color and capInsets
     - parameter image: image that will be used to generate bubble image
     - parameter edgesInsets: Choosed capInsets
     - returns : The generated bubble image
     */
    private class func generateBubbleImage(WithImage image:UIImage,Color color:UIColor, AndInsets edgesInsets:UIEdgeInsets)->UIImage{
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()
        
        // flip the image
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextTranslateCTM(context, 0.0, -image.size.height)
        
        // multiply blend mode
        CGContextSetBlendMode(context, CGBlendMode.Multiply)
        
        //fill rect with color
        let rect = CGRectMake(0, 0, image.size.width, image.size.height)
        CGContextClipToMask(context, rect, image.CGImage)
        color.setFill()
        CGContextFillRect(context, rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //apply cap insets
        return newImage.resizableImageWithCapInsets(edgesInsets)
    }
    
    /**
     This method generates the bubble loading image applying the choosed color and capInsets
     - parameter image: image that will be used to generate bubble image
     - parameter edges: Choosed capInsets
     - returns : The generated bubble loading image
     */

    private class func generateBubbleLoadingImage(WithBubleImage image:UIImage!,edges:UIEdgeInsets)->UIImage{
        
        let color = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()
        
        // flip the image
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextTranslateCTM(context, 0.0, -image.size.height)
        
        // multiply blend mode
        CGContextSetBlendMode(context, CGBlendMode.Multiply)
        
        let rect = CGRectMake(0, 0, image.size.width, image.size.height)
        CGContextClipToMask(context, rect, image.CGImage)
        color.setFill()
        CGContextFillRect(context, rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage.resizableImageWithCapInsets(edges)
    }

    /**
     Call this method to configure the appearance of your incoming messages.
     - parameter incomingBubbleColor: The bubble color of incoming messages.
     - parameter showIncomingSenderImage: A bolean value that determines if the sender`s image will appear or not.
     - parameter incomingTextColor: The text color of incoming messages.

     */
    public class func configIncomingMessages(incomingBubbleColor:UIColor?,showIncomingSenderImage:Bool?,incomingTextColor:UIColor?){
        
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
            let defaultIncomingBubble = UIImage(named: "bubble_min_incoming", inBundle: bundle, compatibleWithTraitCollection: nil)!

            incomingBubbleImage = generateBubbleImage(WithImage: defaultIncomingBubble,Color: self.incomingBubbleColor, AndInsets: edges)
            
            //mask
            incomingBubbleImageMask = UIImage(named: "bubble_min_mask_incoming", inBundle: bundle, compatibleWithTraitCollection: nil)?.resizableImageWithCapInsets(edges)
            
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
    public class func configIncomingMessages(WithCustomBubbleImage customBubble:UIImage!,customBubbleInsets:UIEdgeInsets!,bubbleImageMask:UIImage!,bubbleMaskInsets:UIEdgeInsets!,incomingBubbleColor:UIColor?,showIncomingSenderImage:Bool?,incomingTextColor:UIColor?){
        
        if let incomingBubbleColor = incomingBubbleColor{
            self.incomingBubbleColor = incomingBubbleColor
            
        }
        
        if let showIncomingSenderImage = showIncomingSenderImage{
            self.showIncomingSenderImage = showIncomingSenderImage
        }
        
        if let incomingTextColor = incomingTextColor{
            self.incomingTextColor = incomingTextColor
        }
        
        if let bundle = JLBundleController.getBundle(){
            
            incomingBubbleImage = generateBubbleImage(WithImage: customBubble,Color: self.incomingBubbleColor, AndInsets: customBubbleInsets)
            //mask
            incomingBubbleImageMask = bubbleImageMask.resizableImageWithCapInsets(bubbleMaskInsets)

            incomingBubbleLoadingImage = generateBubbleLoadingImage(WithBubleImage: customBubble, edges: customBubbleInsets)
        }
        
    }
    //
    
    //MARK: - Outgoing messages
    static public private(set) var outgoingBubbleImage:UIImage?
    
    static public private(set) var outgoingBubbleLoadingImage:UIImage?
    
    static public private(set) var outgoingBubbleImageMask:UIImage?

    static public private(set) var outgoingBubbleColor:UIColor = UIColor(red: 0.18, green: 0.8, blue: 0.44, alpha: 1)
    
    static public private(set) var showOutgoingSenderImage:Bool = true

    static public private(set) var outGoingTextColor:UIColor = UIColor.whiteColor()
    
    /**
     Call this method to configure the appearance of your outgoing messages.
     - parameter outgoingBubbleColor: The bubble color of outgoing messages.
     - parameter showOutgoingSenderImage: A bolean value that determines if the sender`s image will appear or not.
     - parameter outgoingTextColor: The text color of outgoing messages.
     
     */
    public class func configOutgoingMessages(outgoingBubbleColor:UIColor? ,showOutgoingSenderImage:Bool?,outgoingTextColor:UIColor?){
        
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
            
            let defaultOutgoingBubble = UIImage(named: "bubble_min", inBundle: bundle, compatibleWithTraitCollection: nil)!
            
            outgoingBubbleImage = generateBubbleImage(WithImage: defaultOutgoingBubble, Color: self.outgoingBubbleColor, AndInsets: edges)
            //mask
            outgoingBubbleImageMask = UIImage(named: "bubble_min_mask", inBundle: bundle, compatibleWithTraitCollection: nil)?.resizableImageWithCapInsets(edges)
            
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
    public class func configOutgoingMessages(WithCustomBubbleImage customBubble:UIImage!,customBubbleInsets:UIEdgeInsets!,bubbleImageMask:UIImage!,bubbleMaskInsets:UIEdgeInsets!,outgoingBubbleColor:UIColor?,showOutgoingSenderImage:Bool?,outgoingTextColor:UIColor?){
        
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
        outgoingBubbleImageMask = bubbleImageMask!.resizableImageWithCapInsets(bubbleMaskInsets)
        
        outgoingBubbleLoadingImage = generateBubbleLoadingImage(WithBubleImage: customBubble, edges: customBubbleInsets)
        
    }
    
    //MARK: - sender image
    
    static public private(set) var senderImageSize:CGSize = CGSize(width: 30, height: 30)
    
    static public private(set) var senderImageCornerRadius:CGFloat = 15
    
    static public private(set) var senderImageBackgroundColor:UIColor = UIColor.lightGrayColor()
    
    static public private(set) var senderImageDefaultImage:UIImage?
    
    
    /**
     Call this method if you want to make some change on sender image appearance,like change its size
     
     OPTIONAL CONFIG METHOD.
     
     - parameter senderImageSize: The size of sender image
     - parameter senderImageCornerRadius: The value of cornerRadius of image
     - parameter senderImageBackgroundColor: The background color of image
     - parameter senderImageDefaultImage: The default image to appear when user there is not an image
     
     */
    public class func configSenderImage(senderImageSize:CGSize?,senderImageCornerRadius:CGFloat?,senderImageBackgroundColor:UIColor?,senderImageDefaultImage:UIImage?){
        
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
    
    static public private(set) var horizontalDistBetweenImg_And_Bubble:CGFloat! = 0
    
    static public private(set) var vertivalDistBetweenImgBottom_And_BubbleBottom:CGFloat! = 0
    
    static public private(set) var outgoingTextAligment:UIEdgeInsets! = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 20)
    
    static private(set) var incomingTextAligment:UIEdgeInsets! = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 16)

    /**
     Call this method to make customizations on sender image and bubble aligment
     
     OPTIONAL CONFIG METHOD.
     
     - parameter horizontalDistBetweenImg_And_Bubble: Represents the horizontal distance between sender`s image side and bubble side
     
     - parameter vertivalDistBetweenImgBottom_And_BubbleBottom: Represents the vertival distance between sender`s image bottom and bubble bottom. This value must not be negative 
     */
    public class func configAligment(horizontalDistBetweenImg_And_Bubble:CGFloat,vertivalDistBetweenImgBottom_And_BubbleBottom:CGFloat){
        
        self.horizontalDistBetweenImg_And_Bubble = horizontalDistBetweenImg_And_Bubble
        self.vertivalDistBetweenImgBottom_And_BubbleBottom = vertivalDistBetweenImgBottom_And_BubbleBottom
        
    }

    /**
     Call this method if you are using some custom bubbles and because of it you need to change text aligment.
     
     OPTIONAL CONFIG METHOD.
     
     - parameter IncomingMessTextAlig: The aligment of text on incoming messages
     - parameter AndOutgoingMessTextAlig: The aligment of text on outgoing messages

     */
    public class func configTextAlignmentOnBubble(IncomingMessTextAlig incomingAligment:UIEdgeInsets,AndOutgoingMessTextAlig outgoingAligment:UIEdgeInsets ){
        
        self.incomingTextAligment = incomingAligment
        self.outgoingTextAligment = outgoingAligment
        
    }
    
    
    //MARK: - message font and date view
        
    static public private(set) var chatFont:UIFont = UIFont(name: "Helvetica", size: 16)!
    /**
     Call this method to configure the font and the logic to show the message date.
     
     - parameter font: The font of your chat
     - parameter shouldShowMessageDateAtIndexPath: A block with what is necessary to determine when present the date of the message.
     */

    @available(*,deprecated,renamed="configChatFont(font:UIFont?,useCustomDateView:Bool)",message="This method is deprecated use configChatFont(font:UIFont?,useCustomDateView:Bool) instead")
    public class func configChatFont(font:UIFont?,shouldShowMessageDateAtIndexPath:((indexPath:NSIndexPath)->Bool)?){
        
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
    public class func configChatFont(font:UIFont){
        chatFont = font
    }
    
    
    //MARK: - Error Button
    
    static public private(set) var normalStateErrorButtonImage:UIImage!
    static public private(set) var selectedStateErrorButtonImage:UIImage!
    
    /**
     Call this method to pre-load the default error button images or to use custom ones.
     
     This method is important because it will make easier for you to use the default images because they are on another bundle.
     
     - parameter normalStateImage: The image for error button on state normal
     - parameter selectedStateImage: The image for error button on state selected
     */
    public class func configErrorButton(normalStateImage:UIImage?,selectedStateImage:UIImage?){
        if let bundle = JLBundleController.getBundle(){
            
            if let img = normalStateImage{
                normalStateErrorButtonImage = img
            }
            else{
                normalStateErrorButtonImage = UIImage(named: "alert9Normal", inBundle: bundle, compatibleWithTraitCollection: nil)!
            }
            
            
            if let img = selectedStateImage{
                selectedStateErrorButtonImage = img
            }
            else{
                selectedStateErrorButtonImage = UIImage(named: "alert9Selected", inBundle: bundle, compatibleWithTraitCollection: nil)!
            }
            
        }
        else{
            print("Error when trying to get pods bundle")
        }
    }
}
