//
//  AuthSessionAccessTokenDefaultParser.swift
//  AuthSession
//
//  Created by Alex da Franca on 28.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

struct AuthSessionAccessTokenDefaultParser: AuthSessionAccessTokenParser {
    func parse(data: Data) throws -> JWToken {
        let parsedToken = try JSONDecoder().decode(JWToken.self, from: data)
        return parsedToken
    }
}
