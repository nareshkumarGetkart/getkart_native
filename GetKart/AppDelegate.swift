//
//  AppDelegate.swift
//  GetKart
//
//  Created by gurmukh singh on 2/19/25.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseMessaging
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
   
    let reachability = Reachability()!
    var isInternetConnected:Bool=Bool()
    var byreachable : String = String()
    @objc static let sharedInstance = UIApplication.shared.delegate as! AppDelegate
    var window: UIWindow?
    var navigationController: UINavigationController?
    var sharedProfileID = ""
    var notificationType = ""
    var userId = ""
    var roomId = ""
    var settingsModel:SettingsModel?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        getSettingsApi()
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        self.window = UIWindow(frame: UIScreen.main.bounds)
        navigationController = UINavigationController()
        self.navigationController?.isNavigationBarHidden = true
        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
        if objLoggedInUser.id != nil {
            print(objLoggedInUser)
            let landingVC = StoryBoard.main.instantiateViewController(withIdentifier: "HomeBaseVC") as! HomeBaseVC
            self.navigationController?.viewControllers = [landingVC]
        }else  {
            
            let  isFirstTime = UserDefaults.standard.object(forKey: "isFirstTime") as? Bool ?? true
            if isFirstTime == true {
                UserDefaults.standard.set(false, forKey: "isFirstTime")
                UserDefaults.standard.synchronize()
                let vc = UIHostingController(rootView: DemoView())
            vc.view.setNeedsUpdateConstraints()
                self.navigationController?.viewControllers = [vc]
           }else {
                let landingVC = StoryBoard.preLogin.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.viewControllers = [landingVC]
            }
        }
        /*
        let landingVC = StoryBoard.preLogin.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.viewControllers = [landingVC]
        */
        self.navigationController?.navigationBar.isHidden = true
        self.window?.setRootViewController(self.navigationController!, options: .init(direction: .fade, style: .easeOut))
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        reachabilityListener()
        registerForRemoteNotification(application: application)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
   
    }
    
    func applicationDidEnterBackground(_ application: UIApplication){
        print("applicationDidEnterBackground")
    }
        
    func applicationWillEnterForeground(_ application: UIApplication){
        print("applicationWillEnterForeground")
        checkSocketStatus()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        checkSocketStatus()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
        if objLoggedInUser.token != nil {
            
            var bgTask: UIBackgroundTaskIdentifier = .invalid
            bgTask = UIApplication.shared.beginBackgroundTask {
                // Cleanup when time expires
                UIApplication.shared.endBackgroundTask(bgTask)
                bgTask = .invalid
            }
            
            SocketIOManager.sharedInstance.socket?.disconnect()
            print("applicationWillTerminate")
            
            UIApplication.shared.endBackgroundTask(bgTask)
            bgTask = .invalid
        }
    }
    
    
    func checkSocketStatus(){
        
        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
        if objLoggedInUser.token == nil {
            return
        }
        
        switch SocketIOManager.sharedInstance.socket?.status{
            
        case .disconnected:
            SocketIOManager.sharedInstance.establishConnection()
            return
        case .notConnected:
            SocketIOManager.sharedInstance.establishConnection()
            return
        case .connecting:
            SocketIOManager.sharedInstance.establishConnection()
            return
            
        default:
            if (SocketIOManager.sharedInstance.socket == nil){
                SocketIOManager.sharedInstance.establishConnection()
            }
            break
        }
    }
     
    
    func reachabilityListener(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        if reachability.isReachable {
            isInternetConnected=true
          //  Themes.sharedInstance.showWaitingNetwork(true, state: true)
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
                byreachable = "1"
            } else {
                print("Reachable via Cellular")
                byreachable = "2"
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.reconnectInternet.rawValue), object: nil , userInfo: nil)
            if Local.shared.getUserId().count > 0 {
            
               SocketIOManager.sharedInstance.establishConnection()
            }
        } else {
            isInternetConnected=false
            //Themes.sharedInstance.showWaitingNetwork(true, state: false)
            print("Network not reachable")
            byreachable = ""
           // NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.noInternet.rawValue), object: nil , userInfo: nil)
        }
    }
}


extension AppDelegate:UNUserNotificationCenterDelegate,MessagingDelegate{
    
    
 
    func registerForRemoteNotification(application:UIApplication){
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
              Local.shared.saveFCMToken(token: token)
          //  self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
          }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if ISDEBUG == true {
            print("Firebase registration token: \(String(describing: fcmToken))")
        }
        
