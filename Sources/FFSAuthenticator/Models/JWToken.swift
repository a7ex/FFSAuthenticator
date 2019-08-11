//
//  JWToken.swift
//  AuthSession
//
//  Created by Alex da Franca on 27.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

public struct JWToken: Codable, Equatable {
    let accessToken: String
    let tokenType: String
    let expiresAt: Date?
    let refreshToken: String?
    
    public func copy(accessToken: String? = nil,
                     tokenType: String? = nil,
                     expiresAt: Date?? = nil,
                     refreshToken: String?? = nil) -> JWToken {
        return JWToken(accessToken: accessToken ?? self.accessToken,
                           tokenType: tokenType ?? self.tokenType,
                           expiresAt: expiresAt ?? self.expiresAt,
                           refreshToken: refreshToken ?? self.refreshToken)
    }
    
    public init(accessToken: String,
         tokenType: String,
         expiresAt: Date?,
         refreshToken: String?) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresAt = expiresAt
        self.refreshToken = refreshToken
    }
}
