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
    
    // MARK: - ApiHandler
 
    @discardableResult
    func makeGetGenericDataWithReturn<T: Decodable>(
        isToShowLoader: Bool,
        url: String,
        completion: @escaping (T) -> Void
    ) -> DataRequest {                                      // ← must be DataRequest, not Void

        let encodedUrl = url.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? url

        let headers = URLhandler.sharedinstance.getHeaderFields(isFormData: false)

        if ISDEBUG {
            print("GET URL == \(encodedUrl)")
        }

        return AF.request(                                  // ← must use return here
            encodedUrl,
            method: .get,
            headers: headers
        )
        .validate()
        .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let decoded):
                if ISDEBUG { print("response: \(response)") }
                completion(decoded)
            case .failure(let error):
                if let urlError = error.underlyingError as? URLError,
                   urlError.code == .cancelled {
                    if ISDEBUG { print("Cancelled: \(encodedUrl)") }
                    return
                }
                if ISDEBUG { print("API Error: \(error.localizedDescription)") }
            }
        }
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
                print("headers: ",httpHeader ?? [:])
            }
            
            AF.request(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "", method: httpMethod, parameters: param, encoding: JSONEncoding.default, headers: httpHeader)               
                .responseJSON { response in
                    
                    
                    DispatchQueue.main.async {
                        if isToShowLoader == true {
                            Themes.sharedInstance.removeActivityView(uiView:AppDelegate.sharedInstance.navigationController?.topViewController?.view ?? UIView())
                        }
                    }
                    
                    if response.response?.statusCode == 409{
                        AppDelegate.sharedInstance.deviceRefreshApi()
                        return
                    }
                    
                    if response.response?.statusCode == 401{
                        URLhandler.sharedinstance.checkAndLogout(responseCode:  response.response?.statusCode ?? 0)
                         return
                     }
                    
                    
                    
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
            AlertView.sharedManager.showToast(message: "No Network Connection")

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
                print("URL: ",url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
                print("headers: ",httpHeader ?? [:])
            }
            
//.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            AF.request(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "", method: .get, encoding: JSONEncoding.default, headers: httpHeader)
                .responseJSON { response in
                    
                    DispatchQueue.main.async {
                        if isToShowLoader == true {
                            Themes.sharedInstance.removeActivityView(uiView:AppDelegate.sharedInstance.navigationController?.topViewController?.view ?? UIView())
                        }
                    }
//                    if response.response?.statusCode == 401{
//                         AppDelegate.sharedInstance.logoutFromApp()
//                         return
//                     }
                    
                    if response.response?.statusCode == 409{
                        AppDelegate.sharedInstance.deviceRefreshApi()
                        return
                    }
                     
                    if response.response?.statusCode == 401{
                        URLhandler.sharedinstance.checkAndLogout(responseCode:  response.response?.statusCode ?? 0)
                         return
                     }
                    
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
            AlertView.sharedManager.showToast(message: "No Network Connection")

        }
        
    }
    
    

}
