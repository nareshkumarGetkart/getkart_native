//
//  PostAdFinalVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 05/10/25.
//

import UIKit
import MapKit
import SwiftUI
import Kingfisher
import PhotosUI

class PostAdFinalVC: UIViewController {
    // @IBOutlet weak var mapView:MKMapView!

    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var lblLocation:UILabel!
  //  @IBOutlet weak var btnChooseLocation:UIButton!
    @IBOutlet weak var btnUpdatePost:UIButton!
    
    @IBOutlet weak var btnEditPencil:UIButton!
    @IBOutlet weak var imgViewProfile:UIImageView!
    @IBOutlet weak var btnEditLocation:UIButton!
    @IBOutlet weak var txtFdName:UITextField!
    @IBOutlet weak var txtFdMobile:UITextField!
    @IBOutlet weak var lblVerifiedStatus:UILabel!
    @IBOutlet weak var btnCurrentLocation:UIButton!
    
    lazy private var imagePicker = UIImagePickerController()

    var latitude = 0.0
    var longitude = 0.0
    var imgData:Data?
    var imgName = ""
    var gallery_images:Array<Data> = []
    var gallery_imageNames:Array<String> = []
    var popType:PopType?
    var params:Dictionary<String,Any> = [:]
    var range1: Double = 0.0
    private var  countryArr: [CountryModel]?
    private  var selectedImage:UIImage?
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // mapView.delegate = self
        cnstrntHtNavBar.constant = self.getNavBarHt
        btnBack.setImageColor(color: .label)
        btnUpdatePost.setTitle((popType == .createPost ? "Post Now" : "Update"), for: .normal)
        
        if latitude == 0{
            LocationManager.sharedInstance.delegate = self
            LocationManager.sharedInstance.checkLocationAuthorization()
            self.lblLocation.text =  "Loading..."
        }else{
            self.updateStateCity1(for: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            self.lblLocation.text =  self.params[AddKeys.address.rawValue] as? String ?? ""
        }
        
        //        // Add tap gesture recognizer
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        //        mapView.addGestureRecognizer(tapGesture)
        //
        //        btnChooseLocation.layer.borderColor = UIColor.lightGray.cgColor
        //        btnChooseLocation.layer.borderWidth = 1.0
        //        btnChooseLocation.layer.cornerRadius = 5.0
        //        btnChooseLocation.clipsToBounds = true
        
        //        mapView.layer.cornerRadius = 5.0
        //        mapView.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self,selector: #selector(selectedLocation(notification:)),
                                               name: Notification.Name(NotiKeysLocSelected.createPostNewLocation.rawValue),
                                               object: nil)
        
