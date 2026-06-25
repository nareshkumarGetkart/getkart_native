//
//  NetworkCondition.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 05/06/26.
//

import Foundation
import CoreTelephony

struct NetworkCondition {
    static var isCellular: Bool {
        let info = CTTelephonyNetworkInfo()
        return info.serviceCurrentRadioAccessTechnology != nil
    }
    
    // true when on slow cellular (3G, Edge, GPRS)
    static var isSlowCellular: Bool {
        let info = CTTelephonyNetworkInfo()
        guard let tech = info.serviceCurrentRadioAccessTechnology?.values.first else { return false }
        let slow: Set<String> = [
            CTRadioAccessTechnologyEdge,
            CTRadioAccessTechnologyGPRS,
            CTRadioAccessTechnologyCDMA1x,
            CTRadioAccessTechnologyWCDMA
        ]
        return slow.contains(tech)
    }
}


import Network

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published var isCellular = false

    private let monitor = NWPathMonitor()

    private init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isCellular = path.usesInterfaceType(.cellular)
            }
        }

        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
}
