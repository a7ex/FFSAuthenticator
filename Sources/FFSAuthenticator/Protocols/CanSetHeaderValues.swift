//
//  CanSetHeaderValues.swift
//  AuthSession
//
//  Created by Alex da Franca on 28.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

public protocol CanSetHeaderValues {
    /// Ability to modify the http header dictionary
    /// Thus it allows for request transformation after creation and handle specific tasks seperately.
    ///
    /// One usecase is for example authentication
    /// In order to 'authenticate' a request, we need to be able to change the request's headers
    /// so that we can add a value for authentication.
    mutating func setValue(_ value: String?, forHTTPHeaderField field: String)
}

extension URLRequest: CanSetHeaderValues { }

private let HTTPRequestHeaderFieldAuthorization = "Authorization"

extension CanSetHeaderValues {
    
    /// Sets the HTTP `Authorization` header value.
    ///
    /// - parameter value: The value to be set or `nil`.
    mutating func setHTTPAuthorization(_ value: String?) {
        setValue(value, forHTTPHeaderField: HTTPRequestHeaderFieldAuthorization)
    }
    
    /// Sets the HTTP `Authorization` header value using the given HTTP
    /// authentication.
    ///
    /// - parameter authentication: The HTTP authentication to be set.
    mutating func setHTTPAuthorization(_ authentication: HTTPAuthentication) {
        setHTTPAuthorization(authentication.authString)
    }
}