        updateUserInfo()
    }
    
    
    func updateUserInfo(){
        
        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
        
        txtFdName.text =  ((objLoggedInUser.name ?? "").lowercased() != "guest user") ?  objLoggedInUser.name ?? "" : ""
        txtFdMobile.text = objLoggedInUser.mobile ?? ""
        txtFdMobile.delegate = self
        self.lblVerifiedStatus.isHidden = true
        
        if (objLoggedInUser.mobile ?? "").count > 0{
            self.lblVerifiedStatus.isHidden = false
        }
        imgViewProfile.kf.setImage(with:  URL(string: objLoggedInUser.profile ?? "") , placeholder:UIImage(named: "user-circle"))
        imgViewProfile.layer.cornerRadius = imgViewProfile.frame.height/2.0
        imgViewProfile.contentMode = .scaleAspectFill
        imgViewProfile.clipsToBounds = true
    }
    
    
    func pushToValidateMobileNumber(){
      //  if (params[AddKeys.contact.rawValue] as? String ?? "").count > 0 { return}
        let destVc = UIHostingController(rootView: MobileNumberView(navigationController: self.navigationController,onDismissUpdatedMobile: { strMob in
            self.params[AddKeys.contact.rawValue]  = strMob
            self.txtFdMobile.text = strMob
            self.lblVerifiedStatus.isHidden = false

        }))
        self.navigationController?.pushViewController(destVc, animated: true)
    }
    
    @objc func selectedLocation(notification: Notification) {
        
        guard let data = notification.userInfo else{
            return
        }
        
            if let userInfo = notification.userInfo as? [String: Any] {
                let latitude = userInfo["latitude"] as? String ?? ""
                let longitude = userInfo["longitude"] as? String ?? ""
                let city = userInfo["city"] as? String ?? ""
                let state = userInfo["state"] as? String ?? ""
                let country = userInfo["country"] as? String ?? ""
                let locality = userInfo["locality"] as? String ?? ""
                
                // Handle the data in SwiftUI View
                print("Location: \(city), \(state), \(country)")
                
                
                if locality.count > 0{
                    self.params[AddKeys.address.rawValue] =  locality + "," + city + ((city.count > 0) ? ", " : "") + state //+ ", " + country
                    
                }else{
                    self.params[AddKeys.address.rawValue] =   city +  ((city.count > 0) ? ", " : "") + state //+ ", " + country
                    
                }
                self.params[AddKeys.latitude.rawValue] = latitude
                self.params[AddKeys.longitude.rawValue] = longitude
                self.params[AddKeys.country.rawValue] = country
                self.params[AddKeys.city.rawValue] = city
                self.params[AddKeys.state.rawValue] = state
               
                self.params[AddKeys.area.rawValue] = locality

                self.savePostLocation(latitude: latitude, longitude: longitude, city: city, state: state, country: country, locality: locality)
               
            }
        }
    
    //MARK: UIButton Action Methods
    
    @IBAction func backButtonAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
 
    @IBAction func pencilButtonAction(_ sender : UIButton){
   
            let actionSheet = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                    self.openImagePicker(sourceType: .camera)
                }))
            }

            actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                self.openImagePicker(sourceType: .photoLibrary)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            // For iPad: prevent crash
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            present(actionSheet, animated: true)
    }
    
    @IBAction func currentLocationButtonAction(_ sender : UIButton){
        LocationManager.sharedInstance.delegate = self
        LocationManager.sharedInstance.checkLocationAuthorization()
    }
  
    
    @IBAction func postButtonAction(_ sender : UIButton){
        
            if (txtFdName.text?.trim().count == 0) || !(txtFdName.text ?? "").isValidName() {
               AlertView.sharedManager.showToast(message: "Please enter your valid name.")

           }else if latitude == 0 && popType != .editPost{
               AlertView.sharedManager.showToast(message: "Please enable location  or select location manually.")
           
           }else{
               let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()

               if selectedImage != nil || ((txtFdName.text ?? "") != objLoggedInUser.name){
                   self.updateProfile()
               }
               self.uploadFIleToServer()
           }
    }
    
   
    @IBAction func chooseLocationtButtonAction(_ sender : UIButton){
        fetchCountryListing()
    }
    
 
    
    func fetchCountryListing(){
        
        if (countryArr?.count ?? 0) == 0{
            var rootView = CountryLocationView(arrCountries: countryArr ?? [], popType: .createPost, navigationController: self.navigationController)
              rootView.delLocationSelected = self
            let vc = UIHostingController(rootView:rootView)
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_Countries) { (obj:CountryParse) in
                self.countryArr = obj.data?.data ?? []
                var rootView = CountryLocationView(arrCountries: self.countryArr ?? [], popType: .createPost, navigationController: self.navigationController)
                rootView.delLocationSelected = self
                let vc = UIHostingController(rootView:rootView)
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
   }
}

extension PostAdFinalVC:UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtFdMobile{
            pushToValidateMobileNumber()
            return false
        }
        return true
    }
    
    
    func updateProfile(){
        
        
//        let isNotification =  isNotificationsEnabled == false ? 0 : 1
//        let isContact =  isContactInfoVisible == false ? 0 : 1

//        let params = ["name":fullName,"email":email,"address":address,"mobile":phoneNumber,"countryCode":"91","notification":isNotification,"personalDetail":isContact] as [String : Any]
        
        
        let params = ["name":txtFdName.text ?? ""] as [String : Any]

        URLhandler.sharedinstance.uploadImageWithParameters(profileImg: selectedImage?.wxCompress() ?? UIImage(), imageName: "profile", url: Constant.shared.update_profile, params: params) { responseObject, error in
            
            
            if error == nil{
                
                
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if code == 200{
                    
                    if let data = result["data"] as? Dictionary<String,Any>{
                        
                        RealmManager.shared.updateUserData(dict: data)
                       
                    }
                    
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
            }
        }
    }
    
}

