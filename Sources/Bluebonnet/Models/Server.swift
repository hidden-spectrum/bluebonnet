//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


/**
 Represents a backend server. This is used to generate the base URLs for a ``ServiceRequest``.
 - Tip: Extend this struct with your servers if you use them with multiple ``Server/Map``  instances:
 ```
 extension Server {
    static let herokuStaging = Server(host: "myapp-staging.herokuapp.com")
    static let herokuProduction = Server(host: "myapp.herokuapp.com")
 }
 ```
 */
public struct Server: Codable {
    
    /// The ``ConnectionProtocol`` to use when generating the URL for this server.
    public let connectionProtocol: ConnectionProtocol
    
    /// The server's host name.
    public let host: String
    
    /**
     Creates a new instance of `Server` with the given host.
     
     - Parameters:
        - connectionProtocol: The protocol to use when generating the URL for this server.
        - host: The server's host name, such as `www.example.com`.]
     
     See  ``Server/ConnectionProtocol-swift.enum`` for more info.
     */
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
    
    /**
     Stores a closure that allows you to define how to map an `Environment` to defined `Server`
     instance.
    
     - After defining your `Server` instances, define your map:
     ```
     let mainServerMap = Server.Map { environment in
         switch environment {
             case .staging:
                 return .herokuStaging
             case .production:
                 return .herokuProduction
         }
    }
     ```
     */
    public struct Map<Environment> {
        internal let block: ((Environment) -> Server)
        
         /// Creates a new instance of ``Server/Map`` with the given block.
        public init(_ block: @escaping ((Environment) -> Server)) {
            self.block = block
        }
    }
    
    /// Possible connection protocols to a ``Server``.
    public enum ConnectionProtocol: String, Codable {
        
        /// Non-secure HTTP protocol.
        case http
        
        /// Secure HTTPS protocol.
        case https
    }
}
