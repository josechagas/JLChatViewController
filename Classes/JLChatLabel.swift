//
//  JLChatMessageLabel.swift
//  Pods
//
//  Created by José Lucas Souza das Chagas on 04/06/16.
//
//

import UIKit

open class JLChatLabel: UILabel {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable var isOutgoingMessage:Bool = true
    
    open override var text: String?{
        didSet{
            if let text = text{
                settAttributedText(text)
            }
        }
    }
    
    fileprivate var detectedDataTypes = [NSTextCheckingResult]()
    
    var outgoingEdges:UIEdgeInsets!{
        get{
            return JLChatAppearence.outgoingTextAligment
        }
    }
    var incomingEdges:UIEdgeInsets{
        get{
            return JLChatAppearence.incomingTextAligment
        }
    }

    
    open override func draw(_ rect: CGRect) {
        
        if isOutgoingMessage{
            JLChatAppearence.outgoingBubbleImage?.draw(in: rect)
        }
        else{
            JLChatAppearence.incomingBubbleImage?.draw(in: rect)
        }
        self.invalidateIntrinsicContentSize()
        super.draw(rect)
        self.invalidateIntrinsicContentSize()
    }
    
    override open func drawText(in rect: CGRect) {
        let rectWithEdges = UIEdgeInsetsInsetRect(rect, isOutgoingMessage ? outgoingEdges : incomingEdges)
        super.drawText(in: rectWithEdges)
    }
    
    
    override open var intrinsicContentSize : CGSize {
        let edges = isOutgoingMessage ? outgoingEdges : incomingEdges
        //let intrinsicSize = super.intrinsicContentSize()
        
        
        /*
         It calculates the limites that exists because of added constraints and other components
         */
        let subtractBy = 50 + (isOutgoingMessage ? (JLChatAppearence.showOutgoingSenderImage ? JLChatAppearence.senderImageSize.width : 0) : (JLChatAppearence.showIncomingSenderImage ? JLChatAppearence.senderImageSize.width : 0))
        
        let sizeOfText = self.sizeToFitText(LimitedToMaxSize: CGSize(width: self.superview!.frame.width - subtractBy - (edges?.right)! - (edges?.left)!, height: CGFloat(FLT_MAX)))

        var size:CGSize = CGSize.zero

        size.width = (edges?.right)! + (edges?.left)! + sizeOfText.width + 1//(intrinsicSize.width + sizeOfText.width)/2.0//+ (intrinsicSize.width > sizeOfText.width ? intrinsicSize.width: sizeOfText.width)
        
        size.height = (edges?.bottom)! + (edges?.top)! + sizeOfText.height/*(intrinsicSize.height > sizeOfText.height ? intrinsicSize.height: sizeOfText.height)*/ + 1
        return size
        
    }
    
    
    /**
     Calculates the correct size of text based on some max width that the label can have and max height that the label can have, the precision of its values mean more prcision on size returned.
     
     -parameter LimitedToMaxSize: The max size that the text can have. Normally you know the max width or the max height and end you let the other one free.
     
     - returns : The estimated size to contain the text of label
     */
    fileprivate func sizeToFitText(LimitedToMaxSize maxSize:CGSize)->CGSize{
        
        if let attributedText = attributedText{
            
            let maximumSize = maxSize
            
            //let options : NSStringDrawingOptions = NSStringDrawingOptions(rawValue: NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue | NSStringDrawingOptions.UsesFontLeading.rawValue)

            let rect = attributedText.boundingRect(with: maximumSize, options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            
            //let rectLine = attributedText.boundingRectWithSize(maximumSize, options:NSStringDrawingOptions.UsesFontLeading, context: nil)
            
            
            //let height = rect.height + (rect.width < rectLine.width ? rectLine.height/2 : 0)

            let size = rect.size//CGSize(width: rect.width,height: height)

            return size
           
        }
        return CGSize.zero
        
    }
    
    
    //MARK: - Message build methods
    /**
     This method get the text, find the special string types and apply some special style to them
     - parameter text: The text this JLChatLabel instace will present
     */
    open func settAttributedText(_ text:String!){
        self.preferredMaxLayoutWidth = self.superview!.frame.width - 70
        
        var attributedText = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:self.font/*,NSParagraphStyleAttributeName:NSParagraphStyle.defaultParagraphStyle()*/])
        
        let linksDetected = detectLinks(text)
        self.detectedDataTypes.append(contentsOf: linksDetected)
       
        applyStyles([NSUnderlineStyleAttributeName:NSUnderlineStyle.styleSingle.rawValue as AnyObject,NSForegroundColorAttributeName:UIColor(red: 0, green: 0.4, blue: 0.9, alpha: 1)], To: &attributedText, Where: linksDetected)
        
        
        let phoneNumbersDetected = detectPhoneNumbers(text)
        self.detectedDataTypes.append(contentsOf: phoneNumbersDetected)
        
