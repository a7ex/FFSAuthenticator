//
//  AuthSessionTokenKeychainStore.swift
//  AuthSession
//
//  Created by Alex da Franca on 27.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

/// A persistent keychain-based access token store.
class AuthSessionTokenKeychainStore: AuthSessionTokenStore {
    private var keychain: Keychain
    
    private struct Constants {
        static let defaultKeychainServiceIdentifier = "de.farbflash.authSession.authData"
        static let accessToken = "access_token"
        static let tokenType = "token_type"
        static let expiresAt = "expires_at"
        static let refreshToken = "refresh_token"
    }
    
    /// Creates an instance initialized to the given keychain service.
    ///
    /// - parameter service: The keychain service.
    ///     Default: `de.farbflash.authSession.authData`.
    init(service: String = "") {
        let identifier = (service != "") ? service: Constants.defaultKeychainServiceIdentifier
        keychain = Keychain(service: identifier)
    }
    
    func storeAccessToken(_ accessToken: JWToken?) {
        keychain[Constants.accessToken] = accessToken?.accessToken
        keychain[Constants.tokenType] = accessToken?.tokenType
        keychain[Constants.expiresAt] = accessToken?.expiresAt?.timeIntervalSince1970.description
        keychain[Constants.refreshToken] = accessToken?.refreshToken
    }
    
    func retrieveAccessToken() -> JWToken? {
        let accessToken = keychain[Constants.accessToken]
        let tokenType = keychain[Constants.tokenType]
        let refreshToken = keychain[Constants.refreshToken]
        let expiresAt = keychain[Constants.expiresAt].flatMap { description in
            return Double(description).flatMap { expiresAtInSeconds in
                Date(timeIntervalSince1970: expiresAtInSeconds)
            }
        }
        if let accessToken = accessToken,
            let tokenType = tokenType {
            return JWToken(accessToken: accessToken,
                               tokenType: tokenType,
                               expiresAt: expiresAt,
                               refreshToken: refreshToken)
        }
        return nil
    }
}
