

// MARK: - CategoryParse
struct CategoryParse: Codable {
    let error: Bool?
    let message: Message?
    let data: CategoryModelClass?
    let code: Int?
    let selfCategory: JSONNull?

    enum CodingKeys: String, CodingKey {
        case error, message, data, code
        case selfCategory = "self_category"
    }
}

// MARK: - DataClass
struct CategoryModelClass: Codable {
    let currentPage: Int?
    let data: [CategoryModel]?
    let firstPageURL: String?
    let from, lastPage: Int?
    let lastPageURL: String?
    let links: [Link]?
    let nextPageURL, path: String?
    let perPage: Int?
    let prevPageURL: JSONNull?
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

// MARK: - Datum
struct CategoryModel: Codable {
    let id, sequence: Int?
    let name: String?
    let image: String?
    let parentCategoryID: JSONNull?
    let description: String?
    let status: Int?
    let createdAt, updatedAt, slug: String?
    let subcategoriesCount, allItemsCount: Int?
    let translatedName: String?
    let translations: [JSONAny]?
    let subcategories: [Subcategory]?

    enum CodingKeys: String, CodingKey {
        case id, sequence, name, image
        case parentCategoryID = "parent_category_id"
        case description, status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case slug
        case subcategoriesCount = "subcategories_count"
        case allItemsCount = "all_items_count"
        case translatedName = "translated_name"
        case translations, subcategories
    }
}

// MARK: - Subcategory
struct Subcategory: Codable, Identifiable {
    let id: Int?
    let sequence: Int?
    let name: String?
    let image: String?
    let parentCategoryID: Int?
    let description: String?
    let status: Int?
    let createdAt, updatedAt, slug: String?
    let approvedItemsCount, subcategoriesCount: Int?
    let translatedName: String?
    let subcategories: [Subcategory]?
    let translations: [JSONAny]?

    enum CodingKeys: String, CodingKey {
        case id, sequence, name, image
        case parentCategoryID = "parent_category_id"
        case description, status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case slug
        case approvedItemsCount = "approved_items_count"
        case subcategoriesCount = "subcategories_count"
        case translatedName = "translated_name"
        case subcategories, translations
    }
}

// MARK: - Link
struct Link: Codable {
    let url: String?
    let label: String?
    let active: Bool?
}

// MARK: - Message
struct Message: Codable {
}

