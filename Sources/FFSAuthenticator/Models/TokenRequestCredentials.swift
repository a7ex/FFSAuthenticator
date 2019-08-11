//
//  TokenRequestCredentials.swift
//  AuthSession
//
//  Created by Alex da Franca on 28.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

/// Client credentials are used for authenticating with the token endpoint.
public struct TokenRequestCredentials {
    public let id: String
    public let secret: String?
    
    /// Returns the client credentials as paramters.
    ///
    /// Includes the client identifier as `client_id` and the client secret,
    /// if set, as `client_secret`.
    public var parameters: [String: String] {
        var parameters = ["client_id": id]
        if let secret = secret {
            parameters["client_secret"] = secret
        }
        return parameters
    }
}
