//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


/**
 Represents an API service, or a collection of APIs. This can be used to point to specific versions of an  API, or different services entirely.
 Each ``ServiceRequest`` can point to a different ``Service``.
 
 After defining your ``Server/Map`` instances, define your ``Service`` instances:
 ```
 let v1Service = Service(serverMap: mainServerMap, contextRoot: "v1")
 ```
 */
public struct Service<Env: Environment> {
    
    /// The ``Server/Map`` for this ``Service``.
    public let serverMap: Server.Map<Env>
    
    /**
     The context root for this service.
     If you have a service that uses the same ``Server/Map`` then you can use this to define a path that is always present, for example `"v1"`.
     */
    public let contextRoot: String?
    
    // This generates the base URL for the current environment. Used in `ServiceRequest` to generate
    // the URL for the request.
    internal var baseUrlForCurrentEnvironment: URL {
        guard let environment = Env.current else {
            fatalError("Attempted to generate a base URL when no current environment has been set")
        }
        
        let server = serverMap.block(environment)
        var urlString = server.connectionProtocol.rawValue + "://" + server.host
        if let contextRoot = contextRoot {
            urlString += "/" + contextRoot
        }
        return URL(string: urlString)!
    }
    
    public init(serverMap: Server.Map<Env>, contextRoot: String? = nil) {
        self.serverMap = serverMap
        self.contextRoot = contextRoot
    }
}
