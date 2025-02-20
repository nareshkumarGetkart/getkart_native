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



