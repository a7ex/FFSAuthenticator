//
//  AuthSessionDefaultServer.swift
//  AuthSession
//
//  Created by Alex da Franca on 28.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

public struct AuthSessionDefaultServer: ServerConnector {
    private let urlSession: URLSession
    
    /// Initializes a new client.
    ///
    /// - parameter urlSession: The URLSession to use.
    ///     Default: `URLSession(configuration: URLSessionConfiguration.defaultSessionConfiguration())`.
    ///
    /// - returns: A new client using the given `URLSession`.
    public init(urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.urlSession = urlSession
    }
    
    /// Sends the given request.
    ///
    /// - parameter request: The request to be sent.
    /// - parameter completion: A callback to invoke when the request completed.
    public func sendRequest(_ request: URLRequest,
                            completion: @escaping (Data?, URLResponse?, Error?) -> Void
        ) {
        _ = urlSession
            .dataTask(with: request, completionHandler: completion)
            .resume()
    }
}