        applyStyles([NSUnderlineStyleAttributeName:NSUnderlineStyle.styleSingle.rawValue as AnyObject,NSForegroundColorAttributeName:UIColor(red: 0, green: 0.4, blue: 0.9, alpha: 1)], To: &attributedText, Where: phoneNumbersDetected)
        
        
        
        if detectedDataTypes.count > 0{
            addGestures()
        }
        
        self.attributedText = attributedText
    }
    
    /**
     Apply selected styles on some part of text present on 'attributedText'
     - parameter styles: Styles you want to apply
     - parameter attributedText: The attribtedText that contains the text you want to apply some styles
     - parameter values: An array of NSTextChekingResult that contains all text you want to apply some style
     */
    fileprivate func applyStyles(_ styles:[String:AnyObject], To attributedText: inout NSMutableAttributedString, Where values:[NSTextCheckingResult]){
        
        for textResult in values{
            attributedText.addAttributes(styles, range: textResult.range)
        }
        
    }
    
    //MARK: - Data Detection methods
    /**
     This method search on text something that can be a link
     - parameter text: The text this JLChatLabel instace will present
     - returns: An array of 'NSTextCheckingResult' with special strings detected
     */
    fileprivate func detectLinks(_ text:String)->[NSTextCheckingResult]{
        //https://www.hackingwithswift.com/example-code/strings/how-to-detect-a-url-in-a-string-using-nsdatadetector
        do{
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.characters.count))
        
            return matches
        }
        catch{
            print("\n\nerror on detectLinks\n\n")
        }
        return []
    }
    
    /**
     This method search on text something that can be a phoneNumber
     - parameter text: The text this JLChatLabel instace will present
     - returns: An array of 'NSTextCheckingResult' with special strings detected
     */
    fileprivate func detectPhoneNumbers(_ text:String)->[NSTextCheckingResult]{
        do{
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.characters.count))
            
            return matches
        }
        catch{
            print("\n\nerror on detectLinks\n\n")
        }
        return []
    }
    
    
    //MARK: - Gestures
    /**
     This method add 'UITapGestureRecognizer' to respective 'JLChatLabel' instance
     */
    fileprivate func addGestures(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(JLChatLabel.tapAction(_:)))
        self.addGestureRecognizer(tap)
    }
    
    /**
     This action is called when you tap on JLChatLabel region
     */
    func tapAction(_ tapGes:UITapGestureRecognizer){
        
        let positionOnlabel = tapGes.location(in: self)
        
        if let attrText = self.attributedText{

            let textContainer = NSTextContainer(size: CGSize(width: self.frame.size.width, height: self.frame.height))
            textContainer.lineFragmentPadding = 0.0
            textContainer.lineBreakMode = self.lineBreakMode
            textContainer.maximumNumberOfLines = self.numberOfLines
            
            
            let layoutManager = NSLayoutManager()
            layoutManager.addTextContainer(textContainer)
            let textStorage = NSTextStorage(attributedString: attrText)
            textStorage.addLayoutManager(layoutManager)
            
            var frameUsedByContainer = layoutManager.usedRect(for: textContainer)
            
            frameUsedByContainer.origin = CGPoint(x: self.center.x - frameUsedByContainer.width/2, y: self.center.y - frameUsedByContainer.height/2)
            
            let xValue = (positionOnlabel.x + self.frame.origin.x) - frameUsedByContainer.origin.x
            
            let yValue = (positionOnlabel.y + self.frame.origin.y) - frameUsedByContainer.origin.y

            
            let positionOnTextContainer = CGPoint(x: xValue, y: yValue)
            
            let characterInder = layoutManager.characterIndex(for: positionOnTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            
            print(characterInder)
            
            let value = self.detectedDataTypes.filter({ (dataType) -> Bool in
                return NSLocationInRange(characterInder, dataType.range)
            })
            if value.count > 0{
                performActionForDataTapped(value[0])
            }
        }
        
    }
    
    /**
     This method execute the action accordingly dataText, for example some link
     - parameter dataText: Some special data that was tapped
     */
    fileprivate func performActionForDataTapped(_ dataText:NSTextCheckingResult){
        switch dataText.resultType {
        case NSTextCheckingResult.CheckingType.link:
            if let url = URL(string: NSString(string: self.text!).substring(with: dataText.range))  , UIApplication.shared.canOpenURL(url){
                UIApplication.shared.openURL(url)
            }
            else if let url = URL(string: "https://\(NSString(string: self.text!).substring(with: dataText.range))") , UIApplication.shared.canOpenURL(url){
                UIApplication.shared.openURL(url)

            }
        case NSTextCheckingResult.CheckingType.phoneNumber:
            let number = NSString(string: self.text!).substring(with: dataText.range)
        
            if let phoneURl = URL(string: "tel://\(number)"){
                UIApplication.shared.openURL(phoneURl)
            }
            
        default:
            break
        }
    }
    
}
