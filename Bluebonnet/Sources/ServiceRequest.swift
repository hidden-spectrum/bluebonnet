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


/// Returned in the completionHandler for all ServiceRequests, this indicates a success with the
/// typed content or failure with any errors.
public enum ServiceRequestResult<ServiceResponseContent: Decodable> {
    case success(ServiceResponseContent)
    case failure(Error)
}


/// A type representing an empty Encodable/Decodable type. Use this for `ServiceRequest`s that have
/// empty parameters or body data.
public struct Empty: Codable {
}


public protocol ServiceRequest {
    
    /// The environment of the `Service` used in `service` parameter. This will be auto-defined by
    /// the compiler.
    associatedtype Env: Environment
    
    /// The type you are using for parameters of the request. Use `Empty` if there are none.
    associatedtype Parameters: Encodable
    
    /// The type that the response's body should be decoded into.
    associatedtype ServiceResponseContent: Decodable
    
    /// Closure used for `completionHandler` on `start(...)` and `decode(...)` methods.
    typealias ServiceRequestResultClosure = (ServiceRequestResult<ServiceResponseContent>) -> Void
    
    /// The HTTP method to use for this request. See `HTTPMethod` for more info.
    var method: HTTPMethod { get }
    
    /// The service this request should hit. See `Service` for more info.
    var service: Service<Env> { get }
    
    /// The path for this request, appeneded to the baseUrl returned by `service`.
    var path: String { get }
    
    /// Any parameters to send with this request. Defaults to nil.
    var parameters: Parameters? { get }
    
    /// The authentication method to use for this request. There is no default so that you can
    /// set one via an extension in your application.
    var authentication: Authentication? { get }
    
    /// The JSONEncoder to use for `POST`/`PUT`/`PATCH` requests. Defaults to
    /// `JSONEncoder.bluebonnetDefault`.
    var jsonEncoder: JSONEncoder { get }
    
    /// The JSONDecoder to use. Defaults to `JSONDecoder.bluebonnetDefault`.
    var jsonDecoder: JSONDecoder { get }
    
    /// Builds the underlying data task and `resume`s it. This method is implemented by the default
    /// extension.
    func start(completionHandler: ServiceRequestResultClosure?) -> URLSessionDataTask?
    
    /// Decodes the response data. Only called on a successful response (2xx). If
    /// `ServiceResponseContent` == Empty then this method always returns `.success(Empty())`.
    func decodeResponseContent(data: Data?, from request: URLRequest) -> ServiceRequestResult<ServiceResponseContent>
}

extension ServiceRequest {
    public var parameters: Parameters? {
        return nil
    }
    
    public var jsonEncoder: JSONEncoder {
        return .bluebonnetDefault
    }
    
    public var jsonDecoder: JSONDecoder {
        return .bluebonnetDefault
    }
    
    @discardableResult
    public func start(completionHandler: ServiceRequestResultClosure? = nil) -> URLSessionDataTask? {
        do {
            let request = try self.urlRequest()
            
            let mainQueueCompletionHandler = { (result: ServiceRequestResult<ServiceResponseContent>) in
                DispatchQueue.main.async {
                    completionHandler?(result)
                }
            }
            
            let dataTask = Bluebonnet.urlSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    self.logIssue(from: request, error: error, response: response)
                    mainQueueCompletionHandler(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = BluebonnetError.receivedNonHTTPURLResponse
                    self.logIssue(from: request, error: error, response: response)
                    mainQueueCompletionHandler(.failure(error))
                    return
                }
                
                let httpStatusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) ?? .unknown
                let successStatusCodes: [HTTPStatusCode] = [.success, .created, .noContent, .accepted]
                guard successStatusCodes.contains(httpStatusCode) else {
                    self.logIssue(from: request, response: response, responseData: data)
                    mainQueueCompletionHandler(.failure(BluebonnetError.unexpectedStatusCode(httpStatusCode)))
                    return
                }
                
                mainQueueCompletionHandler(self.decodeResponseContent(data: data, from: request))
            }
            
            dataTask.resume()
            return dataTask
            
        } catch let error {
            completionHandler?(.failure(error))
            return nil
        }
    }
    
    private func urlRequest() throws -> URLRequest {
        let urlString = self.service.baseUrlForCurrentEnvironment.appendingPathComponent(self.path)
        
        guard var urlComponents = URLComponents(url: urlString, resolvingAgainstBaseURL: false) else {
            throw BluebonnetError.couldNotGenerateRequestURL
        }
        
        if let parameters = self.parameters, self.method == .get {
            urlComponents.queryItems = try URLQueryEncoder().encode(parameters, baseEncoder: self.jsonEncoder)
        }
        
        guard let completeUrl = urlComponents.url else {
            throw BluebonnetError.couldNotGenerateRequestURL
        }
        
        var request = URLRequest(url: completeUrl)
        request.httpMethod = self.method.rawValue
        
        if let parameters = self.parameters, [.post, .patch, .put].contains(self.method) {
            request.httpBody = try self.jsonEncoder.encode(parameters)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
        
        if let authentication = self.authentication {
            switch authentication {
            case .basic(let username, let password):
                let combinedCredentials = username + ":" + password
                let encodedCredentials = String(data: Data(base64Encoded: combinedCredentials)!, encoding: .utf8)!
                request.setValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
            case .bearer(let token):
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        return request
    }
    
    public func decodeResponseContent(data: Data?, from request: URLRequest) -> ServiceRequestResult<ServiceResponseContent> {
        guard let data = data, !data.isEmpty else {
            return .failure(BluebonnetError.unexpectedlyReceivedEmptyResponseBody)
        }
        
        do {
            let responseModel = try self.jsonDecoder.decode(ServiceResponseContent.self, from: data)
            return .success(responseModel)
        } catch let error {
            self.logIssue(from: request, error: error)
            return .failure(error)
        }
    }
    
    private func logIssue(from request: URLRequest, error: Error? = nil, response: URLResponse? = nil, responseData: Data? = nil) {
        bb_log_error(
            """
            \n%{public}

            Request:
            %{public} %{public}
            """,
            String(describing: error),
            request.httpMethod ?? "",
            request.debugDescription
        )
        
        request.allHTTPHeaderFields?.forEach { key, value in
            bb_log_error("\t%{public}: %@", key, value)
        }
        
        if let response = response as? HTTPURLResponse {
            bb_log_error(
                """
                \nResponse:
                %{public}

                Response Data:
                %@
                """,
                response.debugDescription,
                self.stringFromData(responseData)
            )
        }
    }
    
    private func stringFromData(_ data: Data?) -> String {
        return String(data: data ?? Data(), encoding: .utf8) ?? "<None>"
    }
}

extension ServiceRequest where ServiceResponseContent == Empty {
    public func decodeResponse(data: Data?, from request: URLRequest) -> ServiceRequestResult<ServiceResponseContent> {
        return .success(Empty())
    }
}