extension PostAdFinalVC: MKMapViewDelegate,LocationSelectedDelegate {
 
    
    @objc private func handleMapTap(_ gesture: UITapGestureRecognizer) {
        /*let locationInView = gesture.location(in: mapView)
        let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
        
        print("Tapped coordinate: \(tappedCoordinate.latitude), \(tappedCoordinate.longitude)")
        
        // Optionally add a pin annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = tappedCoordinate
        annotation.title = ""
        mapView.removeAnnotations(mapView.annotations) // remove old pins
        mapView.addAnnotation(annotation)
      
        self.updateStateCity1(for: tappedCoordinate)
         */
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let renderer = MKCircleRenderer(overlay: circleOverlay)
            renderer.strokeColor = UIColor.red
            renderer.fillColor = UIColor.red.withAlphaComponent(0.1)
            renderer.lineWidth = 1
            return renderer
        }
        return MKOverlayRenderer()
    }

    
    func updateStateCity1(for coordinate: CLLocationCoordinate2D) {
                
     /*   let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = ""
        annotation.subtitle = ""
        
        // Clear previous pins if needed
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        
        // Update map region (zoom)
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude:  coordinate.latitude, longitude: coordinate.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02) // smaller delta = closer zoom
        )
        mapView.setRegion(region, animated: true)
        */
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) {  [weak self] placemarks, error in
            
            if let error = error {
                print("❌ Reverse geocode failed: \(error.localizedDescription)")
                if let cle = error as? CLError {
                    print("CLError code: \(cle.code.rawValue)")
                }
                self?.getAddressFromLatLongApi(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            }else{
                guard let self = self, let placemark = placemarks?.first, error == nil else {
                    print("Reverse geocoding failed:", error?.localizedDescription ?? "unknown error")
                    
                    return
                }
                guard let placemark = placemarks?.first, error == nil else { return }
                
                
                DispatchQueue.main.async {
                    let city = placemark.locality ?? ""
                    let state = placemark.administrativeArea ?? ""
                    let country = placemark.country ?? ""
                    var locality = placemark.subLocality ?? ""
                    
                    self.savePostLocation(latitude:"\(coordinate.latitude)", longitude: "\(coordinate.longitude)", city: city, state: state, country: country, locality: locality)
                }
            }
        }
    }
    
    
    func getAddressFromLatLongApi(lat: Double, lng: Double) {
       // type :  1=> retrive lat long , 2=>retrive address
        let params = ["lat":lat,"lng":lng,"type":1]
        
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.fetch_google_location, param: params, methodType: .post,showLoader: true) { responseObject, error in
            
            if error == nil {
                if let result = responseObject as? [String: Any],
                   let data = result["data"] as? [String: Any],
                   let results = data["results"] as? [[String: Any]],
                   let first = results.first,
                   let addressComponents = first["address_components"] as? [[String: Any]] {
                    
                    var country = ""
                    var state = ""
                    var city = ""
                    var area = ""
                    
                    for component in addressComponents {
                        guard let longName = component["long_name"] as? String,
                              let types = component["types"] as? [String] else { continue }
                        
                        if types.contains("country") {
                            country = longName
                        } else if types.contains("administrative_area_level_1") {
                            state = longName
                        } else if types.contains("locality") {
                            city = longName
                        } else if types.contains("sublocality_level_1") || types.contains("sublocality_level_2") {
                            area = longName
                        }
                    }
                    
                    print("🌍 Country: \(country)")
                    print("🗾 State: \(state)")
                    print("🏙️ City: \(city)")
                    print("📍 Area: \(area)")
                    
                    // Example: Store or use in UI
                    DispatchQueue.main.async {
                       
                        self.savePostLocation(latitude:"\(lat)", longitude: "\(lng)", city: city, state: state, country: country, locality: area)

                    }
                }
            }
        }

     
     
    }
    
    func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String,locality:String) {
         
         if locality.count > 0{
             self.params[AddKeys.address.rawValue] =  locality + "," + city + ", " + state //+ ", " + country

             self.lblLocation.text =  locality + "," + city + ", " + state
         }else{
             self.params[AddKeys.address.rawValue] = city + ", " + state //+ ", " + country
             self.lblLocation.text =  city + ", " + state


         }
             self.params[AddKeys.latitude.rawValue] = latitude
             self.params[AddKeys.longitude.rawValue] = longitude
             self.params[AddKeys.country.rawValue] = country
             self.params[AddKeys.city.rawValue] = city
             self.params[AddKeys.state.rawValue] = state
             self.params[AddKeys.area.rawValue] = locality
        
        self.latitude = Double(latitude) ?? 0
        self.longitude = Double(longitude) ?? 0
/*
        let coordinate = CLLocationCoordinate2D(latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = ""
        annotation.subtitle = ""
        
        // Clear previous pins if needed
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        
        // Update map region (zoom)
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude:  coordinate.latitude, longitude: coordinate.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02) // smaller delta = closer zoom
        )
        mapView.setRegion(region, animated: true)
        */
        
    }
    
    
    
    func uploadFIleToServer(){
        
        var url = Constant.shared.add_itemURL
       
        if popType == .editPost {
            url = Constant.shared.update_itemURL
        }
        
        params["isPostValidate"] = isPostValidate
        
        URLhandler.sharedinstance.uploadImageArrayWithParameters(imageData: imgData ?? Data(), imageName: imgName, imagesData: gallery_images, imageNames: gallery_imageNames, url: url, params: self.params, completionHandler: { responseObject, error in

            if error == nil {
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshAdsScreen.rawValue), object: nil, userInfo: nil)

                
                if code == 200{
                    
                    if let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) {
                        do {
                            let item = try JSONDecoder().decode(SingleItemParse.self, from: jsonData)
                            if let itemObj = item.data?.first {
                                let vc = UIHostingController(rootView: AddPostSuccessView( navigationController: self.navigationController, itemObj: itemObj ))
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }catch {
                            
                        }
                        
                    } else {
                        print("Something is wrong while converting dictionary to JSON data.")
                        
                    }
                    
                }else{
                    
                    if let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) {
                        do {
                            let item = try JSONDecoder().decode(SingleItemParse.self, from: jsonData)
                            if let itemObj = item.data?.first {
                                
                                if itemObj.status?.lowercased() == "draft"{
                                    DispatchQueue.main.async {
                                        
                                        let swiftView = AdNotPostedView(navigationController: self.navigationController,itemObj: itemObj,message:message)
                                        let destVC = UIHostingController(rootView: swiftView)
                                        self.navigationController?.pushViewController(destVC, animated: true)
                                    }
                                }else{
                                    AlertView.sharedManager.showToast(message: message)
                                }
                            }else{
                                AlertView.sharedManager.showToast(message: message)
                            }
                        }catch {

                        }
                        
                    } else {
                        print("Something is wrong while converting dictionary to JSON data.")
                        
                        AlertView.sharedManager.showToast(message: message)
                        
                    }

                }
            }
        })
    }
    
}



