//
//  AppDelegate.swift
//  GetKart
//
//  Created by gurmukh singh on 2/19/25.
//

import UIKit

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
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        navigationController = UINavigationController()
        self.navigationController?.isNavigationBarHidden = true
        
       // let landingVC = StoryBoard.main.instantiateViewController(withIdentifier: "HomeBaseVC") as! HomeBaseVC
        //self.navigationController?.viewControllers = [landingVC]
        
        let landingVC = StoryBoard.preLogin.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.viewControllers = [landingVC]
        
        
        self.navigationController?.navigationBar.isHidden = true
        self.window?.setRootViewController(self.navigationController!, options: .init(direction: .fade, style: .easeOut))
        
        return true
    }
    

}

