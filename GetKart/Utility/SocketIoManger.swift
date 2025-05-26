//
//  SocketIoManger.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 17/09/24.
//

import Foundation
import SocketIO
/*
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

       if Local.shared.getUserId() == 0 {
            return
        }
        
        if socket == nil{
            manager = SocketManager(socketURL: URL(string:  Constant.shared.socketUrl)!, config: [.log(false), .reconnects(true),.forcePolling(true), .reconnectAttempts(-1), .forceNew(true), .secure(true), .compress, .forceWebsockets(false),.extraHeaders(["Authorization": getHeaderToken()])])
            socket = manager?.socket(forNamespace: "/chat")
        }
           
        socket?.on(clientEvent: .connect, callback: {data, ack in
            if ISDEBUG == true {
                print("socket connected")
            }
            self.socket?.removeAllHandlers()
            self.addListeners()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.socketConnected.rawValue), object: nil, userInfo: nil)
        })
        
        socket?.on(clientEvent: .error) {data, ack in
            print("socket disconnect with Error \(data) \(ack)")
     
                Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_SELLER = true
                Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true
        }
        
        socket?.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnect client \(data) \(ack)")
          
        }
        socket?.connect()

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
        
      /*  socket?.on(SocketEvents.messageDelete.rawValue) { data, ack in
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
        */

     
        
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
        
       /* socket?.on(SocketEvents.unreadNotification.rawValue) { data, ack in
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
        }*/
    }
}

*/
import Foundation
import SocketIO



enum SocketEvents: String, CaseIterable {
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
    case joinRoom = "joinRoom"
    case leaveRoom = "leaveRoom"
    case socketConnected = "socketConnected"
}

final class SocketIOManager: NSObject {

    static let sharedInstance = SocketIOManager()
    var socket: SocketIOClient?
    var manager: SocketManager?

    private override init() {
        super.init()
        if Local.shared.getUserId() > 0 {
            initializeSocket()
        }
    }

    private func initializeSocket() {
        guard let url = URL(string: Constant.shared.socketUrl) else {
            print("Invalid socket URL")
            return
        }
        let headers = ["Authorization": getHeaderToken()]
        manager = SocketManager(socketURL: url, config: [.log(false), .reconnects(true), .forcePolling(true), .reconnectAttempts(-1), .forceNew(true), .secure(true), .compress, .forceWebsockets(false), .extraHeaders(headers)])
        socket = manager?.socket(forNamespace: "/chat")
    }

    private func getHeaderToken() -> String {
        let user = RealmManager.shared.fetchLoggedInUserInfo()
        return "Bearer \(user.token ?? "")"
    }

    func establishConnection() {
        guard Local.shared.getUserId() > 0 else {
            print("User not logged in. Skipping socket connection.")
            return
        }

        if socket == nil {
            initializeSocket()
        }

        guard let socket = socket else {
            print("Socket not initialized. Cannot connect.")
            return
        }

        socket.on(clientEvent: .connect) { [weak self] data, ack in
            print("Socket connected")
            guard let self = self else { return }
            self.socket?.removeAllHandlers()
            self.addListeners()
            NotificationCenter.default.post(name: Notification.Name(SocketEvents.socketConnected.rawValue), object: nil)
        }

        socket.on(clientEvent: .error) { data, ack in
            print("Socket error: \(data)")
        }

        socket.on(clientEvent: .disconnect) { data, ack in
            print("Socket disconnected: \(data)")
        }

        socket.connect()
    }

    func emitEvent(_ event: String, _ param: Dictionary<String, Any>) {
        guard AppDelegate.sharedInstance.isInternetConnected else {
            AlertView.sharedManager.showToast(message: "No internet connection")
            return
        }
        guard let socket = socket else {
            print("Emit failed. Socket is nil.")
            return
        }
        print("Emitting event: \(event) with params: \(param)")
        socket.emit(event, param)
    }

    func safeOn(event: String, callback: @escaping NormalCallback) {
        guard let socket = socket else {
            print("Add handler failed. Socket is nil for event: \(event)")
            return
        }
        socket.on(event, callback: callback)
    }

