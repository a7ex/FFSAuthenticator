//
//  AuthSessionTokenStore.swift
//  AuthSession
//
//  Created by Alex da Franca on 27.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

public protocol AuthSessionTokenStore {
    /// Stores the given access token.
    ///
    /// Given nil, it resets the currently stored access token, if any.
    ///
    /// - parameter accessToken: The access token to be stored.
    func storeAccessToken(_ accessToken: JWToken?)
    
    /// Retrieves the currently stored access token.
    ///
    /// - returns: The currently stored access token.
    func retrieveAccessToken() -> JWToken?
}
