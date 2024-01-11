//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


/// Conform to this protocol to handle an error from a `ServiceRequest`. 
///
/// This allows you to handle common errors in a global way. While the error will still be thrown by ``ServiceRequest/start()`` You can ignore it if you know it's being handled by one of these types.
///
/// See ``ServiceErrorSifter`` for more info.
public protocol ServiceErrorHandler {
    
    /// Handle the error. Return `true` if handled, return `false` if not.
    func handle(error: Error) -> Bool
}
