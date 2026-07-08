//
//  AppDelegate.swift
//  GetKart
//
//  Created by gurmukh singh on 2/19/25.
//


//======= New Optimized code



import UIKit
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseMessaging
import SwiftUI
import Kingfisher
import GooglePlaces
import FittedSheets
import AVFoundation
import FacebookCore
import FacebookAEM
import AppTrackingTransparency
import FBSDKCoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties

    let reachability = Reachability()
    var isInternetConnected: Bool = false
    var byreachable: String = ""

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

    private let isForceAppUpdate = true
    private var isDeviceRegistered = false
    private var hasCheckedUpdateThisSession = false
    private var isBackgroundCalled = false
    private var backgroundCalledTime: TimeInterval = 0
    private var socketConnectToken: NSObjectProtocol?
    

    // MARK: - App Launch

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // ── Critical path: window must be visible before anything else ──────
        window = UIWindow(frame: UIScreen.main.bounds)
        applyTheme()

        navigationController = UINavigationController()
        navigationController?.isNavigationBarHidden = true

        let splashVC = SplashViewController()
        navigationController?.viewControllers = [splashVC]
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()


        // ── Services needed before first network call ────────────────────────
        FirebaseApp.configure()
        setupImageCache()
        configureAudioSession()
        reachabilityListener()
        registerForRemoteNotification(application: application)

        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true

        // Parse cold-launch notification payload before navigateToHomeOrLogin runs
        if let remote = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            parseNotificationPayload(remote)
            Constant.shared.isLaunchFirstTime = 1
        }

        // ── Defer non-critical work until after first frame ──────────────────
        DispatchQueue.main.async { [weak self] in
            self?.setupTabBarFont()
            self?.deviceRegisterApi()
            self?.checkAppUpdate()
        }

        return true
    }

    // MARK: - Image Cache Setup

    func setupImageCache() {
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 80 * 1024 * 1024   // 80 MB
        cache.memoryStorage.config.countLimit     = 60
        cache.memoryStorage.config.cleanInterval  = 30
        cache.diskStorage.config.sizeLimit        = 300 * 1024 * 1024  // 300 MB
        cache.diskStorage.config.expiration       = .days(7)

        let downloader = KingfisherManager.shared.downloader
        downloader.downloadTimeout = 15
        downloader.sessionConfiguration.timeoutIntervalForRequest  = 15
        downloader.sessionConfiguration.timeoutIntervalForResource = 30
    }

    // MARK: - Audio Session

    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    // MARK: - App Update

    private func checkAppUpdate() {
        guard let updater = ATAppUpdater.sharedUpdater() as? ATAppUpdater else { return }
        updater.delegate = self
        isForceAppUpdate ? updater.showUpdateWithForce() : updater.showUpdateWithConfirmation()
    }

    // MARK: - Tab Bar Font

    private func setupTabBarFont() {
        guard let font = UIFont(name: "Inter-Regular", size: 12) else { return }
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.normal.titleTextAttributes   = [.font: font]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.font: font]
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    // MARK: - Navigation

    private func navigateToHomeOrLogin() {
        if Local.shared.getUserId() > 0 {
            if let landingVC = StoryBoard.main.instantiateViewController(withIdentifier: "HomeBaseVC") as? HomeBaseVC {
                navigationController?.viewControllers = [landingVC]
            }
        } else {
            let isFirstTime = UserDefaults.standard.object(forKey: "isFirstTime") as? Bool ?? true
            if isFirstTime {
                UserDefaults.standard.set(false, forKey: "isFirstTime")
                UserDefaults.standard.synchronize()
                let vc = UIHostingController(rootView: DemoView())
                navigationController?.viewControllers = [vc]
            } else {
                if let landingVC = StoryBoard.preLogin.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                    navigationController?.viewControllers = [landingVC]
                }
            }
        }
        navigationController?.navigationBar.isHidden = true
        window?.setRootViewController(navigationController!, options: .init(direction: .fade, style: .easeOut))
    }

    // MARK: - Orientation

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return .portrait
    }

    // MARK: - URL Handling

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }

    // MARK: - Universal Links

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let myUrl = userActivity.webpageURL?.absoluteString else { return true }

        let urlArray = myUrl.components(separatedBy: "/")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            if myUrl.contains("/seller/") {
                let userId = urlArray.last ?? ""
                let vc = UIHostingController(
                    rootView: SellerProfileView(navController: self.navigationController, userId: Int(userId) ?? 0)
                )
                self.navigationController?.pushViewController(vc, animated: true)

            } else if myUrl.contains("/board/") {
                let boardId = urlArray.last ?? ""
                self.getBoardDetailApi(boardId: Int(boardId) ?? 0)
            }
        }
        return true
    }

    // MARK: - Memory Warning

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        ImageCache.default.clearMemoryCache()
        FeedVideoManager.shared.pauseAll()
        FeedVideoManager.shared.reset()
        URLCache.shared.removeAllCachedResponses()
    }

    // MARK: - App Lifecycle

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {
        isBackgroundCalled = true
        backgroundCalledTime = Date().timeIntervalSince1970
    }

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.shared.activateApp()
        requestTrackingPermission()
        SocketIOManager.sharedInstance.checkSocketStatus()

        // Check for update once per session only
        if !hasCheckedUpdateThisSession {
            hasCheckedUpdateThisSession = true
            checkAppUpdate()
        }

        guard isDeviceRegistered else { return }

        if isBackgroundCalled {
            guard backgroundCalledTime > 0 else { return }
            let elapsed = Date().timeIntervalSince1970 - backgroundCalledTime
            if elapsed >= 3600 { deviceRefreshApi() }
            isBackgroundCalled = false  // reset for next background cycle
        } else {
            deviceRefreshApi()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {}

    // MARK: - ATT

    private func requestTrackingPermission() {
        guard #available(iOS 14, *) else { return }
        // Only prompt if not yet determined — avoids re-prompting on every foreground
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            ATTrackingManager.requestTrackingAuthorization { status in
                print("ATT status: \(status.rawValue)")
            }
        }
    }

    // MARK: - Theme

    func applyTheme() {
        let saved = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.light.rawValue
        switch AppTheme(rawValue: saved) ?? .light {
        case .light:  window?.overrideUserInterfaceStyle = .light
        case .dark:   window?.overrideUserInterfaceStyle = .dark
        case .system: window?.overrideUserInterfaceStyle = .unspecified
        }
    }

    // MARK: - Reachability

    func reachabilityListener() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged),
            name: ReachabilityChangedNotification,
            object: reachability
        )
        do {
            try reachability?.startNotifier()
        } catch {
            print("Could not start reachability notifier")
        }
    }

    @objc func reachabilityChanged(note: NSNotification) {
        guard let reachability = note.object as? Reachability else { return }

        if reachability.isReachable {
            isInternetConnected = true
            byreachable = reachability.isReachableViaWiFi ? "1" : "2"
            NotificationCenter.default.post(
                name: NSNotification.Name(NotificationKeys.reconnectInternet.rawValue),
                object: nil
            )
            /*
             if Local.shared.getUserId() > 0 {
                 SocketIOManager.sharedInstance.establishConnection()
             }
             */
            DispatchQueue.main.async{
                if Local.shared.getUserId() > 0 {
                    SocketIOManager.sharedInstance.establishConnection()
                }
            }
            
        } else {
            isInternetConnected = false
            byreachable = ""
            NotificationCenter.default.post(
                name: NSNotification.Name(NotificationKeys.noInternet.rawValue),
                object: nil
            )
        }
    }

    // MARK: - Login / Auth

    func showLoginScreen() {
        navigationController?.viewControllers.removeAll()
        if let vc = StoryBoard.preLogin.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            navigationController?.viewControllers = [vc]
        }
    }

    func isUserLoggedInRequest() -> Bool {
        guard Local.shared.getUserId() > 0 else {
            let vc = UIHostingController(rootView: LoginRequiredView(loginCallback: {
                AppDelegate.sharedInstance.navigationController?.popToRootViewController(animated: true)
            }))
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle   = .crossDissolve
            vc.view.backgroundColor   = UIColor.black.withAlphaComponent(0.5)
            navigationController?.present(vc, animated: true)
            return false
        }
        return true
    }

    // MARK: - Verified Info Sheet

    func presentVerifiedInfoView() {
        let controller = UIHostingController(rootView: SellerVeriedSheetView())
        controller.navigationController?.navigationBar.isHidden = true

        var fixedSize = 0.27
        if !UIDevice().hasNotch, UIScreen.main.bounds.height <= 700 {
            fixedSize = 0.38
        }

        let nav = UINavigationController(rootViewController: controller)
        nav.navigationBar.isHidden = true
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen

        let sheet = SheetViewController(
            controller: nav,
            sizes: [.percent(Float(fixedSize)), .intrinsic],
            options: SheetOptions(presentingViewCornerRadius: 0, useInlineMode: true)
        )
        sheet.cornerRadius = 15
        sheet.dismissOnPull = false
        sheet.gripColor = .clear
        sheet.allowGestureThroughOverlay = false
        controller.rootView = SellerVeriedSheetView()

        if let topVC = navigationController?.topViewController {
            sheet.animateIn(to: topVC.view, in: topVC)
        } else {
            navigationController?.present(sheet, animated: true)
        }
    }
}

