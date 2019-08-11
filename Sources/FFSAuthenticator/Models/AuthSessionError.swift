//
//  AuthSessionError.swift
//  AuthSession
//
//  Created by Alex da Franca on 28.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

public enum AuthSessionError: Error {
    case unableToRetrieveToken(String)
    case errorWithNoData(String)
    case noRefreshToken
    case notAuthorized
    
    public var localizedDescription: String {
        switch self {
        case .unableToRetrieveToken:
            return "Could not get token. Expected access token" //, but got: \(tokenValue)."
        case .errorWithNoData:
            return "Could not authorize. Expected error" //, but got: \(responseAsString)."
        case .noRefreshToken:
            return "Access token expired, no refresh token available."
        case .notAuthorized:
            return "Not authorized. You need to login first."
        }
    }
}

/// See: The OAuth 2.0 Authorization Framework, 5.2 NSError Response
///      <https://tools.ietf.org/html/rfc6749#section-5.2>

public enum OAuthErrorCode: String, Codable {
    case InvalidRequest = "invalid_request"
    case InvalidClient = "invalid_client"
    case InvalidGrant = "invalid_grant"
    case UnauthorizedClient = "unauthorized_client"
    case UnsupportedGrantType = "unsupported_grant_type"
    case InvalidScope = "invalid_scope"
}

public struct OAuthError: Error, Codable {
    public let code: OAuthErrorCode
    public let description: String?
    public let uri: String?
    
    public enum CodinKeys: String {
        case code = "error"
        case description = "error_description"
        case uri = "error_uri"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(OAuthErrorCode.self, forKey: .code)
        description = try? container.decode(String.self, forKey: .description)
        uri = try? container.decode(String.self, forKey: .uri)
    }
}

extension OAuthError {
    static func decode(data: Data) -> OAuthError? {
        return try? JSONDecoder().decode(OAuthError.self, from: data)
    }
}
