//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


/// HTTP/1.1 methods as defined by https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html.
public enum HTTPMethod: String {
    case connect = "CONNECT"
    case delete = "DELETE"
    case get = "GET"
    case head = "HEAD"
    case options = "OPTIONS"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
    case trace = "TRACE"
}


/// HTTP/1.1 status codes as defined by https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
public enum HTTPStatusCode: Int {
    case unknown = 0 // Generic catchall, Not part of RFC spec
    
    case `continue` = 100
    case switchingProtocols = 101
    
    case success = 200
    case created = 201
    case accepted = 202
    case nonAuthoritativeInformation = 203
    case noContent = 204
    case resetContent = 205
    case partialContent = 206
    
    case multipleChoices = 300
    case movedPermanently = 301
    case found = 302
    case seeOther = 303
    case useProxy = 305
    case temporaryRedirect = 307
    
    case badRequest = 400
    case paymentRequired = 402
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case proxyAuthenticationRequired = 407
    case conflict = 409
    case gone = 410
    case lengthRequired = 411
    case preconditionFailed = 412
    case requestEntityTooLarge = 413
    case requestUriTooLong = 414
    case unsupportedMediaType = 415
    case requestedRangeNotSatisfiable = 416
    case expectationFailed = 417
    case unprocessableEntity = 422
    case tooManyRequests = 429
    case internalServerError = 500
    
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504
    case httpVersionNotSupported = 505
    
    public var stringValue: String {
        return String(rawValue)
    }
}