// MARK: - Notification Routing

extension AppDelegate {

    // Shared helper — parses any notification payload dict into instance vars
    private func parseNotificationPayload(_ info: [AnyHashable: Any]) {
        notificationType = info["type"]          as? String ?? ""
        userId           = Int(info["sender_id"]     as? String ?? "0") ?? 0
        roomId           = Int(info["item_offer_id"] as? String ?? "0") ?? 0
        itemId           = Int(info["item_id"]       as? String ?? "0") ?? 0
       
        if userId == 0 { userId = Int(info["user_id"]   as? String ?? "0") ?? 0 }
        if userId == 0 { userId = Int(info["seller_id"] as? String ?? "0") ?? 0 }
        if userId == 0{   userId =  Int(info["userId"] as? String ?? "0") ?? 0 }
        
        if roomId == 0{
            roomId = Int(info["roomId"] as? String ?? "0") ?? 0
        }        
    }

    // Shared helper — switches to a tab and pushes a view controller once
    private func switchToTab(
        _ index: Int,
        in tabBar: HomeBaseVC,
        push: @escaping (UINavigationController) -> Void
    ) {
        tabBar.selectedIndex = index
        DispatchQueue.main.async {
            guard let nav = tabBar.selectedViewController as? UINavigationController else { return }
            nav.popToRootViewController(animated: false)
            push(nav)
        }
    }

