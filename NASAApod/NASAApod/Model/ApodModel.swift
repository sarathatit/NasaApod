//
//  ApodModel.swift
//  NASAApod
//
//  Created by Sarath kumar on 09/08/24.
//

import Foundation

struct ApodModel: Codable {
    let date, explanation: String?
    let hdurl: String?
    let mediaType, serviceVersion, title: String?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case date, explanation, hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title, url
    }
}