extension PostAdFinalVC :LocationAutorizationUpdated {
    func locationAuthorizationUpdate(isToUpdateLocation:Bool) {
        
        if LocationManager.sharedInstance.manager.authorizationStatus == .authorizedAlways  ||  LocationManager.sharedInstance.manager.authorizationStatus == .authorizedWhenInUse {
            if let coordinate = LocationManager.sharedInstance.lastKnownLocation {
                print("Latitude: \(coordinate.latitude)")
                print("Longitude: \(coordinate.longitude)")
                
                if popType == .home || popType == .signUp{
                    
                    Local.shared.saveUserLocation(city: LocationManager.sharedInstance.city, state: LocationManager.sharedInstance.state, country: LocationManager.sharedInstance.country, latitude:"\(LocationManager.sharedInstance.latitude)", longitude:"\(LocationManager.sharedInstance.longitude)", timezone: LocationManager.sharedInstance.timezone)
                }
                
                print(Local.shared.getUserCity(), Local.shared.getUserState(), Local.shared.getUserCountry(),Local.shared.getUserTimeZone())
                
                
                LocationManager.sharedInstance.delegate = nil
                /*
                viewModel.mapRegion.center =  LocationManager.sharedInstance.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                viewModel.mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                
                viewModel.locationInfo = Local.shared.getUserCity() + "," + Local.shared.getUserState() + "," + Local.shared.getUserCountry()
                viewModel.circle = MKCircle(center: LocationManager.sharedInstance.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), radius: (range1) as CLLocationDistance)
                
                viewModel.selectedCoordinate = LocationManager.sharedInstance.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                */
              /*  let latitude = LocationManager.sharedInstance.latitude
                let longitude = LocationManager.sharedInstance.longitude
                let state = LocationManager.sharedInstance.state
                let country = LocationManager.sharedInstance.country
                let city = LocationManager.sharedInstance.city
                let locality = LocationManager.sharedInstance.locality*/
                
                if isToUpdateLocation{
                    self.savePostLocation(latitude:"\(coordinate.latitude)", longitude: "\(coordinate.longitude)", city: LocationManager.sharedInstance.city, state: LocationManager.sharedInstance.state, country: LocationManager.sharedInstance.country, locality: LocationManager.sharedInstance.locality)
                }

                
            } else {
                print("Unknown Location")
            }
        }else{
            
        }
    }
    
}

