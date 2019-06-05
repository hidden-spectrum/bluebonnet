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

import Foundation


/// Represents a backend server. This is used to generate the base URLs for a `ServiceRequest`.
///
/// - Tip - Extend this struct with your servers if you use them with multiple `Server.Map`
/// instances:
/// ```
/// extension Server {
///     static let herokuStaging = Server(host: "myapp-staging.herokuapp.com")
///     static let herokuProduction = Server(host: "myapp.herokuapp.com")
/// }
/// ```
public struct Server: Codable {
    
    /// The connection protocol to use when generating the URL for this server.
    public let connectionProtocol: ConnectionProtocol
    
    /// The server's host name.
    public let host: String
    
    /// Creates a new instance of `Server` with the given host.
    ///
    /// - Parameters:
    ///     - connectionProtocol: The protocol to use when generating the URL for this server. See
    ///     `Server.ConnectionProtocol` for more info.
    ///     - host: The server's host name, such as `www.example.com`.
    public init(_ connectionProtocol: ConnectionProtocol = .https, host: String) {
        self.connectionProtocol = connectionProtocol
        self.host = host
    }
}

extension Server: Equatable {
    public static func == (lhs: Server, rhs: Server) -> Bool {
        return lhs.host == rhs.host
    }
}

extension Server {
    
    /// Stores a closure that allows you to define how to map an `Environment` to defined `Server`
    /// instance.
    ///
    /// - After defining your `Server` instances, define your map:
    /// ```
    /// let mainServerMap = Server.Map { environment in
    ///     switch environment {
    ///         case .staging:
    ///             return .herokuStaging
    ///         case .production:
    ///             return .herokuProduction
    ///     }
    ///}
    /// ```
    public struct Map<Environment> {
        internal let block: ((Environment) -> Server)
        
        /// Creates a new instance of `Server.Map` with the given block. See `Server.Map` for more
        /// info.
        public init(_ block: @escaping ((Environment) -> Server)) {
            self.block = block
        }
    }
    
    /// Possible connection protocols to a `Server`.
    public enum ConnectionProtocol: String, Codable {
        
        /// Non-secure HTTP protocol.
        case http
        
        /// Secure HTTPS protocol.
        case https
    }
}
