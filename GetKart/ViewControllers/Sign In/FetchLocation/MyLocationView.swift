//
//  MyLocationView.swift
//  Getkart
//
//  Created by gurmukh singh on 2/18/25.
//
import SwiftUI

struct MyLocationView: View {
    var navigationController: UINavigationController?
    @StateObject private var locationManager = LocationManager()
    @State private var navigateCountryLocation = false
    var countryCode = ""
    var mobile = ""
    var body: some View {
            VStack {
                
                
                HStack{
                    Image("myLocation")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 233, height: 223, alignment: .center)
                }.padding(.top ,30)
                HStack{
                    Text("What's your location")
                        .font(Font.manrope(.semiBold, size: 20.0))
                        .padding(.horizontal)
                        .frame(height: 50, alignment: .center)
                }.padding(.top ,30)
                HStack{
                    Text("Enjoy a personalize selling and buying experience by telling us your locaiton")
                        .font(Font.manrope(.regular, size: 20.0))
                        .foregroundColor(.gray)
                        .padding([.leading, .trailing], 20.0)
                        //.frame(width: UIScreen.main.bounds.size.width - 60,  alignment: .center)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                }.padding(.top ,10)
                
                HStack{
                    Button( action: findMyLocationAction){
                        Text("Find My Location")
                            .font(Font.manrope(.regular, size: 15.0))
                            .frame(width: (UIScreen.main.bounds.size.width - 60),height: 50)
                            .padding([.leading,.trailing],10)
                    }.foregroundColor(.white)
                        .background(.orange)
                        .cornerRadius(10)
                    
                    
                    
                }.padding(.top ,30)
                HStack{
                    Button( action: otherLocationAction){
                        Text("Other Location")
                            .font(Font.manrope(.regular, size: 15.0))
                            .frame(width: (UIScreen.main.bounds.size.width - 60),height: 50)
                            .padding([.leading,.trailing],10)
                    }.foregroundColor(.orange)
                        .background(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.orange, lineWidth: 1)
                        )
                }.padding(.top ,30)
                
                Spacer()
            }
        
    }
    
    func findMyLocationAction(){
        locationManager.delegate = self
        locationManager.checkLocationAuthorization()
        
        if let coordinate = locationManager.lastKnownLocation {
            print("Latitude: \(coordinate.latitude)")
            
            print("Longitude: \(coordinate.longitude)")
            self.userSignupApi()
            
            
        } else {
            print("Unknown Location")
        }
        
    }
    func userSignupApi(){
        let timestamp = Date.timeStamp
        var params = ["mobile": mobile, "firebase_id":"msg91_\(timestamp)", "type":"phone","platform_type":"ios", "fcm_id":"\(Local.shared.getFCMToken())", "country_code":"\(countryCode)"] as [String : Any]
        
        
      
        URLhandler.sharedinstance.makeCall(url: Constant.shared.userSignupUrl, param: params, methodType: .post,showLoader:true) {  responseObject, error in
            
        
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

                if status == 200{
                    
                    if let payload =  result["data"] as? Dictionary<String,Any>{
                        let token = result["token"] as? String ?? ""
                        let objUserInfo = UserInfo(dict: payload, token: token)
                        RealmManager.shared.saveUserInfo(userInfo: objUserInfo)
                       let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
                        print(objLoggedInUser)
                        
                        if let vc = StoryBoard.main.instantiateViewController(identifier: "HomeBaseVC") as? HomeBaseVC {
                            locationManager.delegate = nil
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                        }
                    }
                    
                }else{
                    //self?.delegate?.showError(message: message)
                }
                
            }
        }
    }
    
    func otherLocationAction(){
        let vc = UIHostingController(rootView: CountryLocationView())
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MyLocationView :LocationAutorizationUpdated {
    func locationAuthorizationUpdate() {
        if locationManager.manager.authorizationStatus == .authorizedAlways  ||  locationManager.manager.authorizationStatus == .authorizedWhenInUse {
            if let coordinate = locationManager.lastKnownLocation {
                print("Latitude: \(coordinate.latitude)")
                print("Longitude: \(coordinate.longitude)")
                self.userSignupApi()
                
                
            } else {
                print("Unknown Location")
            }
        }
    }
}