    func navigateToNotificationType() {
        guard !notificationType.isEmpty else { return }

        // Capture locally so clearReceivedNotification() doesn't race
        let type          = notificationType
        let userIdLocal   = userId
        let roomIdLocal   = roomId
        let itemIdLocal   = itemId

        SocketIOManager.sharedInstance.checkSocketStatus()

        switch type {

        case "chat", "offer":
            guard let tabBar = navigationController?.topViewController as? HomeBaseVC else { break }

            // Already on chat tab and same chat open — just refresh
            if tabBar.selectedIndex == 3,
               let nav = tabBar.viewControllers?[3] as? UINavigationController,
               let chatVC = nav.topViewController as? ChatVC,
               chatVC.userId == userIdLocal {
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationKeys.refreshChatTblViewScreen.rawValue),
                    object: nil
                )
                break
            }

            switchToTab(3, in: tabBar) { nav in
                let vc = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                vc.userId           = userIdLocal
                vc.item_offer_id    = roomIdLocal
                vc.hidesBottomBarWhenPushed = true
                nav.pushViewController(vc, animated: true)
            }

        case "payment":
            let vc = UIHostingController(
                rootView: TransactionHistoryView(navigation: navigationController)
            )
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)

        case "board-update":
            guard let tabBar = navigationController?.topViewController as? HomeBaseVC else { break }

            // Already on profile tab showing MyBoardsView — just refresh
            if tabBar.selectedIndex == 4,
               let nav = tabBar.viewControllers?[4] as? UINavigationController,
               nav.topViewController is UIHostingController<MyBoardsView> {
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationKeys.refreshMyBoardsScreen.rawValue),
                    object: nil
                )
                break
            }

            switchToTab(4, in: tabBar) { nav in
                let vc = UIHostingController(rootView: MyBoardsView(navigationController: nav))
                vc.hidesBottomBarWhenPushed = true
                nav.pushViewController(vc, animated: true)
            }

        case "item-update", "draftItemReminder":
            guard let tabBar = navigationController?.topViewController as? HomeBaseVC else { break }

            if tabBar.selectedIndex == 4,
               let nav = tabBar.viewControllers?[4] as? UINavigationController,
               let topVC = nav.topViewController as? MyAdsVC {
                topVC.refreshMyAds()
                break
            }

            switchToTab(4, in: tabBar) { nav in
                let vc = StoryBoard.main.instantiateViewController(withIdentifier: "MyAdsVC") as! MyAdsVC
                vc.hidesBottomBarWhenPushed = true
                nav.pushViewController(vc, animated: true)
            }

        case "campaign-update":
            guard let tabBar = navigationController?.topViewController as? HomeBaseVC else { break }

            if tabBar.selectedIndex == 4,
               let nav = tabBar.viewControllers?[4] as? UINavigationController,
               let topVC = nav.topViewController as? MyAdsVC {
                topVC.refreshMyAds()
                break
            }

            switchToTab(4, in: tabBar) { nav in
                let vc = StoryBoard.main.instantiateViewController(withIdentifier: "MyAdsVC") as! MyAdsVC
                vc.hidesBottomBarWhenPushed = true
                nav.pushViewController(vc, animated: true)
            }

        case "verifcation-request-update":
            Local.shared.isToRefreshVerifiedStatusApi = true
            guard let tabBar = navigationController?.topViewController as? HomeBaseVC else { break }

            // Pop all nav stacks to root first
            tabBar.viewControllers?
                .compactMap { $0 as? UINavigationController }
                .forEach { $0.popToRootViewController(animated: false) }

            tabBar.selectedIndex = 4
            if let nav = tabBar.viewControllers?[4] as? UINavigationController {
                nav.popToRootViewController(animated: false)
                (nav.viewControllers.first as? ProfileVC)?.getVerificationStatusApi()
            }

        case "notification":
            if itemIdLocal == 0 {
                let vc = UIHostingController(rootView: NotificationView(navigation: navigationController))
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }

        case "board-notification":
            if itemIdLocal == 0 {
                let vc = UIHostingController(rootView: NotificationView(navigation: navigationController))
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            } else {
                getBoardDetailApi(boardId: itemIdLocal)
            }
        case "item_comment":
            getBoardDetailApi(boardId: itemIdLocal)

        case "seller-profile":
            let vc = UIHostingController(
                rootView: SellerProfileView(navController: navigationController, userId: userIdLocal)
            )
            navigationController?.pushViewController(vc, animated: true)

        case "chatReminder":
            guard let tabBar = navigationController?.topViewController as? HomeBaseVC else { break }

            tabBar.viewControllers?
                .compactMap { $0 as? UINavigationController }
                .forEach { $0.popToRootViewController(animated: false) }

            switchToTab(3, in: tabBar) { nav in
                (nav.viewControllers.first as? ChatListVC)?.updateandcheckStatus()
            }

        default:
            break
        }

        clearReceivedNotification()
    }

    func clearReceivedNotification() {
        itemId = 0
        userId = 0
        roomId = 0
        notificationType = ""
    }
}

