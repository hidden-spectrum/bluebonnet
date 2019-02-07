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

/// Represents an API service, or a collection of APIs. This can be used to point to specific
/// versions of an  API, or different services entirely. Each `ServiceRequest` can point to a
/// different `Service`.
///
/// - After defining your `Server.Map` instances, define your `Service`s:
/// ```
/// let v1Service = Service(serverMap: mainServerMap, contextRoot: "v1")
/// ```
public struct Service<Env: Environment> {
    
    /// The `Server.Map` for this `Service`. See `Server.Map` for more info.
    public let serverMap: Server.Map<Env>
    
    /// The context root for this service. If you have a service that uses the same `Server.Map`
    /// then you can use this to define a path that is always present, for example `"v1"`.
    public let contextRoot: String?
    
    // This generates the base URL for the current environment. Used in `ServiceRequest` to generate
    // the URL for the request.
    internal var baseUrlForCurrentEnvironment: URL {
        guard let environment = Env.current else {
            fatalError("Attempted to generate a base URL when no current environment has been set")
        }
        
        let server = self.serverMap.block(environment)
        var urlString = server.connectionProtocol.rawValue + "://" + server.host
        if let contextRoot = self.contextRoot {
            urlString += "/" + contextRoot
        }
        return URL(string: urlString)!
    }
    
    public init(serverMap: Server.Map<Env>, contextRoot: String? = nil) {
        self.serverMap = serverMap
        self.contextRoot = contextRoot
    }
}