        if let fcm = fcmToken{
            Local.shared.saveFCMToken(token: fcm)
        }

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      Messaging.messaging().apnsToken = deviceToken
    }
    

    
     
   
    func  navigateToNotificationType() {
        print("didReceive")
       
        /*switch notificationType{
            
        case "messages","gifts":
            if let destVc = self.navigationController?.topViewController as? ChatVC{
                
                if destVc.senderId == userId{
                    
                }else{
                    
                    AppDelegate.sharedInstance.navigationController?.popViewController(animated: false)
                    let vc = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                    vc.recieverId = userId
                    vc.senderId = Local.shared.getUserId()
                    vc.roomId = roomId
                    AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
                }
            }else{
                    let vc = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                    vc.recieverId = self.userId
                    vc.senderId = Local.shared.getUserId()
                    vc.roomId = self.roomId
                    AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
                
            }
            
        case "likes":
            do {
                    AppDelegate.sharedInstance.needToRefreshLikedYou()
                    let destVC:LikesYouVC = StoryBoard.main.instantiateViewController(withIdentifier: "LikesYouVC") as! LikesYouVC
                    destVC.isToHideBackButton = false
                    destVC.isToRefreshList = true
                    AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
            }
        case "profileVisitors":
            do {
                    
                    let destVC:NotificationListVC = StoryBoard.chat.instantiateViewController(withIdentifier: "NotificationListVC") as! NotificationListVC
                    AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
                
            }
            
        case "match":
            do{
                    for vc in AppDelegate.sharedInstance.navigationController?.viewControllers ?? []{
                        
                        if let destVC = vc as? HomeBaseVC {
                            destVC.selectedIndex = 1
                            destVC.setSelectedImages(index: 1)
                            if let  navVC = destVC.viewControllers?[1] {
                                for vc in navVC.navigationController?.viewControllers ?? [] {
                                    if vc is HomeBaseVC{
                                        destVC.navigationController?.popToViewController(vc, animated: true)
                                    }
                                }
                            }
                            
                        }
                    }
            }
        case "userImageReject":
            do {
                
                if let destVc = self.navigationController?.topViewController as? ProfileEditVC{
                    destVc.getCompleteProfile()
                }else{
                        
                        if let destVC:ProfileEditVC = StoryBoard.settings.instantiateViewController(withIdentifier: "ProfileEditVC") as? ProfileEditVC{
                            AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
                        }
                    
                }
            }
            break
            
        case "verifyGesture","boost","Premium","PremiumPlus":
            do {
                    
                    for vc in AppDelegate.sharedInstance.navigationController?.viewControllers ?? []{
                        if let destVC = vc as? HomeBaseVC {
                            destVC.setSelectedImages(index: 4)
                            if let  navVC = destVC.viewControllers?[4] {
                                for vc in navVC.navigationController?.viewControllers ?? [] {
                                    if vc is HomeBaseVC{
                                        if let  navVC = destVC.viewControllers?[4] {
                                            destVC.navigationController?.popToViewController(vc, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
            }
            break
            
        case "verifyDocument":
            do {
                    
                    for vc in AppDelegate.sharedInstance.navigationController?.viewControllers ?? []{
                        if let destVC = vc as? HomeBaseVC {
                            destVC.setSelectedImages(index: 4)
                            if let  navVC = destVC.viewControllers?[4] {
                                for vc in navVC.navigationController?.viewControllers ?? [] {
                                    if vc is HomeBaseVC{
                                        if let  navVC = destVC.viewControllers?[4] {
                                            destVC.navigationController?.popToViewController(vc, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
            }
            break
        default:
            break
        }*/
    }

    func userNotificationCenter(_ a: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if Local.shared.getUserId().count == 0 {
            
        }else{
            //checkSocketStatus()
            print("didReceive")
            print("NOTIFICATION TAPPED === \(response.notification.request.content.userInfo)")
            
            notificationType =  response.notification.request.content.userInfo["notificationType"] as? String ?? ""
            userId =  response.notification.request.content.userInfo["userId"] as? String ?? ""
            roomId =  response.notification.request.content.userInfo["roomId"] as? String ?? ""
            
            print("notificationType == \(notificationType)")
            print("userId == \(userId)")
            print("roomId == \(roomId)")
            
            if Constant.shared.isLaunchFirstTime == 0 {
               //isLaunchFirstTime = 1 means first at launch time and 0 means after launch tapped on notification
                self.navigateToNotificationType()
            }
        }
    }
    
    
    func needToRefreshLikedYou(){
        
    //NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotificationKeys.refreshLikeList.rawValue), object: nil, userInfo: nil)

    }
    
    //This is key callback to present notification while the app is in foreground

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("willPresent")
        
        print(notification.request.content)
        let  notificationType =  notification.request.content.userInfo["notificationType"] as? String ?? ""
        let  userId =  notification.request.content.userInfo["userId"] as? String ?? ""
        
      /*  if notificationType == "messages" ||  notificationType == "gifts"{
            if let destVc = self.navigationController?.topViewController as? ChatVC{
                
                if destVc.recieverId == userId{
                    
                }else{
                    //completionHandler( [.alert,.sound,.badge])
                    completionHandler([.banner, .list, .sound])

                    //self.playSound()

                }
                
            }else{
                self.playSound()
                completionHandler([.banner, .list, .sound])

               // completionHandler( [.alert,.sound,.badge])

            }
        } else{
            self.playSound()
           // completionHandler( [.alert,.sound,.badge])
            completionHandler([.banner, .list, .sound])

            
        }
        */
        
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void)
    {
        //Handle the notification
        completionHandler(
            [UNNotificationPresentationOptions.banner,
             UNNotificationPresentationOptions.sound,
             UNNotificationPresentationOptions.sound])
    }
    
    
    
    func logoutFromApp(){
        Local.shared.isLogout = true
        Local.shared.removeUserData()
        //DBManager.deleteRecords()
        AppDelegate.sharedInstance.navigationController?.popToRootViewController(animated: true)
    }
    
    func showLoginScreen(){
        AppDelegate.sharedInstance.navigationController?.viewControllers.removeAll()
        let landingVC = StoryBoard.preLogin.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        AppDelegate.sharedInstance.navigationController?.viewControllers = [landingVC]
    }
    
    func getSettingsApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: Constant.shared.get_system_settings) { (obj:SettingsParse) in
            
            if (obj.code ?? 0) == 200 {
                self.settingsModel = obj.data
                Local.shared.currencySymbol = obj.data?.currencySymbol ?? "₹"
                
            }
            
        }
    }
   
    
}

