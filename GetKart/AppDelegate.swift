//
//  AppDelegate.swift
//  GetKart
//
//  Created by gurmukh singh on 2/19/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    @objc static let sharedInstance = UIApplication.shared.delegate as! AppDelegate
    var window: UIWindow?
    var navigationController: UINavigationController?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        navigationController = UINavigationController()
        self.navigationController?.isNavigationBarHidden = true
        let landingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.viewControllers = [landingVC]
        self.window?.setRootViewController(self.navigationController!, options: .init(direction: .fade, style: .easeOut))
        
        return true
    }


    

}

