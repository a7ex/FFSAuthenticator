//
//  AuthSessionRequestAuthenticator.swift
//  AuthSession
//
//  Created by Alex da Franca on 28.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

public struct AuthSessionRequestAuthenticator: RequestAuthenticator {
    /// Authenticates the given request by setting the HTTP `Authorization`
    /// header.
    ///
    /// - parameter request: The request to be authenticated.
    /// - parameter accessToken: The access token that should be used for
    ///     authenticating the request.
    ///
    /// - returns: The authenticated request.
    public func authenticateRequest<T: CanSetHeaderValues>(_ request: T, accessToken: JWToken) -> T {
        var mutableRequest = request
        mutableRequest.setHTTPAuthorization(.accessTokenAuthentication(accessToken))
        return mutableRequest
    }
}
