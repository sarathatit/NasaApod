//
//  ServiceError.swift
//  NASAApod
//
//  Created by Sarath kumar on 09/08/24.
//

import Foundation

enum ServiceError: Error {
    case networkError(description: String)
    case parseError(description: String)
}
