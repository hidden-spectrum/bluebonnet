//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public extension JSONDecoder {
    
    /**
     Default decoder used for ``ServiceRequest``s. Uses `.iso8601DateTimeWithMilliseconds` and `.convertFromSnakeCase`.
     */
    static let bluebonnetDefault: JSONDecoder = .custom(dateFormatter: .iso8601DateTimeWithMilliseconds, keyDecodingStrategy: .convertFromSnakeCase)
    
    /// Convenience initializer.
    static func custom(dateFormatter: DateFormatter, keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys) -> JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
        return jsonDecoder
    }
}


public extension JSONEncoder {
    
    /**
     Standard encoder used for `ServiceRequest`s. Uses `.iso8601DateTimeWithMilliseconds` and `.convertToSnakeCase`.
     */
    static let bluebonnetDefault: JSONEncoder = .custom(dateFormatter: .iso8601DateTimeWithMilliseconds, keyEncodingStrategy: .convertToSnakeCase)
    
    /// Convenience initializer.
    static func custom(dateFormatter: DateFormatter, keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys) -> JSONEncoder {
        let jsonDecoder = JSONEncoder()
        jsonDecoder.dateEncodingStrategy = .formatted(dateFormatter)
        jsonDecoder.keyEncodingStrategy = keyEncodingStrategy
        return jsonDecoder
    }
}