    func addListeners() {
        for event in SocketEvents.allCases {
            let eventName = event.rawValue
            safeOn(event: eventName) { data, ack in
                guard let dict = data.first as? [AnyHashable: Any] else {
                    print("Invalid payload for event: \(eventName)")
                    return
                }
                NotificationCenter.default.post(name: Notification.Name(eventName), object: nil, userInfo: dict)
            }
        }
    }

    func disconnect() {
        
        if let sockett = self.socket{
            socket?.removeAllHandlers()
            socket?.disconnect()
            socket = nil
            manager = nil
       
        }
    }
    
    func checkSocketStatus() {
       guard Local.shared.getUserId() > 0 else {
           print("User not logged in. Skipping socket check.")
           return
       }

       guard let socket = socket else {
           print("Socket is nil. Reinitializing connection.")
           establishConnection()
           return
       }

       switch socket.status {
       case .connected:
           print("Socket is already connected. No action needed.")
           return
       case .disconnected, .notConnected, .connecting:
           print("Socket is not connected. Attempting to reconnect...")
           establishConnection()
       @unknown default:
           print("Unknown socket status. Reinitializing just in case.")
           establishConnection()
       }
   }

}

/*
import Foundation
import SocketIO

enum SocketEvents: String, CaseIterable {
    case buyerChatList, sellerChatList, chatMessages, sendMessage, userInfo, getItemOffer
    case itemOffer, typing, messageAcknowledge, onlineOfflineStatus, updateChatList
    case blockUnblock, joinRoom, leaveRoom, messageDelete, complimentMessages
    case unreadNotification, socketConnected, singleMessageDelete, clearAllMessage
}

final class SocketIOManager: NSObject {

    static let sharedInstance = SocketIOManager()
    var socket: SocketIOClient?
    var manager: SocketManager?

    private override init() {
        super.init()
        configureSocketIfNeeded()
    }

    private func getHeaderToken() -> String {
        guard let token = RealmManager.shared.fetchLoggedInUserInfo().token else { return "" }
        return "Bearer \(token)"
    }

    private func configureSocketIfNeeded() {
        guard Local.shared.getUserId() != 0 else { return }

        let headers = ["Authorization": getHeaderToken()]
        let config: SocketIOClientConfiguration = [
            .log(false), .reconnects(true), .forcePolling(true),
            .reconnectAttempts(-1), .forceNew(true), .secure(true),
            .compress, .forceWebsockets(false), .extraHeaders(headers)
        ]

        manager = SocketManager(socketURL: URL(string: Constant.shared.socketUrl)!, config: config)
        socket = manager?.socket(forNamespace: "/chat")
    }

    func establishConnection() {
        guard Local.shared.getUserId() != 0 else { return }

        if socket == nil {
            configureSocketIfNeeded()
        }

    
        guard let socket = socket else {
            print("⚠️ Socket is nil after config.")
            return
        }

        socket.removeAllHandlers()
        addListeners()

        socket.on(clientEvent: .connect) { [weak self] data, ack in
            print("✅ Socket connected")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SocketEvents.socketConnected.rawValue), object: nil)
        }

        socket.on(clientEvent: .error) { data, ack in
            print("❌ Socket error: \(data)")
            Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_SELLER = true
            Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true
        }

        socket.on(clientEvent: .disconnect) { data, ack in
            print("🔌 Socket disconnected: \(data)")
        }

        socket.connect()
    }

    func emitEvent(_ event: String, _ params: [String: Any]) {
        guard (UIApplication.shared.delegate as? AppDelegate)?.isInternetConnected == true else {
            AlertView.sharedManager.showToast(message: "No internet connection")
            return
        }

        print("📤 Emitting: \(event), params: \(params)")
        socket?.emit(event, params)
    }

    private func post(event: SocketEvents, data: [Any]) {
        guard let dict = data.first as? NSDictionary else { return }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: event.rawValue), object: nil, userInfo: dict as? [AnyHashable: Any])
    }

    func addListeners() {
        guard let socket = socket else {
            print("❗️ Socket is not initialized")
            return
        }

        SocketEvents.allCases.forEach { event in
            socket.on(event.rawValue) { data, ack in
                if ISDEBUG { print("📨 \(event.rawValue): \(data.first ?? "")") }
                self.post(event: event, data: data)
            }
        }
    }
}
*/

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

