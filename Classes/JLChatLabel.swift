//
//  JLChatMessageLabel.swift
//  Pods
//
//  Created by José Lucas Souza das Chagas on 04/06/16.
//
//

import UIKit

public class JLChatLabel: UILabel {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable var isOutgoingMessage:Bool = true
    
    public override var text: String?{
        didSet{
            if let text = text{
                settAttributedText(text)
            }
        }
    }
    
    private var detectedDataTypes = [NSTextCheckingResult]()
    
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

    
    public override func drawRect(rect: CGRect) {
        
        if isOutgoingMessage{
            JLChatAppearence.outgoingBubbleImage?.drawInRect(rect)
        }
        else{
            JLChatAppearence.incomingBubbleImage?.drawInRect(rect)
        }
        self.invalidateIntrinsicContentSize()
        super.drawRect(rect)
        self.invalidateIntrinsicContentSize()
    }
    
    override public func drawTextInRect(rect: CGRect) {
        let rectWithEdges = UIEdgeInsetsInsetRect(rect, isOutgoingMessage ? outgoingEdges : incomingEdges)
        super.drawTextInRect(rectWithEdges)
    }
    
    
    override public func intrinsicContentSize() -> CGSize {
        let edges = isOutgoingMessage ? outgoingEdges : incomingEdges
        var intrinsicSize = super.intrinsicContentSize()
        
        
        /*
         It calculates the limites that exists because of added constraints and other components
         */
        let subtractBy = 50 + (isOutgoingMessage ? (JLChatAppearence.showOutgoingSenderImage ? JLChatAppearence.senderImageSize.width : 0) : (JLChatAppearence.showIncomingSenderImage ? JLChatAppearence.senderImageSize.width : 0))
        
        var sizeOfText = self.sizeToFitText(LimitedToMaxSize: CGSize(width: self.superview!.frame.width - subtractBy - edges.right - edges.left, height: CGFloat(FLT_MAX)))

        var size:CGSize = CGSizeZero

        size.width = edges.right + edges.left + sizeOfText.width + 1//(intrinsicSize.width + sizeOfText.width)/2.0//+ (intrinsicSize.width > sizeOfText.width ? intrinsicSize.width: sizeOfText.width)
        
        size.height = edges.bottom + edges.top + (intrinsicSize.height > sizeOfText.height ? intrinsicSize.height: sizeOfText.height) + 1
        return size
        
    }
    
    
    /**
     Calculates the correct size of text based on some max width that the label can have and max height that the label can have, the precision of its values mean more prcision on size returned.
     
     -parameter LimitedToMaxSize: The max size that the text can have. Normally you know the max width or the max height and end you let the other one free.
     
     - returns : The estimated size to contain the text of label
     */
    private func sizeToFitText(LimitedToMaxSize maxSize:CGSize)->CGSize{
        
        if let attributedText = attributedText{
            let edges = isOutgoingMessage ? outgoingEdges : incomingEdges
            
            let maximumSize = maxSize
            
            let options : NSStringDrawingOptions = NSStringDrawingOptions(rawValue: NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue | NSStringDrawingOptions.UsesFontLeading.rawValue)

            let rect = attributedText.boundingRectWithSize(maximumSize, options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
            
            let rectLine = attributedText.boundingRectWithSize(maximumSize, options:NSStringDrawingOptions.UsesFontLeading, context: nil)
            
            
            //let height = rect.height + (rect.width < rectLine.width ? rectLine.height/2 : 0)

            let size = rect.size//CGSize(width: rect.width,height: height)

            return size
           
        }
        return CGSize.zero
        
    }
    
    
    //MARK: - Message build methods
    
    public func settAttributedText(text:String!){
        self.preferredMaxLayoutWidth = self.superview!.frame.width - 70
        
        var attributedText = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:self.font/*,NSParagraphStyleAttributeName:NSParagraphStyle.defaultParagraphStyle()*/])
        
        let linksDetected = detectLinks(text)
        self.detectedDataTypes.appendContentsOf(linksDetected)
       
        applyStyles([NSUnderlineStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue,NSForegroundColorAttributeName:UIColor(red: 0, green: 0.4, blue: 0.9, alpha: 1)], To: &attributedText, Where: linksDetected)
        
        
        let phoneNumbersDetected = detectPhoneNumbers(text)
        self.detectedDataTypes.appendContentsOf(phoneNumbersDetected)
        
