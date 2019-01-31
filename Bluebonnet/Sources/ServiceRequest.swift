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


public protocol ServiceRequest {
    associatedtype Env: Environment
    associatedtype Parameters: Encodable
    associatedtype ServiceResponseContent: Decodable
    
    typealias ServiceRequestResultClosure = (ServiceRequestResult<ServiceResponseContent>) -> Void
    
    /// The HTTP method to use for this request. See `HTTPMethod` for more info.
    var method: HTTPMethod { get }
    
    /// The service this request should hit. See `Service` for more info.
    var service: Service<Env> { get }
    
    /// The path for this request, appeneded to the baseUrl returned by `service`.
    var path: String { get }
    
    /// Any parameters to send with this request.
    var parameters: Parameters? { get }
    
    /// Whether this request should be retried on 401 Unauthorized response. Defaults to true.
    /// This should be set to false for requests that establish OAuth credentials.
    var retryOnUnauthorizedResponse: Bool { get }
    
    /// Optional timeout interval if necessary to have one other than HTTP/1.1 standard of 2 minutes.
    var timeoutInterval: TimeInterval? { get }

    /// Whether this request is gated by oAuth. Default is true.
    var requiresOAuthCredentials: Bool { get }
    
    /// The JSONDecoder to use. Defaults to `APIClientConfiguration.jsonDecoder`.
    var jsonDecoder: JSONDecoder { get }
    
    /// Builds the underlying data task and `resume`s it. This method is implemented by the default
    /// extension.
    func start(retryIfUnauthorized: Bool, completionHandler: ServiceRequestResultClosure?) -> URLSessionDataTask?
    
    /// Decodes the response data. Only called on a successful response (2xx). If APIResponse == EmptyAPIResponse than
    /// this method always returns .success(EmptyAPIResponse()).
    func decodeResponseBody(data: Data?, from request: URLRequest) -> ServiceRequestResult<ServiceResponseContent>
}

extension ServiceRequest {
    public var timeoutInterval: TimeInterval? {
        return nil
    }
    
    public var retryOnUnauthorizedResponse: Bool {
        return true
    }
    
    public var requiresOAuthCredentials: Bool {
        return true
    }
    
    public var jsonDecoder: JSONDecoder {
        return .bluebonnetDefault
    }
    
    @discardableResult
    public func start(retryIfUnauthorized: Bool = true, completionHandler: ServiceRequestResultClosure? = nil) -> URLSessionDataTask? {
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
                    mainQueueCompletionHandler(.failure([error]))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = BluebonnetError.receivedNonHTTPURLResponse
                    self.logIssue(from: request, error: error, response: response)
                    mainQueueCompletionHandler(.failure([error]))
                    return
                }
                
                let httpStatusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) ?? .unknown
                
                if httpStatusCode == .unauthorized {
                    if retryIfUnauthorized && self.retryOnUnauthorizedResponse {
                        print("\n[WARNING] on APIRequest - \(self.urlAbsoluteString(for: response)): 401 Status Code; Retrying request...")
//                        self.reauthenticateAndRetryRequest(completionHandler: completionHandler)
                    } else {
                        self.logIssue(from: request, response: response, responseData: data)
                        mainQueueCompletionHandler(.failure([BluebonnetError.unexpectedStatusCode(.unauthorized)]))
                    }
                    return
                }
                
                let successStatusCodes: [HTTPStatusCode] = [.success, .created, .noContent, .accepted]
                guard successStatusCodes.contains(httpStatusCode) else {
                    self.logIssue(from: request, response: response, responseData: data)
                    mainQueueCompletionHandler(.failure([BluebonnetError.unexpectedStatusCode(httpStatusCode)]))
                    return
                }
                
                mainQueueCompletionHandler(self.decodeResponse(data: data, from: request))
            }
            
            dataTask.resume()
            return dataTask
            
        } catch let error {
//            if let networkingError = error as? BluebonnetError, case .missingRequiredOAuthCredentials = networkingError {
//                self.reauthenticateAndRetryRequest(completionHandler: completionHandler)
//            } else {
                completionHandler?(.failure([error]))
//            }
            return nil
        }
    }
    
    private func urlRequest() throws -> URLRequest {
        let urlString = self.service.baseUrlForCurrentEnvironment.appendingPathComponent(self.path)
        
        guard var urlComponents = URLComponents(url: urlString, resolvingAgainstBaseURL: false) else {
            throw BluebonnetError.couldNotGenerateRequestURL
        }
        
        if let parameters = self.parameters, self.method == .get {
            urlComponents.queryItems = try URLQueryEncoder().encode(parameters)
        }
        
        guard let completeUrl = urlComponents.url else {
            throw BluebonnetError.couldNotGenerateRequestURL
        }
        
        var request = URLRequest(url: completeUrl)
        request.httpMethod = self.method.rawValue
        
        if let timeoutInterval = self.timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }
        
        if let parameters = self.parameters, [.post, .patch, .put].contains(self.method) {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try jsonEncoder.encode(parameters)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
        
//        if let accessToken = AuthenticationManager.currentUser?.accessToken {
//            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        }
        
        return request
    }
    
    public func decodeResponse(data: Data?, from request: URLRequest) -> ServiceRequestResult<ServiceResponseContent> {
        guard let data = data, !data.isEmpty else {
            return .failure([BluebonnetError.unexpectedlyReceivedEmptyResponseBody])
        }
        
        do {
            let responseModel = try self.jsonDecoder.decode(ServiceResponseContent.self, from: data)
            return .success(responseModel)
        } catch let error {
            self.logIssue(from: request, error: error)
            return .failure([error])
        }
    }
    
//    private func reauthenticateAndRetryRequest(completionHandler: ServiceRequestResultClosure?) {
//        let retryOriginalRequest = { (result: AuthenticationResult) in
//            switch result {
//            case .success:
//                _ = self.start(retryIfUnauthorized: false, completionHandler: completionHandler)
//            case .failure(let errors):
//                let unhandledErrors = ErrorManager.handle(errors: errors)
//                completionHandler?(.failure(unhandledErrors))
//            }
//        }
//
//        DispatchQueue.main.async {
//            if let refreshToken = AuthenticationManager.oAuthCredentials?.refreshToken, AuthenticationManager.oAuthCredentials?.isExpired == false {
//                print("\t...using refresh token")
//                AuthenticationManager.refreshAccessToken(refreshToken: refreshToken, completionHandler: retryOriginalRequest)
//            } else {
//                print("\t...by logging out and reauthenticating")
//                AuthenticationManager.logoutThenReauthenticate(completionHandler: retryOriginalRequest)
//            }
//        }
//    }
    
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
    
    private func urlAbsoluteString(for response: URLResponse?) -> String {
        return response?.url?.absoluteString ?? "UNKNOWN URL"
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
