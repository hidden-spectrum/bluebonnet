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


/// Represents a backend server. This is used to generate the base URLs for a `ServiceRequest`.
///
/// - Extend this struct with your servers:
/// ```
/// extension Server {
///     static let herokuStaging = Server(host: "myapp-staging.herokuapp.com")
///     static let herokuProduction = Server(host: "myapp.herokuapp.com")
/// }
/// ```
public struct Server: Codable {
    internal let host: String
    
    /// Creates a new instance of `Server` with the given host.
    public init(host: String) {
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
    /// - Extend this struct to define your maps:
    /// ```
    /// extension Server.Map {
    ///     static let main = Server.Map { environment in
    ///         switch environment {
    ///             case .staging:
    ///                 return .herokuStaging
    ///             case .production:
    ///                 return .herokuProduction
    ///         }
    ///     }
    /// }
    /// ```
    public struct Map<Env: Environment> {
        internal let block: ((Env) -> Server)
        
        /// Creates a new instance of `Server.Map` with the given block. See `Server.Map` for more
        /// info.
        public init(_ block: @escaping ((Env) -> Server)) {
            self.block = block
        }
    }
}