//
//
//// MARK: ImagePicker Delegate
//extension PostAdFinalVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentPickerDelegate {
//  
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        
//        
//        
//        if let pickedImage = info[.originalImage] as? UIImage {
//            imgViewProfile.image = pickedImage.wxCompress()
//
//        }
//        
//        dismiss(animated: true, completion: nil)
//        
//    }
//    
//    
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        // Handle the user canceling the image picker, if needed.
//        dismiss(animated: true, completion: nil)
//    }
//    
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        print(urls)
//        
//        
//    }
//  
//    
//    @objc func showImagePickerOptions(tag:Int) {
//        let actionSheet = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
//        
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
//                self.openImagePicker(sourceType: .camera)
//            }))
//        }
//
//        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
//            self.openImagePicker(sourceType: .photoLibrary)
//        }))
//        
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//        // For iPad: prevent crash
//        if let popoverController = actionSheet.popoverPresentationController {
//            popoverController.sourceView = self.view
//            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//            popoverController.permittedArrowDirections = []
//        }
//
//        present(actionSheet, animated: true)
//    }
//    
//    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
//        
//        if sourceType == .camera{
//            imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
//             imagePicker.delegate = self
//             imagePicker.sourceType = sourceType
//             imagePicker.allowsEditing = false
//             self.present(imagePicker, animated: true)
//        }else{
//            presentPhotoPicker()
//        }
//
//
//    }
//}
//
//
////MARK: PHPickerDelegate
//extension PostAdFinalVC:  PHPickerViewControllerDelegate{
//    
//    
//    func presentPhotoPicker() {
//        
//        var configuration = PHPickerConfiguration()
//        configuration.selectionLimit = 1
//        configuration.filter = .images
//        let picker = PHPickerViewController(configuration: configuration)
//        picker.delegate = self
//        picker.modalPresentationStyle = .fullScreen
//        present(picker, animated: true, completion: nil)
//    }
//    
//    
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        picker.dismiss(animated: true, completion: nil)
//        
//        for result in results {
//            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
//                result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
//                    if let pickedImage = object as? UIImage {
//                        print("Selected image: \(pickedImage)")
//                        
//                        DispatchQueue.main.async {
//                            
//                            self.imgViewProfile.image = pickedImage.wxCompress()
//                        }
//                    }
//                    
//                }
//            }
//        }
//    }
//}

