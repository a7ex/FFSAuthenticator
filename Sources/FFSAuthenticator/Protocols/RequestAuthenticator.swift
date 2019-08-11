//
//  RequestAuthenticator.swift
//  AuthSession
//
//  Created by Alex da Franca on 28.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

public protocol RequestAuthenticator {
    /// Authenticates the given request.
    ///
    /// - parameter request: The request to be authenticated.
    /// - parameter accessToken: The access token that should be used for
    ///     authenticating the request.
    ///
    /// - returns: The authenticated request.
    func authenticateRequest<T: CanSetHeaderValues>(_ request: T, accessToken: JWToken) -> T
}
