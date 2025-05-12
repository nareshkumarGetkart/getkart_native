
//
//  URLhandler.swift
//  Plumbal
//
//  Created by Casperon Tech on 07/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SystemConfiguration
import AVKit


class URLhandler: NSObject{
    
    var respDictionary:NSDictionary!=NSDictionary()
    var ImageCache = NSCache<AnyObject, AnyObject>()
   
    static let sharedinstance:URLhandler = {
        let urlhandler = URLhandler()
        urlhandler.ImageCache.countLimit = 1000
        urlhandler.ImageCache.totalCostLimit = 1024 * 1024 * 512 //500 MB
        AF.sessionConfiguration.timeoutIntervalForRequest = 700 // 300
        AF.sessionConfiguration.timeoutIntervalForResource = 700
        return urlhandler
    }()
       
    
    func isConnectedToNetwork() -> Bool {
        return (UIApplication.shared.delegate as! AppDelegate).isInternetConnected
    }
  
   
    func getHeaderFields(isFormData:Bool=false)->HTTPHeaders? {
        
        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
        

        if objLoggedInUser.token != nil {
            
            
            let token = "Bearer \(objLoggedInUser.token ?? "")"
            
            if isFormData{
                let headers =  ["Content-Type":"multipart/form-data", "Accept":"application/json", "Authorization":token,"platform":"ios"]
                print("Header == \(headers)")
                return HTTPHeaders.init(headers)
            }else{
                let headers =  [ "Accept":"application/json", "Authorization":token,"platform":"ios"]
                print("Header == \(headers)")
                return HTTPHeaders.init(headers)
            }
        }else{
            let headers =  ["platform":"ios"]
            print("Header == \(headers)")
            return HTTPHeaders.init(headers)
        }

        /*

       let timeZone = TimeZone.current.identifier
        var headers = [ "Content-Type":"application/x-www-form-urlencoded", "device":"ios","timezone":"\(timeZone)", "version":"\(Local.shared.getAppVersion())"]
         
        if isFormData{
            
            headers = [ "Content-Type":"multipart/form-data","Content-Disposition" : "form-data", "device":"ios","timezone":"\(timeZone)", "version":"\(Local.shared.getAppVersion())"
            ]
        }
        
        if  Local.shared.getHashToken().count > 0 {
            headers["authToken"] = Local.shared.getHashToken()
        }
        
        headers["deviceId"] = Local.shared.getUUID()
        headers["Keep-Alive"] = "Connection"

        if ISDEBUG == true {
            print(headers)
        }
         */
        return nil
    }
    
    
    