extension PostAdFinalVC:
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UIDocumentPickerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {

        if let image = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true) {
               // self.imgViewProfile.image = image.wxCompress()
               // self.presentCropper(image: image)
                
                self.imgViewProfile.image = image.wxCompress()
                 self.selectedImage = image
                 self.openCropper(image: image)
            }
        } else {
            picker.dismiss(animated: true)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        print(urls)
    }
}

extension PostAdFinalVC {

    @objc func showImagePickerOptions(tag: Int) {

        let actionSheet = UIAlertController(
            title: "Choose Image Source",
            message: nil,
            preferredStyle: .actionSheet
        )

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.openImagePicker(sourceType: .camera)
            })
        }

        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.presentPhotoPicker()
        })

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        present(actionSheet, animated: true)
    }
}

extension PostAdFinalVC {

    func openImagePicker(sourceType: UIImagePickerController.SourceType) {

        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = .fullScreen

        present(imagePicker, animated: true)
    }
}

extension PostAdFinalVC: PHPickerViewControllerDelegate {

    func presentPhotoPicker() {

        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen

        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController,
                didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { image, error in
            guard let uiImage = image as? UIImage else { return }

            DispatchQueue.main.async {
               self.imgViewProfile.image = uiImage.wxCompress()
                self.selectedImage = uiImage
                self.openCropper(image: uiImage)
            }
        }
    }
}

extension PostAdFinalVC{
    
    func openCropper(image: UIImage) {
        
        let cropVC = ImageCropperController(
            image: image,
            onCropped: { [weak self] croppedImage in
                self?.imgViewProfile.image = croppedImage
                self?.selectedImage = croppedImage
            },
            onCancel: {
                print("Crop cancelled")
            }
        )
        
        cropVC.modalPresentationStyle = .fullScreen
        present(cropVC, animated: true)
    }
}




final class CropImageBottomBarView: UIView {

    var onCancel: (() -> Void)?
    var onDone: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.9)

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [cancelButton, UIView(), doneButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func cancelTapped() {
        onCancel?()
    }

    @objc private func doneTapped() {
        onDone?()
    }
}

import UIKit
import Mantis

final class ImageCropperController: UIViewController {

    private let image: UIImage
    private let onCropped: (UIImage) -> Void
    private let onCancel: () -> Void

    private weak var cropVC: CropViewController?

    init(
        image: UIImage,
        onCropped: @escaping (UIImage) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.image = image
        self.onCropped = onCropped
        self.onCancel = onCancel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCropper()
    }

    private func setupCropper() {

        view.backgroundColor = .black

        var config = Mantis.Config()
        config.showAttachedCropToolbar = false   // ✅ hide default toolbar
        // Free-hand crop → DO NOT set presetFixedRatioType

        let cropVC = Mantis.cropViewController(image: image, config: config)
        cropVC.delegate = self
        self.cropVC = cropVC

        addChild(cropVC)
        view.addSubview(cropVC.view)
        cropVC.didMove(toParent: self)

        cropVC.view.translatesAutoresizingMaskIntoConstraints = false

        // Bottom bar
        let bottomBar = CropImageBottomBarView()
        bottomBar.translatesAutoresizingMaskIntoConstraints = false

        bottomBar.onCancel = { [weak self] in
            self?.onCancel()
            self?.dismiss(animated: true)
        }

        bottomBar.onDone = { [weak self] in
            self?.cropVC?.crop()
        }

        view.addSubview(bottomBar)

        NSLayoutConstraint.activate([
            cropVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            cropVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cropVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cropVC.view.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}

extension ImageCropperController: CropViewControllerDelegate {

    func cropViewControllerDidCrop(
        _ cropViewController: CropViewController,
        cropped: UIImage,
        transformation: Transformation,
        cropInfo: CropInfo
    ) {
        onCropped(cropped)
        dismiss(animated: true)
    }

    func cropViewControllerDidCancel(
        _ cropViewController: CropViewController,
        original: UIImage
    ) {
        onCancel()
        dismiss(animated: true)
    }
}