// MARK: - Push Notifications

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {

    func registerForRemoteNotification(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        application.registerForRemoteNotifications()

        Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
            if let token {
                Local.shared.saveFCMToken(token: token)
            }
        }
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            Local.shared.saveFCMToken(token: token)
        }
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: ["token": fcmToken ?? ""]
        )
    }

    func application(
        application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    // Notification tapped from background / killed state
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        defer { completionHandler() }   // always called, even on early return

        let info = response.notification.request.content.userInfo
        parseNotificationPayload(info)
        // roomId key differs between tap and launch payload
        if roomId == 0 {
            roomId = Int(info["roomId"] as? String ?? "0") ?? 0
        }

        guard Local.shared.getUserId() > 0 else { return }
        guard Constant.shared.isLaunchFirstTime == 0 else { return }
        navigateToNotificationType()
    }

    // Notification received while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let info = notification.request.content.userInfo
        let type = info["type"] as? String ?? ""
        var uid  = Int(info["sender_id"] as? String ?? "0") ?? 0
        if uid == 0 { uid = Int(info["user_id"]   as? String ?? "0") ?? 0 }
        if uid == 0 { uid = Int(info["userId"]     as? String ?? "0") ?? 0 }

        if type == "offer" {
            Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_SELLER = true
        }

        if type == "chat" {
            Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_SELLER = true
            Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER  = true

            // Suppress banner if user is already in that exact chat
            if let tabBar = navigationController?.topViewController as? HomeBaseVC,
               tabBar.selectedIndex == 3,
               let nav = tabBar.viewControllers?[3] as? UINavigationController,
               let chatVC = nav.topViewController as? ChatVC,
               chatVC.userId == uid {
                return  // suppress — user is already reading this chat
            }
        }

        if type == "verifcation-request-update" {
            Local.shared.isToRefreshVerifiedStatusApi = true
        }

        completionHandler([.banner, .list, .sound])
    }
}

// MARK: - API Calls

extension AppDelegate: ATAppUpdaterDelegate {

    func appUpdaterDidShowUpdateDialog() {}
    func appUpdaterUserDidLaunchAppStore() {}
    func appUpdaterUserDidCancel() {}

    func deviceRegisterApi() {
        let params: [String: Any] = ["device_id": UIDevice.getDeviceUIDid()]
        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.device_register,
            param: params,
            methodType: .post,
            showLoader: false
        ) { [weak self] responseObject, error in
            guard let self else { return }
            self.isDeviceRegistered = true
            guard error == nil,
                  let result = responseObject,
                  let data = result["data"] as? [String: Any] else { return }

            if let key = data["key"] as? String, !key.isEmpty {
                Constant.shared.xApiKey = key
            }
            DispatchQueue.main.async {
                self.navigateToHomeOrLogin()
            }
            self.getSettingsApi()
        }
    }

    func deviceRefreshApi() {
        let params: [String: Any] = ["device_id": UIDevice.getDeviceUIDid()]
        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.device_refresh,
            param: params,
            methodType: .post
        ) { responseObject, error in
            guard error == nil,
                  let result = responseObject,
                  let data = result["data"] as? [String: Any],
                  let key = data["key"] as? String,
                  !key.isEmpty else { return }
            Constant.shared.xApiKey = key
        }
    }

    func getSettingsApi() {
        ApiHandler.sharedInstance.makeGetGenericData(
            isToShowLoader: false,
            url: Constant.shared.get_system_settings
        ) { (obj: SettingsParse) in
            guard obj.code == 200 else { return }
            Local.shared.currencySymbol       = obj.data?.currencySymbol    ?? "₹"
            Local.shared.companyEmail         = obj.data?.companyEmail      ?? "support@getkart.com"
            Local.shared.companyTelelphone1   = obj.data?.companyTel1       ?? "8800957957"
            Local.shared.iosNudityThreshold   = obj.data?.iosNudityThreshold ?? 0.15
        }
    }

    func checkUserStatusApi() {
        let url = Constant.shared.user_status + "/\(Local.shared.getUserId())"
        URLhandler.sharedinstance.makeCall(url: url, param: nil, methodType: .get) { responseObject, error in
            guard error == nil,
                  let result = responseObject,
                  let data   = result["data"] as? [String: Any],
                  let isActive = data["is_active"] as? Int else { return }
            URLhandler.sharedinstance.isLogoutPresented = false
            if isActive == 0 {
                Local.shared.removeUserData()
                AppDelegate.sharedInstance.showLoginScreen()
            }
            
            /*
             if let respDict =  responseObject as? Dictionary<String,Any>{
                 let message = respDict["message"] as? String ?? ""
                 let code = respDict["code"] as? Int ?? 0
                 
                 if code == 103 || message.lowercased() == "user not found"{
                     URLhandler.sharedinstance.isLogoutPresented = false
                     Local.shared.removeUserData()
                     AppDelegate.sharedInstance.showLoginScreen()
                     return
                 }
             }
          
             */
        }
    }

    private func getBoardDetailApi(boardId: Int) {
        let url = Constant.shared.get_board_details + "?board_id=\(boardId)"
        ApiHandler.sharedInstance.makeGetGenericData(
            isToShowLoader: true,
            url: url,
            loaderPos: .mid
        ) { [weak self] (obj: SingleItemParse) in
            guard obj.code == 200,
                  let board = obj.data?.first else { return }
            DispatchQueue.main.async {
                let vc = UIHostingController(
                    rootView: BoardDetailView(navigationController: self?.navigationController, itemObj: board)
                )
                vc.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: - Splash Screen

class SplashViewController: UIViewController {

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "Logo")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 90)
        ])
        if !AppDelegate.sharedInstance.isInternetConnected {
            AlertView.sharedManager.showToast(message: "No internet connection")
        }
    }
}



