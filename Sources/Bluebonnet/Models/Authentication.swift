//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


/**
 The type of authentication to use for a ``ServiceRequest``.
 */
public enum Authentication {
    
    /// Basic authentication.
    case basic(username: String, password: String)
    
    /// Bearer token authentication.
    case bearer(token: String)
}
