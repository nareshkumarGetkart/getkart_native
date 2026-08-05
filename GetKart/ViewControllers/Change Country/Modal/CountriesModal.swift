
//
//  Untitled.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/07/26.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let countriesModal = try? JSONDecoder().decode(CountriesModal.self, from: jsonData)

import Foundation

// MARK: - CountriesModal
struct CountriesModal: Codable {
    let error: Bool?
    let message: String?
    let data: [Countries]?

    enum CodingKeys: String, CodingKey {
        case error = "error"
        case message = "message"
        case data = "data"
    }
}

// MARK: - Datum
struct Countries: Codable {
    let id: Int?
    let name: String?
    let iso3: String?
    let iso2: String?
    let numericCode: String?
    let phoneCode: String?
    let capital: String?
    let currency: String?
    let currencyName: String?
    let currencySymbol: String?
    let tld: String?
    let native: String?
    let region: String?
    let regionID: String?
    let subregion: String?
    let subregionID: String?
    let nationality: String?
    let timezones: [Timezone]?
    let latitude: String?
    let longitude: String?
    let emoji: String?
    let emojiU: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case iso3 = "iso3"
        case iso2 = "iso2"
        case numericCode = "numeric_code"
        case phoneCode = "phone_code"
        case capital = "capital"
        case currency = "currency"
        case currencyName = "currency_name"
        case currencySymbol = "currency_symbol"
        case tld = "tld"
        case native = "native"
        case region = "region"
        case regionID = "region_id"
        case subregion = "subregion"
        case subregionID = "subregion_id"
        case nationality = "nationality"
        case timezones = "timezones"
        case latitude = "latitude"
        case longitude = "longitude"
        case emoji = "emoji"
        case emojiU = "emojiU"
    }
}

// MARK: - Timezone
struct Timezone: Codable {
    let zoneName: String?
    let gmtOffset: Int?
    let gmtOffsetName: String?
    let abbreviation: String?
    let tzName: String?

    enum CodingKeys: String, CodingKey {
        case zoneName = "zoneName"
        case gmtOffset = "gmtOffset"
        case gmtOffsetName = "gmtOffsetName"
        case abbreviation = "abbreviation"
        case tzName = "tzName"
    }
}
