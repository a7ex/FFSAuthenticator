import XCTest
@testable import FFSAuthenticator

final class FFSAuthenticatorTests: XCTestCase {
    func testJWTToken() {
        let token = JWToken(accessToken: "", tokenType: "", expiresAt: Date(), refreshToken: "")
        let tokenCopy = token.copy(accessToken: "A new token")
        XCTAssertNotEqual(tokenCopy.accessToken, token.accessToken)
        XCTAssertEqual(tokenCopy.accessToken, "A new token")
        XCTAssertEqual(tokenCopy.tokenType, token.tokenType)
        XCTAssertEqual(tokenCopy.expiresAt, token.expiresAt)
        XCTAssertEqual(tokenCopy.refreshToken, token.refreshToken)
        
        let tokenTypeCopy = tokenCopy.copy(tokenType: "A new token type")
        XCTAssertEqual(tokenTypeCopy.accessToken, tokenCopy.accessToken)
        XCTAssertNotEqual(tokenTypeCopy.tokenType, tokenCopy.tokenType)
        XCTAssertEqual(tokenTypeCopy.tokenType, "A new token type")
        XCTAssertEqual(tokenTypeCopy.expiresAt, tokenCopy.expiresAt)
        XCTAssertEqual(tokenTypeCopy.refreshToken, tokenCopy.refreshToken)
        
        let newDate = Date().addingTimeInterval(3600)
        let expiresAtCopy = tokenTypeCopy.copy(expiresAt: newDate)
        XCTAssertEqual(tokenTypeCopy.accessToken, expiresAtCopy.accessToken)
        XCTAssertEqual(tokenTypeCopy.tokenType, expiresAtCopy.tokenType)
        XCTAssertNotEqual(tokenTypeCopy.expiresAt, expiresAtCopy.expiresAt)
        XCTAssertEqual(expiresAtCopy.expiresAt, newDate)
        XCTAssertEqual(tokenTypeCopy.refreshToken, expiresAtCopy.refreshToken)
        
    }

    static var allTests = [
        ("testJWTToken", testJWTToken),
    ]
}
