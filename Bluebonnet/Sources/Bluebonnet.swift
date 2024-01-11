//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


/// This type holds all global configuration options and miscellaneous variables.
public struct Bluebonnet {
    
    /// The `URLSesssion` to use. See `URLSession` for more info.
    public static var urlSession = URLSession.shared
}


/// Errors specific to Bluebonnet.
public enum BluebonnetError: Error {
    case couldNotGenerateRequestURL
    case receivedNonHTTPURLResponse
    case unexpectedlyReceivedEmptyResponseBody
    case unexpectedStatusCode(HTTPStatusCode)
}


internal extension OSLog {
    
    /// Log for `os_log` calls.
    static let bluebonnet = OSLog(subsystem: "com.theisholdings.bluebonnet", category: "Bluebonnet")
}
