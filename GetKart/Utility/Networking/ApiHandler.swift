//
//  ApiHandler.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 3/10/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import Foundation
import Alamofire



class ApiHandler:NSObject{
    
    static let sharedInstance:ApiHandler = {
        let apiHandler = ApiHandler()
//        apiHandler.ImageCache.countLimit = 1000
//        apiHandler.ImageCache.totalCostLimit = 1024 * 1024 * 512 //500 MB
        return apiHandler
    }()
    var dictionary:NSDictionary!=NSDictionary()
    
   
    func isConnectedToNetwork() -> Bool {
        return (UIApplication.shared.delegate as! AppDelegate).isInternetConnected
    }
    

    func makePostGenericData<T:Decodable>(url:String,param:Dictionary<String, Any>?, httpMethod: HTTPMethod = .post, isToShowLoader:Bool=true,loaderPos:LoaderPosition = .mid,completion:@escaping(T)-> ()){
        
        if isConnectedToNetwork() == true {
            DispatchQueue.main.async {
                if isToShowLoader == true {
                    if let topView = AppDelegate.sharedInstance.navigationController?.topViewController?.view {
                        Themes.sharedInstance.showActivityViewTop(uiView:  topView, position: loaderPos)
                    }
                }
            }
            
            let httpHeader = URLhandler.sharedinstance.getHeaderFields()
            
            if ISDEBUG == true{
                print("URL: ",url)
                print("Param: ",param as Any)
                print("headers: ",httpHeader)
            }
            
            AF.request(url, method: httpMethod, parameters: param, encoding: JSONEncoding.default, headers: httpHeader)
                .responseJSON { response in
                    
                    
                    DispatchQueue.main.async {
                        if isToShowLoader == true {
                            Themes.sharedInstance.removeActivityView(uiView:AppDelegate.sharedInstance.navigationController?.topViewController?.view ?? UIView())
                        }
                    }
                    
//                    if response.response?.statusCode == 404{
//                         AppDelegate.sharedInstance.logoutFromApp()
//                         return
//                     }
                    
                    switch response.result{
                        
                    case .success( _):
                        do {
                            guard let data = response.data else {
                                return
                            }
                            
                            if ISDEBUG == true{
                                self.dictionary = try JSONSerialization.jsonObject(
                                    with: response.data!,
                                    options: JSONSerialization.ReadingOptions.mutableContainers
                                ) as? NSDictionary
                                print("URL: \(url)\n Response received: ",self.dictionary ?? [:])
                            }
                            
                            do{
                                
                                let obj = try JSONDecoder().decode(T.self, from: data)
                                completion(obj)
                            }
                            
                        }
                        catch let error{
                            print("A JSON parsing error occurred, here are the details:\n \(error)")
                            self.dictionary=nil
                            // completion()
                        }
                        
                    case .failure(let error):
                        // completion()
                        print(error.localizedDescription)
                    }
                }
        }else {
           // (AppDelegate.sharedInstance.navigationController?.topViewController)?.view.makeToast(message: Constant.shared.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault,image: UIImage(named: "wifi")!)


        }
        
    }
    
    
    func makeGetGenericData<T:Decodable>(isToShowLoader:Bool, url:String, loaderPos:LoaderPosition = LoaderPosition.mid,completion:@escaping(T)-> ()){
        
        if isConnectedToNetwork() == true {
            DispatchQueue.main.async {
                if isToShowLoader == true {
                    if let topView = AppDelegate.sharedInstance.navigationController?.topViewController?.view {
                        Themes.sharedInstance.showActivityViewTop(uiView:  topView, position: loaderPos)
                    }
                }
            }
            
            let httpHeader = URLhandler.sharedinstance.getHeaderFields()
            
            if ISDEBUG == true{
                print("URL: ",url)
                print("headers: ",httpHeader)
            }
            
            AF.request(url, method: .get, encoding: JSONEncoding.default, headers: httpHeader)
                .responseJSON { response in
                    
                    DispatchQueue.main.async {
                        if isToShowLoader == true {
                            Themes.sharedInstance.removeActivityView(uiView:AppDelegate.sharedInstance.navigationController?.topViewController?.view ?? UIView())
                        }
                    }
//                    if response.response?.statusCode == 404{
//                         AppDelegate.sharedInstance.logoutFromApp()
//                         return
//                     }
                     
                    
                    switch response.result{
                        
                      
                    case .success( _):
                        do {
                            self.dictionary = try JSONSerialization.jsonObject(
                                with: response.data!,
                                options: JSONSerialization.ReadingOptions.mutableContainers
                            ) as? NSDictionary
                            
                            if ISDEBUG == true{
                                print("URL: \(url)\n Response received: ",self.dictionary ?? [:])
                            }
                            
                            
                            guard let data = response.data else {
                                return
                            }
                            
                            do{
                                
                                let obj = try JSONDecoder().decode(T.self, from: data)
                                completion(obj)
                            }
                            
                        }
                        catch let error{
                            print("A JSON parsing error occurred, here are the details:\n \(error)")
                            self.dictionary=nil
                            // completion()
                        }
                        
                    case .failure(let error):
                        // completion()
                        print(error.localizedDescription)
                    }
                }
        }else {
          //  (AppDelegate.sharedInstance.navigationController?.topViewController)?.view.makeToast(message: Constant.shared.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault,image: UIImage(named: "wifi")!)

        }
        
    }
    
    

}
