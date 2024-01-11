//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


/// This type holds all global configuration options and miscellaneous variables.
public struct Bluebonnet {
    
    /// The `URLSesssion` to use. See `URLSession` for more info.
    public static var urlSession = URLSession.shared
    
    static let logger = Logger(subsystem: "io.hiddenspectrum.bluebonnet", category: "Bluebonnet")
}


/// Errors specific to Bluebonnet.
public enum BluebonnetError: Error {
    case couldNotGenerateRequestURL
    case receivedNonHTTPURLResponse
    case unexpectedlyReceivedEmptyResponseBody
    case unexpectedStatusCode(HTTPStatusCode)
}
