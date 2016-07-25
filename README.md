# JLChatViewController

[![CI Status](http://img.shields.io/travis/José Lucas/JLChatViewController.svg?style=flat)](https://travis-ci.org/José Lucas/JLChatViewController)
[![Version](https://img.shields.io/cocoapods/v/JLChatViewController.svg?style=flat)](http://cocoapods.org/pods/JLChatViewController)
[![License](https://img.shields.io/cocoapods/l/JLChatViewController.svg?style=flat)](http://cocoapods.org/pods/JLChatViewController)
[![Platform](https://img.shields.io/cocoapods/p/JLChatViewController.svg?style=flat)](http://cocoapods.org/pods/JLChatViewController)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

If you want to use this framework you will need at least IOS 8!

## Installation

JLChatViewController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
    pod "JLChatViewController"
```
## News on version 2.0.0

##### *CPU usage improvements*

    IMPORTANT =  These and other improvements made necessary some changes on implementations of delegates, some methods were deprecated , so its important you take a look again on example project to make the right corrections.


##### *Customization improvements*
    
    - Now you can use your own bubble form images with simple and fast configuration
    
    - Now you can add custom header views for example use your own Date Header View, use one for indicating the number of unread messages


##### *Animations improvements*

##### *New component added*
    `JLChatLabel` was added to substitute the `JLChatTextView` on `JLTextMessageCell` specially for performance.I advice you to use `JLChatLabel` instead of `JLChatTextView` when possible .

##### *Some methods were deprecated*


## Initial Configurations
##### *First Step*

      Import it on every file that you will use this framework.

```swift
import JLChatViewController
```
##### *Second Step*
      Call this method on AppDelegate for you load the `JLChat.storyboard`, but you can call it where you prefer.
```swift
JLBundleController.loadJLChatStoryboard()
```
##### *Third Step*
      Your ViewController that will have the chat must inherit from `JLChatViewController` and implement all these protocols: 
        `ChatDataSource`,`ChatToolBarDelegate`,`JLChatMessagesMenuDelegate`,`ChatDelegate`.
        
##### *Fourth Step*
      Find `JLChat.storyboard` open it, choose the ViewController and put your ViewController that inherits from `JLChatViewController` as the class of this one.
      

##### *Fith Step*(Added on version 2.0.0)

    You will need some way to know the correctly number of sections(Date sections and/or custom sections), the number of messages by section on your chat. 
    If you have some doubt about it take a look on Mark `Chat messages by section methods` of MyViewController
    
    


## Quick Tips
##### *Configuring your messages*
    Change the parameters values as you prefer
    The example project has some ways of customization implemented

-If you want to use custom bubbles images
    I advise you to use images with 32x32 pixels for @1x
```swift
JLChatAppearence.configIncomingMessages(WithCustomBubbleImage: UIImage(named: "custom-incomingBubble"), customBubbleInsets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14), bubbleImageMask: UIImage(named: "custom-incomingBubbleMask"), bubbleMaskInsets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14), incomingBubbleColor: nil, showIncomingSenderImage: true, incomingTextColor: nil)

JLChatAppearence.configOutgoingMessages(WithCustomBubbleImage: UIImage(named: "custom-outgoingBubble"), customBubbleInsets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14), bubbleImageMask: UIImage(named: "custom-outgoingBubbleMask"), bubbleMaskInsets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14), outgoingBubbleColor: nil, showOutgoingSenderImage: true, outgoingTextColor: nil)

```
-If you want to use default bubbles images
```swift
JLChatAppearence.configIncomingMessages(nil, showIncomingSenderImage: true, incomingTextColor: nil)

JLChatAppearence.configOutgoingMessages(nil, showOutgoingSenderImage: true, outgoingTextColor: nil)
```

-This method is optional, it is normally used when you are using 
custom bubbles images, but fell free to use it when ever you want.
```swift
JLChatAppearence.configAligment(5, vertivalDistBetweenImgBottom_And_BubbleBottom: 10)
```

-This method is optional, it is normally used when you are using 
custom bubbles images, but fell free to use it when ever you want.
```swift
JLChatAppearence.configTextAlignmentOnBubble(IncomingMessTextAlig: UIEdgeInsets(top: 8, left: 10, bottom: 13, right: 8), AndOutgoingMessTextAlig: UIEdgeInsets(top: 8, left: 8, bottom: 13, right: 10))
```


```swift
JLChatAppearence.configSenderImage(nil, senderImageCornerRadius: nil, senderImageBackgroundColor: nil, senderImageDefaultImage: nil)


JLChatAppearence.configErrorButton(nil, selectedStateImage: nil)

```

##### *Adding new message*
    More information take a look on documentation
```swift
public func addNewMessages(quant:Int,changesHandler:()->(),completionHandler:(()->())?)
```


##### *Adding old messages*
```swift
public func addOldMessages(quant:Int,changesHandler:()->())
```


##### *Removing one message cell*
```swift
public func removeMessageCellAtIndexPath(indexPath:NSIndexPath,relatedMessage:JLMessage!)
```

##### *Removing one section(Date section or custom section)*
```swift
public func removeChatSection(section:Int,messagesOfSection:[JLMessage]?)
```

##### *Removing more than one message cell and or more than one section*
```swift
public func removeMessagesCells(rowsIndexPath:[NSIndexPath]?,AndSections sections:[Int]?,WithRelatedMessages relatedMessages:[JLMessage]?)
```


##### *Updating a message cell send status*
```swift
public func updateMessageStatusOfCellAtIndexPath(indexPath:NSIndexPath,message:JLMessage)
```
##### *Open your chat ViewController*

 Use it to open your Chat ViewController
```swift
if let vc = JLBundleController.instantiateJLChatVC() as? /*Name of your ViewController that inherits from            JLChatViewController*/{
            
      vc.view.frame = self.view.frame
            
      let chatSegue = UIStoryboardSegue(identifier: "identifier name", source: self, destination: vc, performHandler: { () -> Void in
                
            self.navigationController?.pushViewController(vc, animated: true)
      })
            
      self.prepareForSegue(chatSegue, sender: nil)
            
      chatSegue.perform()
}
```

## Creating a custom cell

##### *First Step*

      Create a class that inherits from `JLChatMessageCell` and implement all necessary methods , more details on example project
      
##### *Second Step*
      
      Create a .xib file that have a `UITableViewCell` and add all necessary views, more details on example project.
      Attention! there are some constraints of errorButton and senderImageView that must have to exist, for everything works well , more details take a look on custom cell of the example project.
      
##### *Third Step*
      
      Register them on your chat tableView
      
```swift
self.chatTableView.registerNib(UINib(nibName: "nib name", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "identifier")
```
##### *Fourth Step*
      implement the method of `ChatDataSource` that is for custom cells
  
```swift
func chat(chat: JLChatTableView, customMessageCellForRowAtIndexPath indexPath: NSIndexPath) -> JLChatMessageCell {


      ...
        
      var cell:JLChatMessageCell!
      if message.senderID == self.chatTableView.myID{
            cell = self.chatTableView.dequeueReusableCellWithIdentifier("your identifier for outgoing message") as! CellName
      }
      else{
            cell = self.chatTableView.dequeueReusableCellWithIdentifier("your identifier for incoming message") as! CellName

      }
        
        
      return cell
        
}
```

## Creating a custom Header View

##### *First Step*

Create a .xib file that have a `UIView` and add all necessary views, more details on example project.

##### *Second Step*

Register it on your chat tableView

```swift
self.chatTableView.registerNib(UINib(nibName: "nib name", bundle: NSBundle.mainBundle()), forHeaderFooterViewReuseIdentifier: "identifier")
```
##### *Third Step*
implement the methods of `ChatDataSource` that is for custom cells

```swift
func jlChatCustomHeaderInSection(section:Int)->UIView?


func jlChatHeightForCustomHeaderInSection(section:Int)->CGFloat
```


## Author

José Lucas, chagasjoselucas@gmail.com

## License

JLChatViewController is available under the MIT license. See the LICENSE file for more info.
