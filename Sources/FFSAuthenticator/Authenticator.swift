//
//  Authenticator.swift
//  AuthSession
//
//  Created by Alex da Franca on 28.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

/// Authenticator is a class which can, once authenticated, add authorization headers to any given request
///
/// It requires a URLRequest to use for requesting a token or refreshing a token.
/// All other initialization parameters are optional and can be used to override built-in functionality.
/// Those optional parameters are:
///  - Backing Store for the token (or use built-in iOS keychain store)
///  - Urlsession (or use the built-in simple URLSession with default configuration)
///  - AccessToken Parser (or use the built-in standard json decoder)
///  - Request Authenticator (or us the built-in Request Mapper, which adds "Authorization" to the request headers)
open class Authenticator {
    /// The url, where we can request the token
    public let tokenURLRequest: URLRequest
    
    /// The request authenticator that is used to authenticate requests.
    /// That is: adding a value to the header named "Authorization"
    public let requestAuthenticator: RequestAuthenticator
    
    /// Returns a Bool indicating whether the client's access token store
    /// currently holds an access token.
    ///
    /// **Note:** It's not checked whether the stored access token, if any, has
    ///     already expired.
    public var hasAccessToken: Bool {
        return accessToken != nil
    }
    
    /// Returns a Bool indicating whether the client's access token store
    /// currently holds an access token and it is not expired
    public var hasValidAccessToken: Bool {
        return (accessToken?.expiresAt ?? .distantPast) >= Date()
    }
    
    private let credentials: TokenRequestCredentials?
    private let serverConnector: ServerConnector
    private let accessTokenParser: AuthSessionAccessTokenParser
    private var requestQueue = DispatchQueue(label: "com.farbflash.AuthSession.requestQueue", attributes: [])
    
    private let accessTokenStore: AuthSessionTokenStore
    private var accessToken: JWToken? {
        get {
            return accessTokenStore.retrieveAccessToken()
        }
        set {
            accessTokenStore.storeAccessToken(newValue)
        }
    }
    
    /// Initializes a new client.
    ///
    /// - parameter tokenURLRequest: The URL request to use for authentication.
    /// - parameter credentials: The OAuth client credentials. If both an identifier
    ///     and a secret are set, client authentication is performed via HTTP
    ///     Basic Authentication. Otherwise, if only an identifier is set, it is
    ///     encoded as parameter. Default: `nil` (unauthenticated client).
    /// - parameter accessTokenStore: The (persistent) access token store.
    ///     Default: `AuthSessionTokenKeychainStore`.
    /// - parameter accessTokenParser: The access token response parser.
    ///     Default: `AuthSessionAccessTokenDefaultParser`.
    /// - parameter httpClient: The HTTP client that should be used for requesting
    ///     access tokens. Default: `AuthSessionDefaultServer`.
    /// - parameter resourceRequestAuthenticator: The request authenticator that is
    ///     used to authenticate requests. Default:
    ///     `AuthSessionRequestAuthenticator`.
    ///
    /// - returns: A new client initialized with the given token remote store,
    ///     credentials and access token store.
    public init(tokenURLRequest: URLRequest,
                credentials: TokenRequestCredentials? = nil,
                accessTokenStore: AuthSessionTokenStore? = nil,
                accessTokenParser: AuthSessionAccessTokenParser? = nil,
                serverConnector: ServerConnector? = nil,
                requestAuthenticator: RequestAuthenticator? = nil) {
        self.tokenURLRequest = tokenURLRequest
        self.credentials = credentials
        self.accessTokenStore = accessTokenStore ?? AuthSessionTokenKeychainStore()
        self.accessTokenParser = accessTokenParser ?? AuthSessionAccessTokenDefaultParser()
        self.serverConnector = serverConnector ?? AuthSessionDefaultServer()
        self.requestAuthenticator = requestAuthenticator ?? AuthSessionRequestAuthenticator()
    }
    
    deinit {
        releaseRequestQueue()
    }
    
    /// Invalidates the currently stored access token, if any.
    ///
    /// Unlike `clearAccessToken` this will only invalidate the access token so
    /// that Heimdallr will try to refresh the token using the refresh token
    /// automatically.
    ///
    /// **Note:** Sets the access token's expiration date to
    ///     1 January 1970, GMT.
    open func invalidateAccessToken() {
        accessToken = accessToken?.copy(expiresAt: Date(timeIntervalSince1970: 0))
    }
    
    /// Clears the currently stored access token, if any.
    ///
    /// After calling this method the user needs to reauthenticate using
    /// `requestAccessToken`.
    open func clearAccessToken() {
        accessTokenStore.storeAccessToken(nil)
    }
    
    /// Requests an access token with the resource owner's password credentials.
    ///
    /// **Note:** The completion closure may be invoked on any thread.
    ///
    /// - parameter username: The resource owner's username.
    /// - parameter password: The resource owner's password.
    /// - parameter completion: A callback to invoke when the request completed.
    open func requestAccessToken(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        requestAccessToken(grant: .basicAuthentication(username: username, password: password)) { result in
            completion(result.map { _ in return })
        }
    }
    
