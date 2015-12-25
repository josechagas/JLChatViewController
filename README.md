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

## Initial Configurations
  
  -> First Step:
      Import it on every file that you will you this framework
      ```swift
      import JLChatViewController
      ```
  -> Second Step:
      Call this method on AppDelegate for you load the `JLChat.storyboard`, but you can call it where you prefer.
      ```swift
      JLBundleController.loadJLChatStoryboard()
      ```
  -> Third Step:
      Your ViewController that will have the chat must inherit from `JLChatViewController` and implement all these protocols: 
        `ChatDataSource`,`ChatToolBarDelegate`,`JLChatMessagesMenuDelegate`,`ChatDelegate`.
        
  -> Fourth Step:
      Find `JLChat.storyboard` open it choose the ViewController and put your ViewController that inherits from `JLChatViewController` as the class of this one.
      
## Quick Tips
##### *Configuring your messages*

```swift
JLChatAppearence.configIncomingMessages(nil, showIncomingSenderImage: true, incomingTextColor: nil)
        
JLChatAppearence.configOutgoingMessages(nil, showOutgoingSenderImage: true, outgoingTextColor: nil)
  
JLChatAppearence.configChatFont(nil) { (indexPath) -> Bool in
            
    if indexPath.row % 3 == 0{
       return true
    }
    return false
}

```

##### *Adding new message*

```swift
  self.chatTableView.addNewMessage()
```

##### *Adding old messages*
```swift
  self.chatTableView.addOldMessages(20/*the number of old messages that will be added*/)
```

##### *Removing a message*
```swift
  self.chatTableView.removeMessage(indexPath/* the position of the cell in chat tableView*/)
```

##### *Updating a message cell send status*
```swift
  self.chatTableView.updateMessageStatusOfCellAtIndexPath(indexPath, message: message/*the message related to the cell at indexPath*/)
```
##### *Open your chat ViewController*
```swift
if let vc = JLBundleController.instantiateJLChatVC() as? /*Name of your ViewController that inherits from JLChatViewController*/{
            
    vc.view.frame = self.view.frame
            
    let chatSegue = UIStoryboardSegue(identifier: "ChatListVCToChatVC", source: self, destination: vc, performHandler: { () -> Void in
                
        self.navigationController?.pushViewController(vc, animated: true)
    })
            
    self.prepareForSegue(chatSegue, sender: nil)
            
    chatSegue.perform()
}
```



## Author

José Lucas, joselucas1994@yahoo.com.br

## License

JLChatViewController is available under the MIT license. See the LICENSE file for more info.
