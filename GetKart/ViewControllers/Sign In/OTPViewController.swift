//
//  OTPViewController.swift
//  GetKart
//
//  Created by gurmukh singh on 2/21/25.
//

import UIKit
import SwiftUI

class OTPViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signInAction(){
        let hostingController = UIHostingController(rootView: MyLocationView(navigationController: self.navigationController)) // Wrap in UIHostingController
        navigationController?.pushViewController(hostingController, animated: true) // Push to navigation stack
    }
}