//============ OLD CODE =============
/*
 
 import UIKit
 import IQKeyboardManagerSwift
 import FirebaseCore
 import FirebaseMessaging
 import SwiftUI
 import Kingfisher
 import GooglePlaces
 import FittedSheets
 import AVFoundation
 import FacebookCore
 import FacebookAEM
 import AppTrackingTransparency
 import FBSDKCoreKit
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
   
    let reachability = Reachability()
    var isInternetConnected:Bool=Bool()
    var byreachable : String = String()
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
    private let isForceAppUpdate = true
    private var isDeviceRegistered = false
    
   // var settingsModel:SettingsModel?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        

        self.window = UIWindow(frame: UIScreen.main.bounds)
        // self.window?.overrideUserInterfaceStyle = .light
        
        applyTheme()
        
        navigationController = UINavigationController()
        self.navigationController?.isNavigationBarHidden = true
        
        let splashVC = SplashViewController() // simple UIViewController with logo/loader
        navigationController?.viewControllers = [splashVC]
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        reachabilityListener()
        registerForRemoteNotification(application: application)
            
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
       

        //by me kingfisher
        setupImageCache()
        configureAudioSession()

        // Define the desired large font
      if let largeFont = UIFont(name: "Inter-Regular", size: 12) {

             let appearance = UITabBarAppearance()
           
          
             // Apply the font to the normal state
             appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                 NSAttributedString.Key.font: largeFont
             ]
             
             // Apply the same (or different) font to the selected state
             appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                 NSAttributedString.Key.font: largeFont
             ]
             
             // Assign the appearance to the tab bar
             UITabBar.appearance().standardAppearance = appearance
             
             // For iOS 15+ to ensure the appearance is used everywhere (e.g., when scrolling)
             if #available(iOS 15.0, *) {
                 UITabBar.appearance().scrollEdgeAppearance = appearance
             }
         }


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
        

      //  self.setupKingfisherSettings()
        
        if let updateChecker : ATAppUpdater =  ATAppUpdater.sharedUpdater() as? ATAppUpdater{
            updateChecker.delegate = self
            if isForceAppUpdate{
                updateChecker.showUpdateWithForce()
            }else{
                updateChecker.showUpdateWithConfirmation()
            }
        }
        
        
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        

        self.deviceRegisterApi()
        
 

        return true
    }
    


    private func requestTrackingPermission() {
        if #available(iOS 14, *) {
            
            print("ATT Before Request: \(ATTrackingManager.trackingAuthorizationStatus.rawValue)")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    print("ATT After Request: \(status.rawValue)")
                }
            }
        }
    }
    
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        return ApplicationDelegate.shared.application(
            app,
            open: url,
            options: options
        )
    }

    func setupImageCache() {
        let cache = ImageCache.default

        // Hard memory cap — 80 MB is plenty for a visible feed
        cache.memoryStorage.config.totalCostLimit = 80 * 1024 * 1024  // 80 MB (was 120, and then 1 byte!)
        cache.memoryStorage.config.countLimit = 60                      // was 150 — too high
        cache.memoryStorage.config.cleanInterval = 30

        // Disk cache
        cache.diskStorage.config.sizeLimit = 300 * 1024 * 1024
        cache.diskStorage.config.expiration = .days(3)
    }

    // DELETE the entire setupKingfisherSettings() method — it undoes everything above.
    // Also DELETE the call to self.setupKingfisherSettings() in didFinishLaunching.
    
    
    private func navigateToHomeOrLogin(){
        
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
        
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
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
    
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        // 1. Nuke image memory cache
        ImageCache.default.clearMemoryCache()
        
        // 2. Pause all video players (was missing — each player holds 30–80 MB)
        FeedVideoManager.shared.pauseAll()
        
        // 3. Keep only the currently playing player, evict the rest
        FeedVideoManager.shared.reset()

        // 4. Clear URL cache
        URLCache.shared.removeAllCachedResponses()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
   
    }
    
    private var isBackgroundCalled = false
    private var backgroundCalledTime:TimeInterval = 0

    func applicationDidEnterBackground(_ application: UIApplication){
        print("applicationDidEnterBackground")
        isBackgroundCalled = true
        backgroundCalledTime = Date().timeIntervalSince1970
    }
    
    func applicationWillEnterForeground(_ application: UIApplication){
        print("applicationWillEnterForeground")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
       
        AppEvents.shared.activateApp()
        
        requestTrackingPermission()

        SocketIOManager.sharedInstance.checkSocketStatus()
        
        if isForceAppUpdate{
            if let updateChecker : ATAppUpdater =  ATAppUpdater.sharedUpdater() as? ATAppUpdater{
                updateChecker.delegate = self
                updateChecker.showUpdateWithForce()
            }
        }
        
        if isDeviceRegistered{
            if isBackgroundCalled{
                
                guard backgroundCalledTime > 0 else { return }
                let now = Date().timeIntervalSince1970
                
                if (now - backgroundCalledTime) >= (1 * 60 * 60){
                    self.deviceRefreshApi()
                }
            }else{
                self.deviceRefreshApi()
            }
            //  self.deviceRefreshApi()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
       // SocketEvents.onlineOfflineStatus.rawValue, ["user_id":Local.shared.getUserId()
        print("applicationWillTerminate")
    }
    
    
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
        print(" UIApplication, continue userActivity")
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            
            let myUrl: String? = userActivity.webpageURL?.absoluteString
            let urlArray = myUrl?.components(separatedBy: "/")

                if myUrl?.range(of: "/seller/") != nil {
                    
                    let userId = urlArray?.last ?? ""
                    //https://getkart.com/seller/213619
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        let hostingController = UIHostingController(rootView: SellerProfileView(navController: self.navigationController, userId: Int(userId) ?? 0))
                        self.navigationController?.pushViewController(hostingController, animated: true)
                    }
                }else  if myUrl?.range(of: "/product-details/") != nil {
                    
                  /*  let slugName = (urlArray?.last ?? "").replacingOccurrences(of: "?share=true", with: "")
                    
                   // https://getkart.com/product-details/yamaha-fzs-2017-model?share=true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        let siftUIview = ItemDetailView(navController:  self.navigationController, itemId: 0, itemObj: nil, slug: slugName)
                        let hostingController = UIHostingController(rootView:siftUIview)
                        hostingController.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(hostingController, animated: true)
                    }
                    */
                }else  if myUrl?.range(of: "/board/") != nil {
                    
                    let boardId = (urlArray?.last ?? "")

                   // https://getkart.com/product-details/yamaha-fzs-2017-model?share=true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        self.getBoardDetailApi(boardId: Int(boardId) ?? 0)
                    }
                }
            
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
    
    func applyTheme() {
        let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.light.rawValue
        let theme = AppTheme(rawValue: savedTheme) ?? .light

        switch theme {
        case .light:
            window?.overrideUserInterfaceStyle = .light
        case .dark:
            window?.overrideUserInterfaceStyle = .dark
        case .system:
            window?.overrideUserInterfaceStyle = .unspecified
        }
    }

    

    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ Audio session configured")
        } catch {
            print("❌ Audio session error: \(error)")
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
                if tabBarController.selectedIndex == 3, // update with your actual chat tab index
                   let navController = tabBarController.viewControllers?[3] as? UINavigationController,
                   let topVC = navController.topViewController as? ChatVC {
                    
                    // Now we know ChatVC is visible
                    if topVC.userId == userIdRecieved {
                        // Same chat already opened — do nothing or update UI
                        print("ChatVC is already opened for this user.")
                        
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshChatTblViewScreen.rawValue), object: nil , userInfo: nil)

                        
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
                    tabBarController.selectedIndex = 3 // Update with actual index
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
        case "board-update":
            do {
            
                if let tabBarController = self.navigationController?.topViewController as? HomeBaseVC {

                    if tabBarController.selectedIndex == 4,
                       let navController = tabBarController.viewControllers?[4] as? UINavigationController,
                       let hostingVC = navController.topViewController as? UIHostingController<MyBoardsView> {

                        // ✅ SwiftUI screen already visible
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshMyBoardsScreen.rawValue), object: nil, userInfo: nil)


                    } else {

                        // ❌ Not selected → switch tab and push SwiftUI view
                        tabBarController.selectedIndex = 4

                        DispatchQueue.main.async {
                            if let navController = tabBarController.selectedViewController as? UINavigationController {

                                let myBoardsView = MyBoardsView(navigationController:navController)
                                let hostingVC = UIHostingController(rootView: myBoardsView)
                                hostingVC.hidesBottomBarWhenPushed = true

                                navController.popToRootViewController(animated: false)
                                navController.pushViewController(hostingVC, animated: true)
                            }
                        }
                    }
                }

