//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


/// This type holds all global configuration options and miscellaneous variables.
public struct Bluebonnet: Sendable {
    
    /// The `URLSesssion` to use. See `URLSession` for more info.
    public static let urlSession = URLSession.shared
    
    static let logger = Logger(subsystem: "io.hiddenspectrum.bluebonnet", category: "Bluebonnet")
}


/// Errors specific to Bluebonnet.
public enum BluebonnetError: Error, Sendable {
    case couldNotGenerateRequestURL
    case polledRequestMaxAttemptsExceeded
    case polledRequestFailed
    case receivedNonHTTPURLResponse
    case unexpectedlyReceivedEmptyResponseBody
    case unexpectedStatusCode(HTTPStatusCode)
}

extension BluebonnetError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .couldNotGenerateRequestURL:
            "Could not generate request URL"
        case .polledRequestFailed:
            "Polled request failed"
        case .polledRequestMaxAttemptsExceeded:
            "Max attempts exceeded"
        case .receivedNonHTTPURLResponse:
            "Received non-HTTP URL response"
        case .unexpectedlyReceivedEmptyResponseBody:
            "Unexpectedly received empty response body"
        case .unexpectedStatusCode(let statusCode):
            "Status code: \(statusCode.rawValue)"
        }
    }
}
