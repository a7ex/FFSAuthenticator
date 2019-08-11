//
//  AuthSessionAccessTokenParser.swift
//  AuthSession
//
//  Created by Alex da Franca on 28.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

public protocol AuthSessionAccessTokenParser {
    func parse(data: Data) throws -> JWToken
}
