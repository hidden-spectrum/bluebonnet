//
//  Copyright (c) 2019 Theis Holdings, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


public extension JSONDecoder {
    
    /// Default decoder used for `ServiceRequest`s. Uses `.iso8601DateTimeWithMilliseconds` and
    /// `.convertFromSnakeCase`.
    public static let bluebonnetDefault: JSONDecoder = .custom(dateFormatter: .iso8601DateTimeWithMilliseconds, keyDecodingStrategy: .convertFromSnakeCase)
    
    /// Convenience initializer.
    public static func custom(dateFormatter: DateFormatter, keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys) -> JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
        return jsonDecoder
    }
}


public extension JSONEncoder {
    
    /// Standard encoder used for `ServiceRequest`s. Uses `.iso8601DateTimeWithMilliseconds` and
    /// `.convertToSnakeCase`.
    public static let bluebonnetDefault: JSONEncoder = .custom(dateFormatter: .iso8601DateTimeWithMilliseconds, keyEncodingStrategy: .convertToSnakeCase)
    
    /// Convenience initializer.
    public static func custom(dateFormatter: DateFormatter, keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys) -> JSONEncoder {
        let jsonDecoder = JSONEncoder()
        jsonDecoder.dateEncodingStrategy = .formatted(dateFormatter)
        jsonDecoder.keyEncodingStrategy = keyEncodingStrategy
        return jsonDecoder
    }
}
