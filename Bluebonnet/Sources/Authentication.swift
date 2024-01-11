//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public enum Authentication {
    case basic(username: String, password: String)
    case bearer(token: String)
}
