//
//  HTTPAuthentication.swift
//  AuthSession
//
//  Created by Alex da Franca on 28.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

public enum HTTPAuthentication {
    /// HTTP Basic Authentication.
    ///
    /// - parameter username: The username.
    /// - parameter password: The password.
    case basicAuthentication(username: String, password: String)
    
    /// Access Token Authentication.
    ///
    /// - parameter _: The access token.
    case accessTokenAuthentication(JWToken)
    
    /// A refresh token grant.
    ///
    /// - parameter refreshToken: The refresh token.
    case refreshToken(String)
    
    /// An extension grant
    ///
    /// - parameter grantType: The grant type URI of the extension grant
    /// - parameter parameters: A dictionary of parameters
    case `extension`(String, [String: String])
    
    /// Returns the authentication encoded as `String` suitable for the HTTP
    /// `Authorization` header.
    var authString: String? {
        switch self {
        case let .basicAuthentication(username, password):
            if let credentials = "\(username):\(password)"
                .data(using: String.Encoding.ascii)?
                .base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
                return "Basic \(credentials)"
            } else {
                return nil
            }
        case let .accessTokenAuthentication(accessToken):
            return "\(accessToken.tokenType) \(accessToken.accessToken)"
        case .refreshToken:
            return ""
        case .extension:
            return ""
        }
    }
    
    /// Returns the grant's parameters.
    ///
    /// Except for `grant_type`, parameters are specific to each grant:
    ///
    /// - `.ResourceOwnerPasswordCredentials`: `username`, `password`
    /// - `.Refresh`: `refresh_token`
    /// - `.Extension`: `grantType`, `parameters`
    public var authRequestParameters: [String: String] {
        switch self {
        case let .basicAuthentication(username, password):
            return [
                "grant_type": "password",
                "username": username,
                "password": password,
            ]
        case let .accessTokenAuthentication(accessToken):
            return [
                "grant_type": "refresh_token",
                "refresh_token": accessToken.accessToken,
            ]
        case let .refreshToken(refreshToken):
            return [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken,
            ]
        case .extension(let grantType, var parameters):
            parameters["grant_type"] = grantType
            return parameters
        }
    }
}
