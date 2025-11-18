//
//  SettingModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 08/04/25.
//

import Foundation


// MARK: - Settings
struct SettingsParse: Codable {
    
    let error: Bool?
    let message: String?
    let data: SettingsModel?
    let code: Int?
}

// MARK: - DataClass
struct SettingsModel: Codable {
    
    var currencySymbol:String = "₹"
    let companyName, iosVersion, defaultLanguage: String?
    let forceUpdate, androidVersion, numberWithSuffix, maintenanceMode: String?
    let privacyPolicy, termsConditions, companyTel1: String?
    let companyTel2: String?
    let razorpayGateway, paystackGateway, paypalGateway, systemVersion: String?
    let companyEmail, placeAPIKey: String?
    let fcmKey: String?
    let faviconIcon, companyLogo, loginImage: String?
    let aboutUs, bannerAdIDAndroid, bannerAdIDIos, bannerAdStatus: String?
    let interstitialAdIDAndroid, interstitialAdIDIos, interstitialAdStatus: String?
    let pinterestLink, linkedinLink, facebookLink, xLink: String?
    let instagramLink: String?
    let googleMapIframeLink, appStoreLink, playStoreLink: String?
    let footerDescription, webThemeColor, firebaseProjectID: String?
    let bannerScrollInterval:Int?
    let companyAddress, gecodeXyzAPIKey: String?
    let placeholderImage, webLogo: String?
    let serviceFile: String?
    let headerLogo: String?
    let footerLogo: String?
    let defaultLatitude, defaultLongitude, cancellationRefundPolicy, contactUs: String?
    let fileManager, showLandingPage, mobileAuthentication, googleAuthentication: String?
    let emailAuthentication, appleAuthentication, s3AwsAccessKeyID, s3AwsSecretAccessKey: String?
    let s3AwsDefaultRegion, s3AwsBucket: String?
    let s3AwsURL: String?
    let watermarkImage: String?
    let demoMode: Bool?
    let languages: [Language]?
    let admin: Admin?
    let iosPlaceKey:String?
    
    enum CodingKeys: String, CodingKey {
        case bannerScrollInterval
        case companyName = "company_name"
        case currencySymbol = "currency_symbol"
        case iosVersion = "ios_version"
        case defaultLanguage = "default_language"
        case forceUpdate = "force_update"
        case androidVersion = "android_version"
        case numberWithSuffix = "number_with_suffix"
        case maintenanceMode = "maintenance_mode"
        case privacyPolicy = "privacy_policy"
        case termsConditions = "terms_conditions"
        case companyTel1 = "company_tel1"
        case companyTel2 = "company_tel2"
        case razorpayGateway = "razorpay_gateway"
        case paystackGateway = "paystack_gateway"
        case paypalGateway = "paypal_gateway"
        case systemVersion = "system_version"
        case companyEmail = "company_email"
        case placeAPIKey = "place_api_key"
        case fcmKey = "fcm_key"
        case faviconIcon = "favicon_icon"
        case companyLogo = "company_logo"
        case loginImage = "login_image"
        case aboutUs = "about_us"
        case bannerAdIDAndroid = "banner_ad_id_android"
        case bannerAdIDIos = "banner_ad_id_ios"
        case bannerAdStatus = "banner_ad_status"
        case interstitialAdIDAndroid = "interstitial_ad_id_android"
        case interstitialAdIDIos = "interstitial_ad_id_ios"
        case interstitialAdStatus = "interstitial_ad_status"
        case pinterestLink = "pinterest_link"
        case linkedinLink = "linkedin_link"
        case facebookLink = "facebook_link"
        case xLink = "x_link"
        case instagramLink = "instagram_link"
        case googleMapIframeLink = "google_map_iframe_link"
        case appStoreLink = "app_store_link"
        case playStoreLink = "play_store_link"
        case footerDescription = "footer_description"
        case webThemeColor = "web_theme_color"
        case firebaseProjectID = "firebase_project_id"
        case companyAddress = "company_address"
        case gecodeXyzAPIKey = "gecode_xyz_api_key"
        case placeholderImage = "placeholder_image"
        case webLogo = "web_logo"
        case serviceFile = "service_file"
        case headerLogo = "header_logo"
        case footerLogo = "footer_logo"
        case defaultLatitude = "default_latitude"
        case defaultLongitude = "default_longitude"
        case cancellationRefundPolicy = "cancellation_refund_policy"
        case contactUs = "contact_us"
        case fileManager = "file_manager"
        case showLandingPage = "show_landing_page"
        case mobileAuthentication = "mobile_authentication"
        case googleAuthentication = "google_authentication"
        case emailAuthentication = "email_authentication"
        case appleAuthentication = "apple_authentication"
        case s3AwsAccessKeyID = "S3_aws_access_key_id"
        case s3AwsSecretAccessKey = "s3_aws_secret_access_key"
        case s3AwsDefaultRegion = "s3_aws_default_region"
        case s3AwsBucket = "s3_aws_bucket"
        case s3AwsURL = "s3_aws_url"
        case watermarkImage = "watermark_image"
        case demoMode = "demo_mode"
        case languages, admin
        case iosPlaceKey
    }
}

// MARK: - Admin
struct Admin: Codable {
    let name: String?
    let profile: String?
}

// MARK: - Language
struct Language: Codable {
    let id: Int?
    let code, name, nameInEnglish, appFile: String?
    let panelFile, webFile: String?
    let rtl: Bool?
    let image: String?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, code, name
        case nameInEnglish = "name_in_english"
        case appFile = "app_file"
        case panelFile = "panel_file"
        case webFile = "web_file"
        case rtl, image
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}