//                
//                
//                let hostingController = UIHostingController(rootView: MyBoardsView(navigationController: self.navigationController))
//                hostingController.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(hostingController, animated: true)
            }
            
        case "item-update","draftItemReminder":
            do{
             
               /* for controller in self.navigationController?.viewControllers ?? []{
                    
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
                }*/
                
                
                if let tabBarController = self.navigationController?.topViewController as? HomeBaseVC{

                    // Check if Chat tab is selected (e.g., assuming Chat tab is at index 2)
                    if tabBarController.selectedIndex == 4, // update with your actual chat tab index
                       let navController = tabBarController.viewControllers?[4] as? UINavigationController,
                       let topVC = navController.topViewController as? MyAdsVC {
                        topVC.refreshMyAds()

                                            
                    } else {
                        
                        // Chat tab not selected, switch to Chat tab and push ChatVC
                        tabBarController.selectedIndex = 4 // Update with actual index
                        DispatchQueue.main.async {
                            if let navController = tabBarController.selectedViewController as? UINavigationController {
                                let vc = StoryBoard.main.instantiateViewController(withIdentifier: "MyAdsVC") as! MyAdsVC
                                vc.hidesBottomBarWhenPushed = true
                                navController.popToRootViewController(animated: false)
                                navController.pushViewController(vc, animated: true)
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
                   
                    /*let hostingController = UIHostingController(rootView: ItemDetailView(navController:  self.navigationController, itemId:itemIdRecieved, itemObj: nil, slug: nil))
                    hostingController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(hostingController, animated: true)*/
                }
            }
            
        case "board-notification":
            do{
                
                if itemId == 0{
                    let hostingController = UIHostingController(rootView: NotificationView(navigation:self.navigationController))
                    hostingController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(hostingController, animated: true)
               
                }else{
                    
                    //DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        self.getBoardDetailApi(boardId: itemId)
                   // }
                }
            }
        case "seller-profile":
            do{
                let hostingController = UIHostingController(rootView: SellerProfileView(navController: self.navigationController, userId: userIdRecieved))
                self.navigationController?.pushViewController(hostingController, animated: true)
            }
        case "chatReminder":
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
                            if  let thirdVC = navController.viewControllers.first as? ChatListVC {
                                thirdVC.updateandcheckStatus()
                                break
                            }

                        }
                    }
                }
            }
      
       /* case "draftItemReminder":
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
                        
                        if let navController = destvc.viewControllers?[3] as? UINavigationController {
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
      */
        case "campaign-update":
            do{
                
               /* for controller in self.navigationController?.viewControllers ?? []{
                    
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
                                thirdVC.refreshBannerAds()
                     
                                break
                            }
                        }
                    }
                }*/
                
                if let tabBarController = self.navigationController?.topViewController as? HomeBaseVC{

                    // Check if Chat tab is selected (e.g., assuming Chat tab is at index 2)
                    if tabBarController.selectedIndex == 4, // update with your actual chat tab index
                       let navController = tabBarController.viewControllers?[4] as? UINavigationController,
                       let topVC = navController.topViewController as? MyAdsVC {
                        topVC.refreshMyAds()

                                            
                    } else {
                        
                        // Chat tab not selected, switch to Chat tab and push ChatVC
                        tabBarController.selectedIndex = 4 // Update with actual index
                        DispatchQueue.main.async {
                            if let navController = tabBarController.selectedViewController as? UINavigationController {
                                let vc = StoryBoard.main.instantiateViewController(withIdentifier: "MyAdsVC") as! MyAdsVC
                                vc.hidesBottomBarWhenPushed = true
                                navController.popToRootViewController(animated: false)
                                navController.pushViewController(vc, animated: true)
                            }
                        }
                    }
                }

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
            roomId = Int(response.notification.request.content.userInfo["roomId"] as? String ?? "0") ?? 0
            itemId = Int(response.notification.request.content.userInfo["item_id"] as? String ?? "0") ?? 0
            
            if userId == 0{
                userId =  Int(response.notification.request.content.userInfo["userId"] as? String ?? "0") ?? 0
            }
            
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
        
        
        if userId == 0{
            userId =   Int(notification.request.content.userInfo["userId"] as? String ?? "0") ?? 0
        }
        
         
        if notificationType == "offer" {
            Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_SELLER = true
        }
        
        if notificationType == "chat" {
            
            
            Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_SELLER = true
            Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true
            
            if let tabBarController = self.navigationController?.topViewController as? HomeBaseVC {
                
                if (tabBarController.viewControllers?.count ?? 0) > 1{
                    
                    if tabBarController.selectedIndex == 3, // update with your actual chat tab index
                       
                       let navController = tabBarController.viewControllers?[3] as? UINavigationController,
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
    
    
 func presentVerifiedInfoView(){
  
        let controller = UIHostingController(rootView: SellerVeriedSheetView())

        controller.title = ""
        controller.navigationController?.navigationBar.isHidden = true
        let nav = UINavigationController(rootViewController: controller)
        var fixedSize = 0.27
        if UIDevice().hasNotch{
            fixedSize = 0.27
        }else{
            if UIScreen.main.bounds.size.height <= 700 {
                fixedSize = 0.38
            }
        }
        nav.navigationBar.isHidden = true
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen
              
        let sheet = SheetViewController(
            controller: nav,
            sizes: [.percent(Float(fixedSize)),.intrinsic],
            options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: true))
        sheet.allowGestureThroughOverlay = false
        sheet.cornerRadius = 15
        sheet.dismissOnPull = false
        sheet.gripColor = .clear
     
        
        let settingView =  SellerVeriedSheetView()

        controller.rootView = settingView
   
        if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
            sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
        } else {
            self.navigationController?.present(sheet, animated: true, completion: nil)
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
    
    
    func deviceRegisterApi(){
        
        let params = ["device_id":UIDevice.getDeviceUIDid()] as [String : Any]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.device_register, param: params,methodType: .post,showLoader: false) {[weak self]  responseObject, error in
       
            self?.isDeviceRegistered = true
            if error == nil {
                if  let result = responseObject{
                    if let data = result["data"] as? Dictionary<String, Any>{
                        if (data["key"] as? String ?? "").count > 0{
                            Constant.shared.xApiKey = data["key"] as? String ?? ""
                        }
                       DispatchQueue.main.async {
                           self?.navigateToHomeOrLogin()
                        }
                        
                        self?.getSettingsApi()

                    }

                }
            }
        }
    }
    
    
    func deviceRefreshApi(){
        let params:Dictionary<String,Any> = ["device_id":UIDevice.getDeviceUIDid()]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.device_refresh, param: params,methodType: .post) { responseObject, error in
            
            if error == nil {
                if  let result = responseObject{
                    if let data = result["data"] as? Dictionary<String, Any>{
                        print("device_refresh== api == \(data)")
                        if (data["key"] as? String ?? "").count > 0{
                            Constant.shared.xApiKey = data["key"] as? String ?? ""
                        }
                    }
                }
            }
        }
    }
    
    
    func getSettingsApi(){

        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: Constant.shared.get_system_settings) { (obj:SettingsParse) in
            
            if (obj.code ?? 0) == 200 {
               // self.settingsModel = obj.data
                Local.shared.currencySymbol = obj.data?.currencySymbol ?? "₹"
                Local.shared.companyEmail = obj.data?.companyEmail ?? "support@getkart.com"
                Local.shared.companyTelelphone1 = obj.data?.companyTel1 ?? "8800957957"
               // Local.shared.placeApiKey = obj.data?.iosPlaceKey ?? ""
               // Local.shared.bannerScrollInterval = obj.data?.bannerScrollInterval ?? 3
               // print(" \( Local.shared.bannerScrollInterval) bannerScrollInterval val = \(obj.data?.bannerScrollInterval ?? 0)")
                
                Local.shared.iosNudityThreshold = obj.data?.iosNudityThreshold ?? 0.15
                
               /* if (obj.data?.iosPlaceKey ?? "").count > 0{
                    GMSPlacesClient.provideAPIKey(obj.data?.iosPlaceKey ?? "")
                }
                */
                
            }
            
        }
    }

    func checkUserStatusApi(){
        let strUrl = Constant.shared.user_status + "/\(Local.shared.getUserId())"
        

        URLhandler.sharedinstance.makeCall(url: strUrl, param: nil,methodType: .get) { responseObject, error in
            
            if error == nil {
                if  let result = responseObject{
                    if let data = result["data"] as? Dictionary<String, Any>{
                        URLhandler.sharedinstance.isLogoutPresented = false
                        
                        if let isActive = data["is_active"] as? Int{
                            
                            if isActive == 0{
                                Local.shared.removeUserData()
                                AppDelegate.sharedInstance.showLoginScreen()
                            }else{
                                
                            }
                            
                        }
                      
                    }
                }
            }
        }
    }

    private  func getBoardDetailApi(boardId:Int){
      
       let strUrl = Constant.shared.get_board_details + "?board_id=\(boardId)"
        ///v1/get-board-details?board_id=126560'
       ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl,loaderPos: .mid) { (obj:SingleItemParse) in
           
           if obj.code == 200
           {
               
               if obj.data != nil  {
                   if let board = obj.data?.first{
                       DispatchQueue.main.async {
                           
                           let hostingVC = UIHostingController(rootView: BoardDetailView(navigationController:self.navigationController, itemObj: board))
                           
                           hostingVC.hidesBottomBarWhenPushed = true
                           self.navigationController?.pushViewController(hostingVC, animated: true)
                       }
                   }
               }
               
           }else{
               
           }
       }
   }
    
}





import UIKit

class SplashViewController: UIViewController {

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo") // replace with your logo asset name
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground   // or your theme color
        
        setupLogo()
        
        
        if !AppDelegate.sharedInstance.isInternetConnected{
            AlertView.sharedManager.showToast(message: "No internet connection")
        }
    }

    private func setupLogo() {
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
   
}


*/