        applyStyles([NSUnderlineStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue,NSForegroundColorAttributeName:UIColor(red: 0, green: 0.4, blue: 0.9, alpha: 1)], To: &attributedText, Where: phoneNumbersDetected)
        
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
    private func applyStyles(styles:[String:AnyObject],inout To attributedText:NSMutableAttributedString, Where values:[NSTextCheckingResult]){
        
        for textResult in values{
            attributedText.addAttributes(styles, range: textResult.range)
        }
        
    }
    
    //MARK: - Data Detection methods
    
    private func detectLinks(text:String)->[NSTextCheckingResult]{
        //https://www.hackingwithswift.com/example-code/strings/how-to-detect-a-url-in-a-string-using-nsdatadetector
        do{
            let detector = try NSDataDetector(types: NSTextCheckingType.Link.rawValue)
            let matches = detector.matchesInString(text, options: [], range: NSRange(location: 0, length: text.characters.count))
        
            return matches
        }
        catch{
            print("\n\nerror on detectLinks\n\n")
        }
        return []
    }
    
    private func detectPhoneNumbers(text:String)->[NSTextCheckingResult]{
        do{
            let detector = try NSDataDetector(types: NSTextCheckingType.PhoneNumber.rawValue)
            let matches = detector.matchesInString(text, options: [], range: NSRange(location: 0, length: text.characters.count))
            
            return matches
        }
        catch{
            print("\n\nerror on detectLinks\n\n")
        }
        return []
    }
    
    
    //MARK: - Gestures
    
    private func addGestures(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(JLChatLabel.tapAction(_:)))
        self.addGestureRecognizer(tap)
    }
    
    func tapAction(tapGes:UITapGestureRecognizer){
        
        let positionOnlabel = tapGes.locationInView(self)
        
        if let attrText = self.attributedText{

            let textContainer = NSTextContainer(size: CGSize(width: self.frame.size.width, height: self.frame.height))
            textContainer.lineFragmentPadding = 0.0
            textContainer.lineBreakMode = self.lineBreakMode
            textContainer.maximumNumberOfLines = self.numberOfLines
            
            
            let layoutManager = NSLayoutManager()
            layoutManager.addTextContainer(textContainer)
            let textStorage = NSTextStorage(attributedString: attrText)
            textStorage.addLayoutManager(layoutManager)
            
            var frameUsedByContainer = layoutManager.usedRectForTextContainer(textContainer)
            
            frameUsedByContainer.origin = CGPoint(x: self.center.x - frameUsedByContainer.width/2, y: self.center.y - frameUsedByContainer.height/2)
            
            let xValue = (positionOnlabel.x + self.frame.origin.x) - frameUsedByContainer.origin.x
            
            let yValue = (positionOnlabel.y + self.frame.origin.y) - frameUsedByContainer.origin.y

            
            let positionOnTextContainer = CGPoint(x: xValue, y: yValue)
            
            let characterInder = layoutManager.characterIndexForPoint(positionOnTextContainer, inTextContainer: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            
            print(characterInder)
            
            let value = self.detectedDataTypes.filter({ (dataType) -> Bool in
                return NSLocationInRange(characterInder, dataType.range)
            })
            if value.count > 0{
                performActionForDataTapped(value[0])
            }
        }
        
    }
    
    private func performActionForDataTapped(dataText:NSTextCheckingResult){
        switch dataText.resultType {
        case NSTextCheckingType.Link:
            if let url = NSURL(string: (self.text as! NSString).substringWithRange(dataText.range))  where UIApplication.sharedApplication().canOpenURL(url){
                UIApplication.sharedApplication().openURL(url)
            }
            else if let url = NSURL(string: "https://\((self.text as! NSString).substringWithRange(dataText.range))") where UIApplication.sharedApplication().canOpenURL(url){
                UIApplication.sharedApplication().openURL(url)

            }
        case NSTextCheckingType.PhoneNumber:
            let number = (self.text as! NSString).substringWithRange(dataText.range)
        
            if let phoneURl = NSURL(string: "tel://\(number)"){
                UIApplication.sharedApplication().openURL(phoneURl)
            }
            
        default:
            break
        }
    }
    
}
