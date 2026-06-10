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
