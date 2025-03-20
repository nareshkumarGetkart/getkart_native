//
//  DateExtension.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 25/09/24.
//

import Foundation

extension Date {
    
    
    func getISODateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC

        let formattedString = dateFormatter.string(from: self)
        print("Formatted Date:", formattedString)
        return formattedString
    }
    
  
    
    func timeAgoDisplay() -> String {
 
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!

        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return "\(diff) sec"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff) min"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff) hrs"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff) days"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff) weeks"
    }

    
    static var timeStamp: Int64{
        return Int64(Date().timeIntervalSince1970)
    }
    
    
    func toMonthNameFormatWithTime()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy hh:mm a"
        return formatter.string(from: self)
    }
    
    
    func toDDMMYYY()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        return formatter.string(from: self)
    }
    
    func to_DD_MM_YYY()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: self)
    }
    
    func toMMDDYYYY() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YYYY"
        return formatter.string(from: self)
    }
    
    func toDDMMYYYTime()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        return formatter.string(from: self)
    }
    
    func toDDMMYYYYAndTime()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
    
    func toMMDD()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM.dd"
        return formatter.string(from: self)
    }
    
    func toHHMMA() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = .autoupdatingCurrent
        formatter.timeZone = NSTimeZone.local
        return formatter.string(from: self)
    }
    
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    //Date to milliseconds
    func currentTimeInMiliseconds() -> UInt64 {
        let currentDate = self
        let since1970 = currentDate.timeIntervalSince1970
        return UInt64(since1970 * 1000)
    }
}

