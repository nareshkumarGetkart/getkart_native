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
import Kingfisher


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
   
    let reachability = Reachability()
    var isInternetConnected:Bool=Bool()
    var byreachable : String = String()
  //  @objc static let sharedInstance = UIApplication.shared.delegate as! AppDelegate
    static var sharedInstance: AppDelegate {
        return UIApplication.shared.delegate as? AppDelegate ?? AppDelegate()
    }

    var window: UIWindow?
    var navigationController: UINavigationController?
    var sharedProfileID = ""
    var notificationType = ""
    var userId = 0
    var roomId = 0
    var itemId = 0
    
   // var settingsModel:SettingsModel?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.overrideUserInterfaceStyle = .light
        navigationController = UINavigationController()
        self.navigationController?.isNavigationBarHidden = true

        
        //  DispatchQueue.global().async {
               self.setupKingfisherSettings()
           //    self.getSettingsApi()
          //}

        if let updateChecker : ATAppUpdater =  ATAppUpdater.sharedUpdater() as? ATAppUpdater{
            updateChecker.delegate = self
            updateChecker.showUpdateWithForce()
        }
   
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        reachabilityListener()
        registerForRemoteNotification(application: application)

        
        if Local.shared.getUserId() > 0{
   

            if let landingVC = StoryBoard.main.instantiateViewController(withIdentifier: "HomeBaseVC") as? HomeBaseVC{
                self.navigationController?.viewControllers = [landingVC]
            }
            
        }else{
            
            let  isFirstTime = UserDefaults.standard.object(forKey: "isFirstTime") as? Bool ?? true
            if isFirstTime == true {
                UserDefaults.standard.set(false, forKey: "isFirstTime")
                UserDefaults.standard.synchronize()
                let vc = UIHostingController(rootView: DemoView())
                vc.view.setNeedsUpdateConstraints()
                self.navigationController?.viewControllers = [vc]
            }else {
                if let landingVC = StoryBoard.preLogin.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC{
                    self.navigationController?.viewControllers = [landingVC]
                }
            }
        }
        
        self.navigationController?.navigationBar.isHidden = true
        self.window?.setRootViewController(self.navigationController!, options: .init(direction: .fade, style: .easeOut))
        
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        
        // Handle notification if app was launched by tapping a push notification
           if let remoteNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
               print("Notification Launch Payload: \(remoteNotification)")

               self.notificationType = remoteNotification["type"] as? String ?? ""
               self.userId = Int(remoteNotification["sender_id"] as? String ?? "0") ?? 0
               self.roomId = Int(remoteNotification["item_offer_id"] as? String ?? "0") ?? 0
               self.itemId = Int(remoteNotification["item_id"] as? String ?? "0") ?? 0

               if self.userId == 0 {
                   self.userId = Int(remoteNotification["user_id"] as? String ?? "0") ?? 0
               }
               if self.userId == 0 {
                   self.userId = Int(remoteNotification["seller_id"] as? String ?? "0") ?? 0
               }

               Constant.shared.isLaunchFirstTime = 1
           }
        
        return true
    }
    
    
    //MARK: Other helpfule Methods
    fileprivate func setupKingfisherSettings() {
       
    /*    // Limit memory cache size to 300 MB.
        KingfisherManager.shared.cache.memoryStorage.config.totalCostLimit = 1

        // Limit memory cache to hold 150 images at most.
        KingfisherManager.shared.cache.memoryStorage.config.countLimit = 150
        
        // Limit disk cache size to 1 GB.
        KingfisherManager.shared.cache.diskStorage.config.sizeLimit = 1000 * 1024 * 1024
      
        // Check memory clean up every 30 seconds.
        KingfisherManager.shared.cache.memoryStorage.config.cleanInterval = 5
        
        // ImageCache.default.diskStorage.config.expiration = .days(5)
        KingfisherManager.shared.cache.cleanExpiredMemoryCache()
        KingfisherManager.shared.cache.cleanExpiredDiskCache()*/
        
        // Limit memory cache size to 300 MB.
        KingfisherManager.shared.cache.memoryStorage.config.totalCostLimit = 1

        // Limit memory cache to hold 150 images at most.
        KingfisherManager.shared.cache.memoryStorage.config.countLimit = 150
        
        // Limit disk cache size to 1 GB.
        KingfisherManager.shared.cache.diskStorage.config.sizeLimit = 1000 * 1024 * 1024
      
        // Check memory clean up every 30 seconds.
        KingfisherManager.shared.cache.memoryStorage.config.cleanInterval = 5
        
        // ImageCache.default.diskStorage.config.expiration = .days(5)
        KingfisherManager.shared.cache.cleanExpiredMemoryCache()
        KingfisherManager.shared.cache.cleanExpiredDiskCache()
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
   
    }
    
    func applicationDidEnterBackground(_ application: UIApplication){
        print("applicationDidEnterBackground")
    }
        
    func applicationWillEnterForeground(_ application: UIApplication){
        print("applicationWillEnterForeground")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        SocketIOManager.sharedInstance.checkSocketStatus()

    }
    
    func applicationWillTerminate(_ application: UIApplication) {

       /* if Local.shared.getUserId() > 0{
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
        }*/
        if Local.shared.getUserId() > 0{
          //  SocketIOManager.sharedInstance.disconnect() // socket?.disconnect()
        }

    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
        print(" UIApplication, continue userActivity")
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            
            let myUrl: String? = userActivity.webpageURL?.absoluteString
            let urlArray = myUrl?.components(separatedBy: "/")

           // if Local.shared.getUserId() > 0{
                if myUrl?.range(of: "/seller/") != nil {
                    
                    let userId = urlArray?.last ?? ""
                    //https://getkart.com/seller/213619
                  
                    let hostingController = UIHostingController(rootView: SellerProfileView(navController: self.navigationController, userId: Int(userId) ?? 0))
                    self.navigationController?.pushViewController(hostingController, animated: true)
                    
                }else  if myUrl?.range(of: "/product-details/") != nil {
                    
                    let slugName = (urlArray?.last ?? "").replacingOccurrences(of: "?share=true", with: "")
                    
                   // https://getkart.com/product-details/yamaha-fzs-2017-model?share=true
                  
                    
                    let siftUIview = ItemDetailView(navController:  self.navigationController, itemId: 0, itemObj: nil, slug: slugName)
                    let hostingController = UIHostingController(rootView:siftUIview)
                    hostingController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(hostingController, animated: true)
                }

          //  }
        }else{
            
        }
        return true
    }

    
    func reachabilityListener(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification, object: reachability)
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
   
    @objc func reachabilityChanged(note: NSNotification) {
       
      //  let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()

        guard  let reachability = note.object as? Reachability else{ return }
        if reachability.isReachable {
            isInternetConnected=true
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
                byreachable = "1"
            } else {
                print("Reachable via Cellular")
                byreachable = "2"
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.reconnectInternet.rawValue), object: nil , userInfo: nil)

            if Local.shared.getUserId() > 0{
                SocketIOManager.sharedInstance.establishConnection()
            }
        } else {
            isInternetConnected=false
            print("Network not reachable")
            byreachable = ""
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
    

    
     
   //MARK: NAvigate
    func  navigateToNotificationType() {
        
        guard !notificationType.isEmpty else { return }
        
        let roomIdRecieved = self.roomId
        let userIdRecieved = self.userId
        let notificationTypeRecieved = self.notificationType
        let itemIdRecieved = self.itemId
        
           
        print("didReceive")
        SocketIOManager.sharedInstance.checkSocketStatus()

        switch notificationTypeRecieved{
            
        case "chat","offer":
            
            if let tabBarController = self.navigationController?.topViewController as? HomeBaseVC{

                // Check if Chat tab is selected (e.g., assuming Chat tab is at index 2)
                if tabBarController.selectedIndex == 1, // update with your actual chat tab index
                   let navController = tabBarController.viewControllers?[1] as? UINavigationController,
                   let topVC = navController.topViewController as? ChatVC {
                    
                    // Now we know ChatVC is visible
                    if topVC.userId == userIdRecieved {
                        // Same chat already opened — do nothing or update UI
                        print("ChatVC is already opened for this user.")
                    } else {
                        // Different chat user, replace the ChatVC
                        navController.popViewController(animated: false)
                        let vc = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                        vc.userId = userIdRecieved
                        vc.item_offer_id = roomIdRecieved
                        vc.hidesBottomBarWhenPushed = true
                        navController.pushViewController(vc, animated: true)
                    }
                    
                    
                    
                } else {
                    
                    // Chat tab not selected, switch to Chat tab and push ChatVC
                    tabBarController.selectedIndex = 1 // Update with actual index
                    DispatchQueue.main.async {
                        
                        if let navController = tabBarController.selectedViewController as? UINavigationController {
                            let vc = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                            vc.userId = userIdRecieved
                            vc.item_offer_id = roomIdRecieved
                            vc.hidesBottomBarWhenPushed = true
                            navController.popToRootViewController(animated: false)
                            navController.pushViewController(vc, animated: true)
                        }
                    }
                }
            }

        case "payment":
            
           do {
                
                let hostingController = UIHostingController(rootView: TransactionHistoryView(navigation:self.navigationController)) 
                hostingController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(hostingController, animated: true)
            }
            
        case "item-update":
            do{
             
                for controller in self.navigationController?.viewControllers ?? []{
                    
                    if let destvc =  controller as? HomeBaseVC{
                        
                        
                        if let navController = destvc.viewControllers?[0] as? UINavigationController {
                            navController.popToRootViewController(animated: false)

                        }
                        
                        if let navController = destvc.viewControllers?[1] as? UINavigationController {
                            navController.popToRootViewController(animated: false)

                        }
                        
                        if let navController = destvc.viewControllers?[2] as? UINavigationController {
                            navController.popToRootViewController(animated: false)

                        }
                        
                        if let navController = destvc.viewControllers?[4] as? UINavigationController {
                            navController.popToRootViewController(animated: false)
                        }
                        
                        destvc.selectedIndex = 3
                        
                        if let navController = destvc.viewControllers?[3] as? UINavigationController {
                          
                            navController.popToRootViewController(animated: false)

                            // Notify the 3rd view controller to refresh
                            if  let thirdVC = navController.viewControllers.first as? MyAdsVC {
                                thirdVC.refreshMyAds()
                                break
                            }
                        }
                    }
                }
            
            }
            
            
        case "verifcation-request-update":
            do{
                
                Local.shared.isToRefreshVerifiedStatusApi = true
                
                for controller in self.navigationController?.viewControllers ?? []{
                    
                    if let destvc =  controller as? HomeBaseVC{
                            
                        
                        if let navController = destvc.viewControllers?[0] as? UINavigationController {
                            navController.popToRootViewController(animated: false)

                        }
                        
                        if let navController = destvc.viewControllers?[1] as? UINavigationController {
                            navController.popToRootViewController(animated: false)

                        }
                        
                        if let navController = destvc.viewControllers?[2] as? UINavigationController {
                            navController.popToRootViewController(animated: false)

                        }
                        
                        if let navController = destvc.viewControllers?[3] as? UINavigationController {
                            navController.popToRootViewController(animated: false)

                        }
                        

                        destvc.selectedIndex = 4
                        
                        // Notify the 3rd view controller to refresh
                        if let navController = destvc.viewControllers?[4] as? UINavigationController {
                          
                            navController.popToRootViewController(animated: false)
                           if let thirdVC = navController.viewControllers.first as? ProfileVC {
                                
                                thirdVC.getVerificationStatusApi()
                               break
                            }
                        }
                    }
                }
            }
       
        case "notification":
            do{
               
                if itemId == 0{
                    let hostingController = UIHostingController(rootView: NotificationView(navigation:self.navigationController))
                    hostingController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(hostingController, animated: true)
               
                }else{
                   
                    let hostingController = UIHostingController(rootView: ItemDetailView(navController:  self.navigationController, itemId:itemIdRecieved, itemObj: nil, slug: nil))
                    hostingController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(hostingController, animated: true)
                }
            }
        case "seller-profile":
            do{
                let hostingController = UIHostingController(rootView: SellerProfileView(navController: self.navigationController, userId: userIdRecieved))
                self.navigationController?.pushViewController(hostingController, animated: true)
            }
      
        default:
            break
        }
    
        self.clearRecievedNotification()
    }
    

    
    func clearRecievedNotification(){
        itemId = 0
        userId = 0
        roomId = 0
        notificationType = ""
    }
    
    func userNotificationCenter(_ a: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
      

       if Local.shared.getUserId() == 0{

            
        }else{
            print("didReceive")
            print("NOTIFICATION TAPPED === \(response.notification.request.content.userInfo)")
            
            notificationType =  response.notification.request.content.userInfo["type"] as? String ?? ""
            userId =  Int(response.notification.request.content.userInfo["sender_id"] as? String ?? "0") ?? 0
            roomId = Int(response.notification.request.content.userInfo["item_offer_id"] as? String ?? "0") ?? 0
            itemId = Int(response.notification.request.content.userInfo["item_id"] as? String ?? "0") ?? 0
            
            
            if userId == 0{
                userId =  Int(response.notification.request.content.userInfo["user_id"] as? String ?? "0") ?? 0
            }
            
            if userId == 0{
                userId =  Int(response.notification.request.content.userInfo["seller_id"] as? String ?? "0") ?? 0
            }
                
            
            print("notificationType == \(notificationType)")
            print("userId == \(userId)")
            print("roomId == \(roomId)")
            
            if Constant.shared.isLaunchFirstTime == 0 {
               //isLaunchFirstTime = 1 means first at launch time and 0 means after launch tapped on notification
                self.navigateToNotificationType()
            }
        }
    }
    
 
    
    //This is key callback to present notification while the app is in foreground

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("willPresent")
        
        print(notification.request.content)
        
        let  notificationType =  notification.request.content.userInfo["type"] as? String ?? ""
        var  userId = Int(notification.request.content.userInfo["sender_id"] as? String ?? "0") ?? 0
        
        
        if userId == 0{
            userId =  Int(notification.request.content.userInfo["user_id"] as? String ?? "0") ?? 0
        }
        
        
//        if userId == 0{
//            userId =  Int(notification.request.content.userInfo["seller_id"] as? String ?? "0") ?? 0
//        }
        
         
        if notificationType == "offer" {
            Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_SELLER = true
        }
        
        if notificationType == "chat" {
            
            
            Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_SELLER = true
            Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true
            
            if let tabBarController = self.navigationController?.topViewController as? HomeBaseVC {
                
                if (tabBarController.viewControllers?.count ?? 0) > 1{
                    
                    if tabBarController.selectedIndex == 1, // update with your actual chat tab index
                       
                       let navController = tabBarController.viewControllers?[1] as? UINavigationController,
                       let topVC = navController.topViewController as? ChatVC {
                        
                        // Now we know ChatVC is visible
                        if topVC.userId == userId {
                            // Same chat already opened — do nothing or update UI
                            print("ChatVC is already opened for this user.")
                        } else {
                            completionHandler([.banner, .list, .sound])
                        }
                        
                    }else{
                        completionHandler([.banner, .list, .sound])

                    }
                } else {
                    completionHandler([.banner, .list, .sound])

                }
            }else{
                completionHandler([.banner, .list, .sound])

            }

        } else{
            if notificationType == "verifcation-request-update"{
                Local.shared.isToRefreshVerifiedStatusApi = true
            }
         
            completionHandler([.banner, .list, .sound])
            
        }
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
    
   
    
    func showLoginScreen(){
        
        AppDelegate.sharedInstance.navigationController?.viewControllers.removeAll()
        let landingVC = StoryBoard.preLogin.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        AppDelegate.sharedInstance.navigationController?.viewControllers = [landingVC]
    }
    
    func getSettingsApi(){

        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: Constant.shared.get_system_settings) { (obj:SettingsParse) in
            
            if (obj.code ?? 0) == 200 {
               // self.settingsModel = obj.data
                Local.shared.currencySymbol = obj.data?.currencySymbol ?? "₹"
                Local.shared.companyEmail = obj.data?.companyEmail ?? "support@getkart.com"
                Local.shared.companyTelelphone1 = obj.data?.companyTel1 ?? "8800957957"
            }
            
        }
    }
   
    
    func isUserLoggedInRequest() -> Bool {

        if Local.shared.getUserId() > 0{

            return true
            
        }else{
            let deleteAccountView = UIHostingController(rootView: LoginRequiredView(loginCallback: {
                //Login
                AppDelegate.sharedInstance.navigationController?.popToRootViewController(animated: true)
            }))
            deleteAccountView.modalPresentationStyle = .overFullScreen // Full-screen modal
            deleteAccountView.modalTransitionStyle = .crossDissolve   // Fade-in effect
            deleteAccountView.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
            self.navigationController?.present(deleteAccountView, animated: true, completion: nil)
            
            return false
        }
    }
    
    
}


extension AppDelegate : ATAppUpdaterDelegate{
    
    func appUpdaterDidShowUpdateDialog(){
        
    }
    func appUpdaterUserDidLaunchAppStore(){
        
    }
    
    func appUpdaterUserDidCancel(){
        
    }
    
}
