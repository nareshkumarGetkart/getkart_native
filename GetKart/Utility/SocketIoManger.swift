//
//  SocketIoManger.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 17/09/24.
//

import Foundation
import SocketIO

enum SocketEvents:String,CaseIterable{

    case buyerChatList = "buyerChatList"
    case sellerChatList = "sellerChatList"
    case chatMessages = "chatMessages"
    case sendMessage = "sendMessage"
    case userInfo = "userInfo"
    case getItemOffer = "getItemOffer"
    case itemOffer = "itemOffer"
    case typing = "typing"
    case messageAcknowledge = "messageAcknowledge"
    case onlineOfflineStatus = "onlineOfflineStatus"
    case updateChatList = "updateChatList"
    case blockUnblock = "blockUnblock"


    //
    case joinRoom = "joinRoom"
    case leaveRoom = "leaveRoom"
    case messageDelete = "messageDelete"
    case complimentMessages = "complimentMessages"
    case unreadNotification = "unreadNotification"
    case socketConnected = "socketConnected"
    case singleMessageDelete = "singleMessageDelete"
    case clearAllMessage = "clearAllMessage"
    
}


final class SocketIOManager: NSObject {
    
    static let sharedInstance = SocketIOManager()
    var socket:SocketIOClient?
    var manager:SocketManager?

    private override init() {
        super.init()
        
//        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
//        if objLoggedInUser.token == nil {
        if Local.shared.getUserId() == 0 {
            
        }else{
            manager = SocketManager(socketURL: URL(string:  Constant.shared.socketUrl)!, config: [.log(false), .reconnects(true),.forcePolling(true), .reconnectAttempts(-1), .forceNew(true), .secure(true), .compress, .forceWebsockets(false),.extraHeaders(["Authorization": getHeaderToken()])])
            socket = manager?.socket(forNamespace: "/chat")
        }
    }
    
    
    private func getHeaderToken() ->String{
        
        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
        if objLoggedInUser.token != nil {
            return "Bearer \(objLoggedInUser.token ?? "")"
        }
        return ""
    }
    
    
    func establishConnection(){

//        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
//        if objLoggedInUser.token == nil {
            
       if Local.shared.getUserId() == 0 {
            return
        }
        
        if socket == nil{
            manager = SocketManager(socketURL: URL(string:  Constant.shared.socketUrl)!, config: [.log(false), .reconnects(true),.forcePolling(true), .reconnectAttempts(-1), .forceNew(true), .secure(true), .compress, .forceWebsockets(false),.extraHeaders(["Authorization": getHeaderToken()])])
            socket = manager?.socket(forNamespace: "/chat")
        }
        
        socket?.removeAllHandlers()
        addListeners()
        socket?.connect()
        
        
        socket?.on(clientEvent: .connect, callback: {data, ack in
            if ISDEBUG == true {
                print("socket connected")
            }
            //Unread notififcation
//            let params = ["sender":Local.shared.getUserId()]
//            SocketIOManager.sharedInstance.emitEvent(SocketEvents.unreadNotification.rawValue, params)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.socketConnected.rawValue), object: nil, userInfo: nil)
        })
        
        socket?.on(clientEvent: .error) {data, ack in
            print("socket disconnect with Error \(data) \(ack)")
           // DispatchQueue.global(qos: .background).async {
               // self.socket?.connect()
               // self.socket = nil
                Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_SELLER = true
                Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true
           // }
        }
        
        socket?.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnect client \(data) \(ack)")
          //  DispatchQueue.global(qos: .background).async {
              //  self.socket?.connect()
               // self.socket = nil
           // }
        }
    }
    
    
    func emitEvent(_ event : String, _ param : Dictionary<String,Any>){
       
        if (UIApplication.shared.delegate as! AppDelegate).isInternetConnected == false{
            AlertView.sharedManager.showToast(message: "No internet connection")
            return
        }
        
        if ISDEBUG == true {
            print("socketURL",socket?.manager?.socketURL ?? "")
            print("nsps",socket?.manager?.nsps ?? "")
            print("event: ",event,"param: ", param)
        }
        
        socket?.emit(event, param )
    }
    
    
    func addListeners(){
        
        guard let socket1 = self.socket else {
            print("Socket not ready!")
            return
        }
        socket?.on(SocketEvents.getItemOffer.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.getItemOffer.rawValue) responseDict =>\(responseDict.printAsJSON())")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.getItemOffer.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket?.on(SocketEvents.buyerChatList.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.buyerChatList.rawValue) responseDict =>\(responseDict.printAsJSON())")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.buyerChatList.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket?.on(SocketEvents.sellerChatList.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.sellerChatList.rawValue) responseDict =>\(responseDict.printAsJSON())")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.sellerChatList.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        
        socket?.on(SocketEvents.updateChatList.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.updateChatList.rawValue) responseDict =>\(responseDict)")
                    
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.updateChatList.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket?.on(SocketEvents.itemOffer.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.itemOffer.rawValue) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.itemOffer.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket?.on(SocketEvents.chatMessages.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.chatMessages.rawValue) responseDict =>\(responseDict.printAsJSON())")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.chatMessages.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket?.on(SocketEvents.sendMessage.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.sendMessage.rawValue) responseDict =>\(responseDict)")
                }

                Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_SELLER = true
                Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.sendMessage.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket?.on(SocketEvents.joinRoom.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.joinRoom.rawValue) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.joinRoom.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket?.on(SocketEvents.typing.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.typing.rawValue) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.typing.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket?.on(SocketEvents.messageAcknowledge.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.messageAcknowledge.rawValue) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.messageAcknowledge.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket?.on(SocketEvents.messageDelete.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.messageDelete.rawValue) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.messageDelete.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket?.on(SocketEvents.onlineOfflineStatus.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.onlineOfflineStatus.rawValue) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.onlineOfflineStatus.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }

        socket?.on(SocketEvents.complimentMessages.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.complimentMessages.rawValue) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.complimentMessages.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket?.on(SocketEvents.userInfo.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.userInfo.rawValue) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.userInfo.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
               
        
        socket?.on(SocketEvents.blockUnblock.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.blockUnblock.rawValue) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.blockUnblock.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket?.on(SocketEvents.unreadNotification.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.unreadNotification.rawValue) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.unreadNotification.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket?.on(SocketEvents.singleMessageDelete.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.singleMessageDelete.rawValue) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.singleMessageDelete.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket?.on(SocketEvents.clearAllMessage.rawValue) { data, ack in
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(SocketEvents.clearAllMessage.rawValue) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.clearAllMessage.rawValue), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
    }
}



class SocketParser {

    static func convert<T: Decodable>(data: Any) throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let decoder = JSONDecoder()
        do{
           let  _ = try decoder.decode(T.self, from: jsonData)
            
        }catch{
            print("CheckError \(error)")
        }
        return try decoder.decode(T.self, from: jsonData)
    }

}


extension Data
{
    func printJSON()
    {
        if let JSONString = String(data: self, encoding: String.Encoding.utf8)
        {
            print(JSONString)
        }
    }
}


extension NSDictionary{
    
  func printAsJSON(){
      do{
          // Serialize to JSON
          let jsonData = try JSONSerialization.data(withJSONObject: self)
          
          // Convert to a string and print
          if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
              print(JSONString)
          }
      } catch  {
          print(error.localizedDescription)
      }
    }
}

