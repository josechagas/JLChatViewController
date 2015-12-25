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
##### *First Step*
      
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
      
## Quick Tips
##### *Configuring your messages*
      Change the parameters values as you prefer
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
      self.chatTableView.addOldMessages(/*the number of old messages that will be added*/)
      ```

##### *Removing a message*
      ```swift
      self.chatTableView.removeMessage(/* the indexPath of the cell in chat tableView*/)
      ```

##### *Updating a message cell send status*
      ```swift
      self.chatTableView.updateMessageStatusOfCellAtIndexPath(/* the indexPath of the cell in chat tableView*/,             message:/*the message(JLMessage) related to the cell at indexPath*/)
      ```
##### *Open your chat ViewController*
      ```swift
      if let vc = JLBundleController.instantiateJLChatVC() as? /*Name of your ViewController that inherits from             JLChatViewController*/{
            
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
        
       /*...*/
        
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


## Author

José Lucas, joselucas1994@yahoo.com.br

## License

JLChatViewController is available under the MIT license. See the LICENSE file for more info.
