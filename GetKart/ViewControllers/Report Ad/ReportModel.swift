//
//  ReportModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 10/03/25.
//

import Foundation

// MARK: - Report
struct Report: Codable {
    let error: Bool?
    let message: String?
    let data: DataClass?
    let code, total: Int?
}

// MARK: - DataClass
struct DataClass: Codable {
    let currentPage: Int?
    let data: [ReportModel]?
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
struct ReportModel: Identifiable, Codable {
    let id: Int?
    let reason, createdAt, updatedAt: String?
    

    enum CodingKeys: String, CodingKey {
        case id, reason
        case createdAt
        case updatedAt
    }
}