    /// Requests an access token with the given grant type URI and parameters
    ///
    /// **Note:** The completion closure may be invoked on any thread.
    ///
    /// - parameter grantType: The grant type URI of the extension grant
    /// - parameter parameters: The required parameters for the external grant
    /// - parameter completion: A callback to invoke when the request completed.
    open func requestAccessToken(grantType: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) {
        requestAccessToken(grant: .extension(grantType, parameters)) { result in
            completion(result.map { _ in return })
        }
    }
    
    /// Uses the provided access token to authenticate.
    ///
    /// - parameter accessToken: The access token to be used for authentication.
    open func authenticateWith(_ accessToken: JWToken) {
        self.accessToken = accessToken
    }
    
    /// Alters the given request by adding authentication with an access token.
    ///
    /// - parameter request: An unauthenticated URLRequest.
    /// - parameter accessToken: The access token to be used for authentication.
    ///
    /// - returns: The given request authorized using the resource request
    ///     authenticator.
    open func authenticateRequest<T: CanSetHeaderValues>(_ request: T, accessToken: JWToken) -> T {
        return requestAuthenticator.authenticateRequest(request, accessToken: accessToken)
    }
    
    /// Alters the given request by adding authentication, if possible.
    ///
    /// In case of an expired access token and the presence of a refresh token,
    /// automatically tries to refresh the access token. If refreshing the
    /// access token fails, the access token is cleared.
    ///
    /// **Note:** If the access token must be refreshed, network I/O is
    ///     performed.
    ///
    /// **Note:** The completion closure may be invoked on any thread.
    ///
    /// **Note:** Calls to this function are automatically serialized
    ///
    /// - parameter request: An unauthenticated URLRequest.
    /// - parameter completion: A callback to invoke with the authenticated request.
    open func authenticateRequest<T: CanSetHeaderValues>(_ request: T, completion: @escaping (Result<T, Error>) -> Void) {
        requestQueue.async {
            self.blockRequestQueue()
            self.authenticateRequestConcurrently(request, completion: completion)
        }
    }
    
    /// Requests an access token with the given authorization grant.
    ///
    /// The client is authenticated via HTTP Basic Authentication if both an
    /// identifier and a secret are set in its credentials. Otherwise, if only
    /// an identifier is set, it is encoded as parameter.
    ///
    /// - parameter grant: The authorization grant (e.g., refresh).
    /// - parameter completion: A callback to invoke when the request completed.
    private func requestAccessToken(grant: HTTPAuthentication, completion: @escaping (Result<JWToken, Error>) -> Void) {
        var request = tokenURLRequest
        
        var parameters = grant.authRequestParameters
        
        if let credentials = credentials {
            if let secret = credentials.secret {
                request.setHTTPAuthorization(.basicAuthentication(username: credentials.id, password: secret))
            } else {
                parameters["client_id"] = credentials.id
            }
        }
        
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parametersAsBodyData(parameters)
        
        serverConnector.sendRequest(request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if (response as! HTTPURLResponse).statusCode == 200 {
                if let data = data,
                    let accessToken = try? self.accessTokenParser.parse(data: data) {
                    self.accessToken = accessToken
                    completion(.success(accessToken))
                } else {
                    let receivedValueAsString = (data != nil) ? String(data: data!, encoding: .utf8): "nil"
                    completion(.failure(AuthSessionError.unableToRetrieveToken(receivedValueAsString ?? "nil")))
                }
            } else {
                if let data = data,
                    let error = OAuthError.decode(data: data) {
                    completion(.failure(error))
                } else {
                    let receivedValueAsString = (data != nil) ? String(data: data!, encoding: .utf8): "nil"
                    completion(.failure(AuthSessionError.errorWithNoData(receivedValueAsString ?? "nil")))
                }
            }
        }
    }
    
    private func parametersAsBodyData(_ parameters: [String: String]) -> Data? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https" // doesn't matter
        urlComponents.host = "someHost" // doesn't matter
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        if let bodyString = urlComponents.percentEncodedQuery {
            return bodyString.data(using: String.Encoding.utf8)
        }
        return nil
    }
    
    private func authenticateRequestConcurrently<T: CanSetHeaderValues>(_ request: T, completion: @escaping (Result<T, Error>) -> Void) {
        if let accessToken = accessToken {
            if let expiration = accessToken.expiresAt, expiration < Date() {
                if let refreshToken = accessToken.refreshToken, !refreshToken.isEmpty {
                    requestAccessToken(grant: .refreshToken(refreshToken)) { [weak self] result in
                        guard let self = self else {
                            completion(.failure(AuthSessionError.noRefreshToken))
                            return
                        }
                        switch result {
                        case .failure(let error):
                            self.clearAccessToken()
                            completion(.failure(error))
                        case .success(let token):
                            let authenticatedRequest = self.authenticateRequest(request, accessToken: token)
                            return completion(.success(authenticatedRequest))
                        }
                        self.releaseRequestQueue()
                    }
                } else {
                    completion(.failure(AuthSessionError.noRefreshToken))
                    releaseRequestQueue()
                }
            } else {
                let request = authenticateRequest(request, accessToken: accessToken)
                completion(.success(request))
                releaseRequestQueue()
            }
        } else {
            completion(.failure(AuthSessionError.notAuthorized))
            releaseRequestQueue()
        }
    }
    
    private func blockRequestQueue() {
        requestQueue.suspend()
    }
    
    private func releaseRequestQueue() {
        requestQueue.resume()
    }
}
