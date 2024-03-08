//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


/** A protocol to define your server environments. This is typically an enum.
 
    Example:
    ```
    enum ServerEnvironment: Environment {
        static let current: ServerEnvironment? = .production
        
        case staging
        case production
    }
    ```
 */
public protocol Environment {
    
    /**
     This tracks the current environment. Set this before making any service requests.
     See ``Environment`` for more info.
     */
    static var current: Self? { get set }
}
