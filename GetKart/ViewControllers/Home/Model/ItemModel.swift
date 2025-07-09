//
//  ItemModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/02/25.
//
import Foundation

 
// MARK: - Empty
struct ItemParse: Codable {
    let error: Bool?
    let message: String?
    let data: ItemModelClass?
    let code: Int?
}


struct SingleItemParse: Codable {
    
    let error: Bool?
    let message: String?
    let data: [ItemModel]?
    let code: Int?
}

// MARK: - DataClass
struct ItemModelClass: Codable {
    
    let currentPage: Int?
    var data: [ItemModel]?
    let firstPageURL: String?
    let from, lastPage: Int?
    let lastPageURL: String?
    let links: [Link]?
    let nextPageURL, path: String?
    let perPage: Int?
    let prevPageURL: String?
    let to, total: Int?

    enum CodingKeys: String, CodingKey {
        
        case currentPage = "current_page"
        case data
        case firstPageURL = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageURL = "last_page_url"
        case links
        case nextPageURL = "next_page_url"
        case path
        case perPage = "per_page"
        case prevPageURL = "prev_page_url"
        case to, total
    }
}

// MARK: - ItemModel
struct ItemModel: Codable,Identifiable {
    let id: Int?
    let name, slug, description: String?
    let price: Double?
    let image: String?
    let watermarkImage: String?
    let latitude, longitude: Double?
    let address, contact: String?
    let showOnlyToPremium: Int?
    let status: String?
    let rejectedReason: String?
    let videoLink: String?
    let clicks: Int?
    let city, state: String?
    let country: String?
    let areaID: String?
    let userID: Int?
    let soldTo: Int?
    let categoryID: Int?
    let allCategoryIDS, expiryDate, createdAt, updatedAt: String?
    let deletedAt: String?
    let user: User?
    let category: Category?
    var galleryImages: [GalleryImage]?
   // let featuredItems: [JSONAny]?
    let favourites: [Favourite]?
    let area: Int?
    var isFeature: Bool?
    let totalLikes: Int?
    var isLiked: Bool?
    let customFields: [CustomField]?
    var isAlreadyOffered, isAlreadyReported: Bool?
    let isPurchased: Int?
    var itemOffers:[ItemOffers]?
    let usedPackage:String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug, description, image
        case price
        case watermarkImage = "watermark_image"
        case latitude, longitude, address, contact
        case showOnlyToPremium = "show_only_to_premium"
        case status
        case rejectedReason = "rejected_reason"
        case videoLink = "video_link"
        case clicks, city, state, country
        case areaID = "area_id"
        case userID = "user_id"
        case soldTo = "sold_to"
        case categoryID = "category_id"
        case allCategoryIDS = "all_category_ids"
        case expiryDate = "expiry_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case user, category
        case galleryImages = "gallery_images"
      //  case featuredItems = "featured_items"
        case favourites, area
        case isFeature = "is_feature"
        case totalLikes = "total_likes"
        case isLiked = "is_liked"
        case customFields = "custom_fields"
        case isAlreadyOffered = "is_already_offered"
        case isAlreadyReported = "is_already_reported"
        case isPurchased = "is_purchased"
        case itemOffers = "item_offers"
        case usedPackage

    }
}

struct ItemOffers: Codable {
    
    let amount: Int?
    let buyerID: Int?
    let createdAt: String?
    let id: Int?
    let itemId: Int?
    let sellerID: Int?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        
        case amount = "amount"
        case buyerID = "buyer_id"
        case createdAt = "created_at"
        case id = "id"
        case itemId = "item_id"
        case sellerID = "seller_id"
        case updatedAt = "updated_at"
    }
    
}

// MARK: - Category
struct Category: Codable {
    let id: Int?
    let name: String?
    let image: String?
    let translatedName: String?

    enum CodingKeys: String, CodingKey {
        case id, name, image
        case translatedName = "translated_name"
    }
}

enum Country: String, Codable {
    case india = "India"
}

