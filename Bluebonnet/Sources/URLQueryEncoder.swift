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


/// Errors that can be thrown by `URLQueryEncoder`.
enum URLQueryEncoderError: Error {
    
    /// URL queries are key:value pairs, therefore if we receive a Encodable type that does not
    /// have key/value pairs, this error will be thrown.
    case topLevelContainerNotDictionary
}


/// This structure allows you to encode any value conforming to Encodable protocol into an array of
/// URLQueryItems, which you can then pass to URLComponents instance to convert into a percent-encoded
/// string.
///
/// References:
/// - https://github.com/Alamofire/Alamofire/blob/master/Source/ParameterEncoding.swift
public class URLQueryEncoder {
    
    // MARK: Encoding
    
    /// Invoke this method on a new instance to attempt to encode the given value.
    public func encode<T: Encodable>(_ value: T) throws -> [URLQueryItem] {
        // Lean on the JSON encoder to do the heavy lifting of converting the value to a useable container
        // This is hacky, but it works and requires less maintenance than rolling our own Encoder
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try jsonEncoder.encode(value)
        let container = try JSONSerialization.jsonObject(with: jsonData, options: [])
        
        guard let dictionaryContainer = container as? [String: Any] else {
            throw URLQueryEncoderError.topLevelContainerNotDictionary
        }
        
        return self.queryItems(from: dictionaryContainer)
    }
    
    /// Once a value has been converted to a Swift container (in this case a dictionary) then use
    /// this method to convert to the final output needed (in this case, an array of
    /// `URLQueryItem`s).
    private func queryItems(from container: [String: Any]) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        
        for key in container.keys.sorted(by: <) {
            if let value = container[key] {
                queryItems += self.queryItems(fromKey: key, value: value)
            }
        }
        
        return queryItems
    }
    
    /// This method recursively goes through key/value pairs and converts them to `URLQueryItem`s
    /// with the values converted to strings.
    private func queryItems(fromKey key: String, value: Any) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                queryItems += self.queryItems(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                queryItems += self.queryItems(fromKey: "\(key)[]", value: value)
            }
        } else if let bool = value as? Bool {
            queryItems.append(URLQueryItem(name: key, value: bool ? "1" : "0"))
        } else {
            queryItems.append(URLQueryItem(name: key, value: "\(value)"))
        }
        
        return queryItems
    }
}
