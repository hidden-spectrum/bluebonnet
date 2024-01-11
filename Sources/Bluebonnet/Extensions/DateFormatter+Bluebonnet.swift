//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public extension DateFormatter {
    
    /// For dates in the format of `yyyy-MM-dd'T'HH:mm:ssZ`.
    static let iso8601DateTime = DateFormatter.iso8601(format: "yyyy-MM-dd'T'HH:mm:ssXXXXX")
    
    /// For dates in the format of `yyyy-MM-dd'T'HH:mm:ss.SSSZ`.
    static let iso8601DateTimeWithMilliseconds = DateFormatter.iso8601(format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX")
    
    /// For dates in the format of `yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ`.
    static let iso8601DateTimeWithMicroseconds = DateFormatter.iso8601(format: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX")
    
    /// Convenience method to create above formats.
    private static func iso8601(format: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }
}