// MARK: - CustomField
struct CustomField: Codable,Identifiable  {
    let id: Int?
    let name: String?
    let type: TypeEnum?
    let image: String?
    let customFieldRequired: Int?
    var values: [String?]?
    let minLength, maxLength: Int?
    let status: Int?
    var value: [String?]?
    let customFieldValue: CustomFieldValue?
    let ranges:[PriceRange]?
    let minPrice, maxPrice: Double?
    var selectedMinValue: Double?
    var selectedMaxValue: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, image
        case customFieldRequired = "required"
        case values
        case value
        case minLength = "min_length"
        case maxLength = "max_length"
        case status
        case customFieldValue = "custom_field_value"
        case ranges = "ranges"
        case minPrice = "minPrice"
        case maxPrice = "maxPrice"
        case selectedMinValue
        case selectedMaxValue

    }
    
    init(id: Int?, name: String?, type: TypeEnum?, image: String?, customFieldRequired: Int?, values: [String?]?, minLength: Int?, maxLength: Int?, status: Int?, value: [String?]?, customFieldValue: CustomFieldValue?, arrIsSelected: Array<Bool>, selectedValue: String? = nil,ranges:Array<PriceRange> = [], minPrice: Double?=nil, maxPrice: Double?=nil,selectedMinValue:Double?=nil,selectedMaxValue:Double?=nil) {
        self.id = id
        self.name = name
        self.type = type
        self.image = image
        self.customFieldRequired = customFieldRequired
        self.values = values
        self.minLength = minLength
        self.maxLength = maxLength
        self.status = status
        self.value = value
        self.customFieldValue = customFieldValue
        self.ranges = ranges
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.selectedMinValue = selectedMinValue
        self.selectedMaxValue = selectedMaxValue
    }
  
}


struct PriceRange:Codable{
    
    let count:Int?
    let label:String?
    let max:Double?
    let min:Double?

    init(count: Int?, label: String?, max: Double?, min: Double?) {
        self.count = count
        self.label = label
        self.max = max
        self.min = min
    }
}

// MARK: - CustomFieldValue
struct CustomFieldValue: Codable {
    
    let id, itemID, customFieldID: Int?
    let value: Value?
    let createdAt, updatedAt: String?

        enum CodingKeys: String, CodingKey {
            case id
            case itemID = "item_id"
            case customFieldID = "custom_field_id"
            case value
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }
}

enum AtedAt: String, Codable {
    case the0000011130T000000000000Z = "-000001-11-30T00:00:00.000000Z"
}

enum Value: Codable {
    case string(String?)
    case stringArray([String?]?)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([String?]?.self) {
            self = .stringArray(x)
            return
        }
        if let x = try? container.decode(String?.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(Value.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Value"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .stringArray(let x):
            try container.encode(x)
        }
    }
}




enum TypeEnum: String, Codable {
    case checkbox = "checkbox"
    case dropdown = "dropdown"
    case fileinput = "fileinput"
    case number = "number"
    case radio = "radio"
    case textbox = "textbox"
    case range = "range"
    case sortby = "sortby"
    case category = "category"

}

// MARK: - Favourite
struct Favourite: Codable {
    let id: Int?
    let createdAt, updatedAt: String?
    let userID, itemID: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userID = "user_id"
        case itemID = "item_id"
    }
}

// MARK: - GalleryImage
struct GalleryImage: Codable {
    let id: Int?
    let image: String?
    let itemID: Int?
    var imgData:Data?

    enum CodingKeys: String, CodingKey {
        case id, image
        case itemID = "item_id"
        case imgData
    }
}

//enum Status: String, Codable {
//    case approved = "approved"
//}

// MARK: - User
struct User: Codable {
    let id: Int?
    let name, email: String?
    let mobile: String?
    let profile: String?
    let createdAt: String?
    let isVerified, showPersonalDetails: Int?
    let countryCode: String?
    let reviewsCount: Int?
    let averageRating: Int?
   // let sellerReview: [JSONAny]?
    let mobileVisibility: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, mobile, profile
        case createdAt = "created_at"
        case isVerified = "is_verified"
        case showPersonalDetails = "show_personal_details"
        case countryCode = "country_code"
        case reviewsCount = "reviews_count"
        case averageRating = "average_rating"
        case mobileVisibility
      //  case sellerReview = "seller_review"
    }
}

enum CountryCode: String, Codable {
    case empty = ""
    case the91 = "+91"
}

