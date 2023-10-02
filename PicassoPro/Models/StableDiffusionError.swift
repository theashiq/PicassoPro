//
//  StableDiffusionError.swift
//  PicassoPro
//
//  Created by mac 2019 on 10/2/23.
//

import Foundation

enum StableDiffusionError: Error, LocalizedError, Equatable{
    case apiError(String)
    case networkError(String)
    case unknownError(String = "An  error occurred. Please retry after sometime")
    
    var errorDescription: String?{
        switch self{
        case .apiError(let message):
            return message
        case .networkError(let message):
            return message
        case .unknownError(let message):
            return message
        }
    }
}

extension StableDiffusionError: RawRepresentable {

    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "API Error":  self = .apiError("API Error")
        case "Network Error":  self = .networkError("Network Error")
        case "Error":  self = .unknownError()
        default:
            return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .apiError: return "API Error"
        case .networkError: return "Network Error"
        case .unknownError: return "Unknown Error"
        }
    }
}
