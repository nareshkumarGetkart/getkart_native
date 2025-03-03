//
//  ItemModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/02/25.
//

// MARK: - ItemParse
struct ItemParse: Codable {
    
    let error: Bool
    let message: String
    let data: ItemModelClass?
    let code: Int
}


// MARK: - ItemClass
struct ItemModelClass: Codable {
    let currentPage: Int
    let data: [ItemModel]?
    let firstPageURL: String
    let from, lastPage: Int
    let lastPageURL: String
    let links: [Link]
    let nextPageURL, path: String
    let perPage: Int
    //let prevPageURL: JSONNull?
    let to, total: Int

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
       // case prevPageURL = "prev_page_url"
        case to, total
    }
}

// MARK: - Datum
struct ItemModel: Codable {
    let id: Int
    let name, slug, description: String
    let price: Int
    let image: String
    let watermarkImage: JSONNull?
    let latitude, longitude: Double
    let address, contact: String
    let showOnlyToPremium: Int
    let status: Status
    let rejectedReason: String
    let videoLink: JSONNull?
    let clicks: Int
    let city, state: String
    let country: Country
    let areaID: JSONNull?
    let userID: Int
    let soldTo: JSONNull?
    let categoryID: Int
    let allCategoryIDS, expiryDate, createdAt, updatedAt: String
    let deletedAt: JSONNull?
    let user: User
    let category: Category?
    let galleryImages: [GalleryImage]
    let featuredItems, favourites: [JSONAny]
    let area: JSONNull?
    let isFeature: Bool
    let totalLikes: Int
    let isLiked: Bool
   // let customFields: [CustomField]
    let isAlreadyOffered, isAlreadyReported: Bool
    let isPurchased: Int

    enum CodingKeys: String, CodingKey {
        case id, name, slug, description, price, image
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
        case featuredItems = "featured_items"
        case favourites, area
        case isFeature = "is_feature"
        case totalLikes = "total_likes"
        case isLiked = "is_liked"
       // case customFields = "custom_fields"
        case isAlreadyOffered = "is_already_offered"
        case isAlreadyReported = "is_already_reported"
        case isPurchased = "is_purchased"
    }
}

// MARK: - Category
struct Category: Codable {
    let id: Int
    let name: String
    let image: String
    let translatedName: String

    enum CodingKeys: String, CodingKey {
        case id, name, image
        case translatedName = "translated_name"
    }
}

enum Country: String, Codable {
    case india = "India"
}

// MARK: - CustomField
struct CustomField: Codable {
    let id: Int
    let name: String
    let type: TypeEnum
    let image: String
    let customFieldRequired: Int
    let values: [String]
    let minLength, maxLength: Int?
    let status: Int
    let value: [String]
    let customFieldValue: CustomFieldValue

    enum CodingKeys: String, CodingKey {
        case id, name, type, image
        case customFieldRequired = "required"
        case values
        case minLength = "min_length"
        case maxLength = "max_length"
        case status, value
        case customFieldValue = "custom_field_value"
    }
}

// MARK: - CustomFieldValue
struct CustomFieldValue: Codable {
    let id, itemID, customFieldID: Int
    let value: [String]
    let createdAt, updatedAt: AtedAt

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

enum TypeEnum: String, Codable {
    case checkbox = "checkbox"
    case dropdown = "dropdown"
    case number = "number"
    case radio = "radio"
    case textbox = "textbox"
}

// MARK: - GalleryImage
struct GalleryImage: Codable {
    let id: Int
    let image: String
    let itemID: Int

    enum CodingKeys: String, CodingKey {
        case id, image
        case itemID = "item_id"
    }
}

enum Status: String, Codable {
    case approved = "approved"
}

// MARK: - User
struct User: Codable {
    let id: Int
    let name, email: String
    let mobile: String?
    let profile: String?
    let createdAt: String
    let isVerified, showPersonalDetails: Int
    let countryCode: String?
    let reviewsCount: Int
    let averageRating: JSONNull?
    let sellerReview: [JSONAny]

    enum CodingKeys: String, CodingKey {
        case id, name, email, mobile, profile
        case createdAt = "created_at"
        case isVerified = "is_verified"
        case showPersonalDetails = "show_personal_details"
        case countryCode = "country_code"
        case reviewsCount = "reviews_count"
        case averageRating = "average_rating"
        case sellerReview = "seller_review"
    }
}





