//
//  NotificationModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/02/25.
//

import Foundation


struct NotificationModel: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let message: String
}
