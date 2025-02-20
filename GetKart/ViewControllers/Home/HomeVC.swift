//
//  HomeVC.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit

class HomeVC: UIViewController {
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        cnstrntHtNavBar.constant = self.getNavBarHt
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