    func makeCall(url: String, param:Dictionary<String, Any>?, methodType: HTTPMethod = .post, showLoader:Bool = false, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?) {
         
        if ISDEBUG == true{
            print("Url: ", url)
            print("Param: ",param)
            
        }
        
        if isConnectedToNetwork() == true {
            if showLoader{
                DispatchQueue.main.async {
                    if  let topView = AppDelegate.sharedInstance.navigationController?.topViewController?.view {
                        
                        print("------",topView)
                        Themes.sharedInstance.activityView(uiView: topView)
                        
                    }
                }
            }
            
            
            AF.request(url, method: methodType, parameters: param , encoding: JSONEncoding.default, headers: getHeaderFields())
                
                .responseJSON { response in
                    
                    if showLoader{
                        
                        DispatchQueue.main.async {
                            if  let topView = AppDelegate.sharedInstance.navigationController?.topViewController?.view {
                                print("+++++", topView)
                                Themes.sharedInstance.removeActivityView(uiView:topView)
                                topView.isUserInteractionEnabled = true
                            }
                        }
                    }
                    
//                    if response.response?.statusCode == 404{
//                         AppDelegate.sharedInstance.logoutFromApp()
//                         return
//                     }
                    
                    self.respDictionary = [:]
                    switch response.result {
                    case .success(_):
                        self.respDictionary = response.value as? NSDictionary
                        if ISDEBUG == true{
                            print("URL: \(url)\n Response received: ",self.respDictionary)
                        }
                        completionHandler(self.respDictionary as NSDictionary?, nil)
                        
                    case .failure(let error):
                        
                        if ISDEBUG == true {
                        print(response)
                        }
                        self.respDictionary=nil
                        completionHandler(self.respDictionary as NSDictionary?, error as NSError)
                        print("A JSON parsing error occurred, here are the details:\n \(error.errorDescription ?? "")")
                    }
                }
        }else {
            //AlertView.sharedManager.showToast(message: "No Network Connection")
            //(AppDelegate.sharedInstance.navigationController?.topViewController)?.view.makeToast(message: Constant.shared.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault,image: UIImage(named: "wifi")!)
        }
    }
    
    
    func uploadArrayOfMediaWithParameters(mediaArray : [UIImage],mediaName:String, url:String, params:Dictionary<String, Any> ,method:HTTPMethod = .post, showLoader:Bool = true, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?){
        if isConnectedToNetwork() == true {
            if showLoader{
                if  let topView = AppDelegate.sharedInstance.navigationController?.topViewController?.view  {
                    Themes.sharedInstance.activityView(uiView:  topView)
                }
            }
            
            if ISDEBUG{
                print(url)
                print(params)
            }
            
            AF.upload(multipartFormData: { (multipartFormData) in
                
                for img in mediaArray {
                    
                    if let data = img.jpegData(compressionQuality: 1.0) {
                        multipartFormData.append(data, withName: mediaName, fileName: "\(mediaName).jpeg", mimeType: "image/jpeg")
                    }
                    
                }
                
                for (key, value) in params {
                    
                    if value is Array<Dictionary<String,String>> {
                        
                        if let array = value as? Array<Dictionary<String,String>> {
                            var index = 0
                            for item in array {
                                
                                if let dimDict = item as? Dictionary<String,Any> {
                                    let height = dimDict["height"] as? String ?? "0"
                                    let width = dimDict["width"] as? String ?? "0"
                                    
                                    multipartFormData.append(height.data(using: String.Encoding.utf8)!, withName: "\(key)[\(index)][height]")
                                    multipartFormData.append(width.data(using: String.Encoding.utf8)!, withName: "\(key)[\(index)][width]")
                                }
                                index = index + 1
                            }
                        }
                        
                    }else if let arr = value as? Array<String>{
                        
                        let count : Int  = arr.count
                        
                        for i in 0  ..< count
                        {
                            let valueObj = arr[i]
                            let keyObj = key + "[" + String(i) + "]"
                            multipartFormData.append(valueObj.data(using: String.Encoding.utf8)!, withName: keyObj)
                        }
                        
                    }else if let dict = value as? Dictionary<String,Any>{
                        
                        print("dict==\(dict)")
                        print("dict.values==\(dict.values)")
                        print("dict.keys==\(dict.keys)")
                        
                        let mainKey = key
                        for (key, value) in dict
                        {
                            
                            multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: "\(mainKey)[\(key)]")
                        }
                        
                    } else {
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                    }
                    
                }
                
            },to: url, usingThreshold: UInt64.init(), method: method, headers: self.getHeaderFields(isFormData:true))
            .uploadProgress(queue: .main, closure: { (progress) in
                
                
            })
            .response{ response in
              
                DispatchQueue.main.async {
                    
                    Themes.sharedInstance.removeActivityView(uiView:AppDelegate.sharedInstance.navigationController?.topViewController?.view ?? UIView())
                }
                
//                if response.response?.statusCode == 404{
//                     AppDelegate.sharedInstance.logoutFromApp()
//                     return
//                 }
                
                if response.error == nil{
                    do{
                        self.respDictionary = try JSONSerialization.jsonObject(
                            with: response.value!!,
                            options: JSONSerialization.ReadingOptions.mutableContainers
                        ) as? NSDictionary
                        
                        if ISDEBUG == true {
                            print("URL: \(url)\n Response received: ",self.respDictionary ?? [:])
                        }
                        
                        completionHandler(self.respDictionary as NSDictionary?, response.error as NSError? )
                        
                    }catch let error{
                        completionHandler(self.respDictionary as NSDictionary?, error as NSError? )
                    }
                    
                }else{
                    completionHandler(self.respDictionary as NSDictionary?, response.error as NSError?)
                    
                }
            }
        }else {
           // AlertView.sharedManager.showToast(message: "No Network Connection")
          //  (AppDelegate.sharedInstance.navigationController?.topViewController)?.view.makeToast(message: Constant.shared.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault,image: UIImage(named: "wifi")!)

        }
    }
          
    func uploadMedia(fileName : String,fileKey:String,  param : [String:AnyObject] , file : URL?, url:String, mimeType:String, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?){
        
        if isConnectedToNetwork() == true {
            if ISDEBUG == true {
                print("URL:\n ",url,param)
                print("file:\n ",file)
                
            }
            AF.upload(multipartFormData: { (multipartFormData) in
                
                if let fileUrl = file{
                    multipartFormData.append(fileUrl, withName: fileKey, fileName: fileName, mimeType: "\(mimeType)")
                }
                for (key, value) in param {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                }
                
            },to: url, usingThreshold: UInt64.init(), method: .post, headers: self.getHeaderFields(isFormData: true))
            .uploadProgress(queue: .main, closure: { (progress) in
                let myDict = ["progress": progress.fractionCompleted]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploadProgress"), object: myDict)
                print("Upload Progress: \(progress.fractionCompleted)")
            })
            .response{ response in
                
//                if response.response?.statusCode == 404{
//                     AppDelegate.sharedInstance.logoutFromApp()
//                     return
//                 }
//                
                if response.error == nil{
                    do{
                        self.respDictionary = try JSONSerialization.jsonObject(
                            with: response.value!!,
                            options: JSONSerialization.ReadingOptions.mutableContainers
                        ) as? NSDictionary
                        
                        if ISDEBUG == true {
                            print("URL: \(url)\n Response received: ",self.respDictionary ?? [:])
                        }
                        
                        completionHandler(self.respDictionary as NSDictionary?, response.error as NSError? )
                        
                    }catch let error{
                        completionHandler(self.respDictionary as NSDictionary?, error as NSError? )
                    }
                    
                }else{
                    completionHandler(self.respDictionary as NSDictionary?, response.error as NSError?)
                    
                }               
            }
        }else {
           // (AppDelegate.sharedInstance.navigationController?.topViewController)?.view.makeToast(message: Constant.shared.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault,image: UIImage(named: "wifi")!)

            //AlertView.sharedManager.showToast(message: "No Network Connection")
        }
    }
    
    
    
    func uploadImageWithParameters(profileImg : UIImage,imageName:String, url:String, params:[String:Any], completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?){
    
        if isConnectedToNetwork() == true {
            if let topView = AppDelegate.sharedInstance.navigationController?.topViewController?.view {
                Themes.sharedInstance.showActivityViewTop(uiView:  topView, position: .mid)
            }
            
            if ISDEBUG{
                print(url)
                print(params)
            }
            //let param = [String:AnyObject]()
            AF.upload(multipartFormData: { (multipartFormData) in
                
                if let data = profileImg.jpegData(compressionQuality: 1.0) {
                    
                    multipartFormData.append(data, withName: imageName, fileName: "\(imageName).jpeg", mimeType: "image/jpeg")
                }else {
                    
                }
                
                
                for (key, value) in params {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                }
                print("\nmultipartFormData= \(multipartFormData)")
                
            },to: url, usingThreshold: UInt64.init(), method: .post, headers: self.getHeaderFields())
            .uploadProgress(queue: .main, closure: { (progress) in
                
            })
            .response{ response in
                DispatchQueue.main.async {
                    
                    Themes.sharedInstance.removeActivityView(uiView:AppDelegate.sharedInstance.navigationController?.topViewController?.view ?? UIView())
                }
                if response.error == nil{
                    do{
                        self.respDictionary = try JSONSerialization.jsonObject(
                            with: response.value!!,
                            options: JSONSerialization.ReadingOptions.mutableContainers
                        ) as? NSDictionary
                        
                        if ISDEBUG == true {
                            print("\(url) Response received: ",self.respDictionary)
                        }
                        completionHandler(self.respDictionary as NSDictionary?, response.error as NSError?)
                    }catch let error{
                        completionHandler(self.respDictionary as NSDictionary?, response.error as NSError?)
                    }
                }else{
                    
                    completionHandler(self.respDictionary as NSDictionary?, response.error as NSError?)
                }
            }
        }
    }
    
    func uploadImageArrayWithParameters(imageData:Data, imageName:String, imagesData : Array<Data>, imageNames:Array<String>, url:String, params:[String:Any], completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?){
    
        if isConnectedToNetwork() == true {
            if let topView = AppDelegate.sharedInstance.navigationController?.topViewController?.view {
                Themes.sharedInstance.showActivityViewTop(uiView:  topView, position: .mid)
            }
            
            if ISDEBUG{
                print(url)
                print(params)
            }
            //let param = [String:AnyObject]()
            AF.upload(multipartFormData: { (multipartFormData) in
                
                
                if imageData.count > 0 {
                    multipartFormData.append(imageData, withName: imageName, fileName: "\(imageName).jpeg", mimeType: "image/jpeg")
                }
                
                
                
                
                for ind in 0..<imagesData.count {
                    let data = imagesData[ind]
                    let name = imageNames[ind]
                    multipartFormData.append(data, withName: name, fileName: "file\(ind).jpeg", mimeType: "image/jpeg")
                }
                
                
                for (key, value) in params {
                    if let data = value as? Data {
                        multipartFormData.append(data, withName: key, fileName: "\(key).jpeg", mimeType: "image/jpeg")
                    }else if let arr = value as? Array<String> {
                        for i in 0  ..< arr.count {
                            let valueObj = arr[i] as! String
                            let keyObj = key as! String + "[" + String(i) + "]"
                            multipartFormData.append(valueObj.data(using: String.Encoding.utf8)!, withName: keyObj)
                        }
                    }else if let dict = value as? Dictionary<String,Any> {
                        var str = "{"
                        for (key1, value1) in dict {
                            if let dictCustom = value1 as? Dictionary<String,Any> {
                                for (keyCustom, valueCustom) in dictCustom {
                                    print(valueCustom)
                                    if let dataCustom = valueCustom as? Data {
                                        let nameKey = "\(key1)[\(keyCustom)]"
                                        multipartFormData.append(dataCustom, withName: nameKey, fileName: "\(key1).jpeg", mimeType: "image/jpeg")
                                    }
                                }
                                
                            }else if let data1 = value1 as? Data {
                                multipartFormData.append(data1, withName: key1, fileName: "\(key1).jpeg", mimeType: "image/jpeg")
                            }else if let arr = value1 as? Array<String> {
                                str = str + "\"\(key1)\":\(value1),"
                                print("String", arr)
                                
                            }else {
                                str = str + "\"\(key1)\":[\"\(value1)\"],"
                            }
                            
                        }
                        //remove , from last
                        str = String(str.dropLast())
                        
                        str = str + "}"
                        print(str)
                        multipartFormData.append("\(str)".data(using: String.Encoding.utf8)!, withName: key as! String)
                        
                    } else {
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as! String)
                    }
                    
                }
                print("\nmultipartFormData= \(multipartFormData)")
                
            },to: url, usingThreshold: UInt64.init(), method: .post, headers: self.getHeaderFields())
            .uploadProgress(queue: .main, closure: { (progress) in
                
            })
            .response{ response in
                DispatchQueue.main.async {
                    
                    Themes.sharedInstance.removeActivityView(uiView:AppDelegate.sharedInstance.navigationController?.topViewController?.view ?? UIView())
                }
                
                
                if response.error == nil{
                    do{
                        self.respDictionary = try JSONSerialization.jsonObject(
                            with: response.value!!,
                            options: JSONSerialization.ReadingOptions.mutableContainers
                        ) as? NSDictionary
                        
                        if ISDEBUG == true {
                            print("\(url) Response received: ",self.respDictionary)
                        }
                        completionHandler(self.respDictionary as NSDictionary?, response.error as NSError?)
                    }catch let error{
                        completionHandler(self.respDictionary as NSDictionary?, response.error as NSError?)
                    }
                }else{
                    completionHandler(self.respDictionary as NSDictionary?, response.error as NSError?)
                }
            }
        }
    }
    
    deinit {
    }
    
   
    
    
    
    
    
    
    func uploadArrayOfImagesWithParameters(mediaArray : [UIImage],mediaKeyArray:[String],mediaName:String, url:String, params:Dictionary<String, Any> ,method:HTTPMethod = .post, showLoader:Bool = true, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?){
        if isConnectedToNetwork() == true {
            if showLoader{
                if  let topView = AppDelegate.sharedInstance.navigationController?.topViewController?.view  {
                    Themes.sharedInstance.activityView(uiView:  topView)
                }
            }
            
            if ISDEBUG{
                print(url)
                print(params)
            }
            
            AF.upload(multipartFormData: { (multipartFormData) in
                
                var i = 0
                for img in mediaArray {
                    
                    var keyStr = ""
                    if mediaKeyArray.count > i {
                        keyStr = "\(mediaName)[\(mediaKeyArray[i])]"
                    }
                    print(keyStr)
                    
                    if let data = img.wxCompress().jpegData(compressionQuality: 1.0) {

                   // if let data = img.jpegData(compressionQuality: 0.7) {
                        multipartFormData.append(data, withName: keyStr, fileName: "\(mediaName).jpeg", mimeType: "image/jpeg")
                    }
                    i = i + 1
                    
                }
                
                for (key, value) in params {
                    
                    if value is Array<Dictionary<String,String>> {
                        
                        if let array = value as? Array<Dictionary<String,String>> {
                            var index = 0
                            for item in array {
                                
                                if let dimDict = item as? Dictionary<String,Any> {
                                    let height = dimDict["height"] as? String ?? "0"
                                    let width = dimDict["width"] as? String ?? "0"
                                    
                                    multipartFormData.append(height.data(using: String.Encoding.utf8)!, withName: "\(key)[\(index)][height]")
                                    multipartFormData.append(width.data(using: String.Encoding.utf8)!, withName: "\(key)[\(index)][width]")
                                }
                                index = index + 1
                            }
                        }
                        
                    }else if let arr = value as? Array<String>{
                        
                        let count : Int  = arr.count
                        
                        for i in 0  ..< count
                        {
                            let valueObj = arr[i]
                            let keyObj = key + "[" + String(i) + "]"
                            multipartFormData.append(valueObj.data(using: String.Encoding.utf8)!, withName: keyObj)
                        }
                        
                    }else if let dict = value as? Dictionary<String,Any>{
                        
                        print("dict==\(dict)")
                        print("dict.values==\(dict.values)")
                        print("dict.keys==\(dict.keys)")
                        
                        let mainKey = key
                        for (key, value) in dict
                        {
                            
                            multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: "\(mainKey)[\(key)]")
                        }
                        
                    } else {
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                    }
                    
                }
                
            },to: url, usingThreshold: UInt64.init(), method: method, headers: self.getHeaderFields(isFormData:true))
            .uploadProgress(queue: .main, closure: { (progress) in
                
                
            })
            .response{ response in
              
                DispatchQueue.main.async {
                    
                    Themes.sharedInstance.removeActivityView(uiView:AppDelegate.sharedInstance.navigationController?.topViewController?.view ?? UIView())
                }
                
//                if response.response?.statusCode == 404{
//                     AppDelegate.sharedInstance.logoutFromApp()
//                     return
//                 }
                
                if response.error == nil{
                    do{
                        self.respDictionary = try JSONSerialization.jsonObject(
                            with: response.value!!,
                            options: JSONSerialization.ReadingOptions.mutableContainers
                        ) as? NSDictionary
                        
                        if ISDEBUG == true {
                            print("URL: \(url)\n Response received: ",self.respDictionary ?? [:])
                        }
                        
                        completionHandler(self.respDictionary as NSDictionary?, response.error as NSError? )
                        
                    }catch let error{
                        completionHandler(self.respDictionary as NSDictionary?, error as NSError? )
                    }
                    
                }else{
                    completionHandler(self.respDictionary as NSDictionary?, response.error as NSError?)
                    
                }
            }
        }else {
           // AlertView.sharedManager.showToast(message: "No Network Connection")
          //  (AppDelegate.sharedInstance.navigationController?.topViewController)?.view.makeToast(message: Constant.shared.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault,image: UIImage(named: "wifi")!)

        }
    }
    
}
                    
                    
                    
                    
                    
                    
                   
        




