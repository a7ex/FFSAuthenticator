# FFSAuthenticator

This library provides a mechanism to authenticate requests. In simple words: Add the required headers to the request.
It is heavily inspired by the Heimdallr OAuth2 Library. (Find the original here: https://github.com/trivago/Heimdallr.swift/tree/master/Heimdallr)

First login to the backend in order to get a token. This token is stored securely in the keychain. It is always read directly from the keychain. No sensible data is not kept in instance variables. Accessing the keychain everytime is safer, but a tad slower.

## Usage

Create an instance of the Authenticator class. The only required parameter is a URLRequest, which can retrieve and refresh a JWT token.

Note that the body of this URLRequest is overwriten with the provided credentials data.
Also note that the request's httpMethod is forced to "POST"
and the header value "Content-Type" is forced to "application/x-www-form-urlencoded"

```Swift
import AuthSession

struct Backend {
    private let authenticator: Authenticator?
    
    init(loginRequest: URLRequest) {
        authenticator = Authenticator(tokenURLRequest: loginRequest)
    }
    
    func login(user: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        authenticator.clearAccessToken()
        authenticator.requestAccessToken(username: user, password: password, completion: completion)
    }
    
    func runAuthenticatedTask(with request: URLRequest,
                    completion: @escaping (Result<StringResponse, Error>) -> Void) {
                    
        authenticator.authenticateRequest(request) { (result) in
            switch result {
            case .success(let authenticatedRequest):
                self.runTaskWith(authenticatedRequest, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    } 
}
```

An instance of Authenticator can only authenticate a request, if it has a valid accessToken or a valid refreshToken.
The entire JWT is stored in the Authenticators backing store. If that's the built-in keychain store, the stored token will persist across app runs.
If a valid access token is found, it is used, otherwise a new token will requested using the refresh token, if any.

If Authenticator doesn't find an accessToken in its store or by refreshing, then either a 'AuthSessionError.notAuthorized' or a 'AuthSessionError.noRefreshToken' error is returned.
It is then up to the UI layer to start the login process and provide credentials to log in.

To do so call:
```Swift
authenticator.requestAccessToken(username: user, password: password, completion: completion)
```
Once the call successfully returns, the access token will be available to run authenticator.authenticateRequest() and all should work fine.


## Points to override
- use your own Backing Store for the token (or use built-in iOS keychain store)
- use your own Urlsession (or use the built-in simple URLSession with default configuration)
- use your own AccessToken Parser (or use the built-in standard json decoder)
- use your own Request Authenticator (or us the built-in Request Mapper, which adds "Authorization" to the request headers)

