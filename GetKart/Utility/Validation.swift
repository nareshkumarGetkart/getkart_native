//
//  Validation.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 23/08/24.
//

import Foundation





func isValidName(testStr:String) -> Bool {
    guard testStr.count > 1, testStr.count < 35 else { return false }
    
    let predicateTest = NSPredicate(format: "SELF MATCHES %@", "^(([^ ]?)(^[a-zA-Z].*[a-zA-Z]$)([^ ]?))$")
    return predicateTest.evaluate(with: testStr)
}


func isValidEmail(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}


func isValidDate(strDate:String) ->Bool{
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    if let date = dateFormatter.date(from: strDate){
        return true // if this prints date is valid
    }else{
        return false // if this prints date is invalid
    }
}

//func validateYearWithDate(numberOfYr:Int,strDate:String) -> Bool{
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd"
//    if let date = dateFormatter.date(from: strDate){
//        let minDateComponent = Calendar.current.dateComponents([.day,.month,.year], from: date)
//        return  (minDateComponent.year! >= numberOfYr) ? true : false
//    }else{
//        return false // if this prints date is invalid
//    }
//}


func calcAge(birthday: String) -> Int {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "yyyy-MM-dd"
    let birthdayDate = dateFormater.date(from: birthday)
    let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
    let now = Date()
    let calcAge = calendar.components(.year, from: birthdayDate!, to: now, options: [])
    let age = calcAge.year
    return age!
}


extension String {
   var isNumeric: Bool {
     return !(self.isEmpty) && self.allSatisfy { $0.isNumber }
   }
    
   
    
    func getDateFrom() ->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard  let date = dateFormatter.date(from: self) else{ return ""}
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return dateFormatter.string(from: date)
        
    }

    
    func isValidName() -> Bool {
        let alphaNumericRegEx = #"[a-zA-Z\s]"#
        let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
        return predicate.evaluate(with: self)
    }
    
    
    var isValidEmail: Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    
    var isAlphanumeric: Bool {
        return range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    var isValidPassword: Bool{
        //Password must be of minimum 5 characters at least 1 Alphabet and 1 Number
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d$@$!%*#?&]{5,}$"
        let passTest = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passTest.evaluate(with: self)
    }
    
    
    var containsSpecialCharacter: Bool {
        let regex = ".*[^A-Za-z0-9].*"
        let testString = NSPredicate(format:"SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
    
    var isValidNameWithNumber: Bool {
        let alphaNumericRegEx = "[a-zA-Z0-9]"
        let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
        return predicate.evaluate(with: self)
    }
    
    var isPanCardValid: Bool {
        let alphaNumericRegEx = "[A-Z]{5}[0-9]{4}[A-Z]{1}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
        return predicate.evaluate(with: self)
    }
    
    
    var isIfscCodeValid: Bool {
        let alphaNumericRegEx = "^[a-zA-Z0-9]{11}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
        return predicate.evaluate(with: self)
    }
    
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
