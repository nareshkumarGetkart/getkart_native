//
//  BlogModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 10/03/25.
//

import Foundation



// MARK: - Blogs
struct Blogs: Codable {
    let error: Bool?
    let message: String?
    let data: BlogsClass?
    let code: Int?
    let otherBlogs: [JSONAny]?

    enum CodingKeys: String, CodingKey {
        case error, message, data, code
        case otherBlogs
    }
}

// MARK: - DataClass
struct BlogsClass: Codable {
    let currentPage: Int?
    let data: [BlogsModel]?
    let firstPageURL: String?
    let from, lastPage: Int?
    let lastPageURL: String?
    let links: [Link]?
    let nextPageURL: String?
    let path: String?
    let perPage: Int?
    let prevPageURL: String?
    let to, total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage
        case data
        case firstPageURL
        case from
        case lastPage
        case lastPageURL
        case links
        case nextPageURL
        case path
        case perPage
        case prevPageURL
        case to, total
    }
}

// MARK: - Datum
struct BlogsModel: Codable,Identifiable {
    let id: Int?
    let title, slug, description: String?
    let image: String?
    let tags: [String]?
    let views: Int?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, slug, description, image, tags, views
        case createdAt
        case updatedAt
    }
}

