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


public enum ServiceResponseResult<T: Decodable> {
    case success(T)
    case failure(Error)
}


public protocol ServiceRequest {
    associatedtype Env: Environment
    associatedtype ServiceResponse: Decodable
    
    /// The service this request should hit. See `Service` for more info.
    var service: Service<Env> { get }
    
    /// The path for this request, appeneded to the baseUrl returned by `service`.
    var path: String { get }
    
    /// Whether this request should be retried on 401 Unauthorized response. Defaults to true.
    /// This should be set to false for requests that establish OAuth credentials.
    var retryOnUnauthorizedResponse: Bool { get }
    
    /// Optional timeout interval if necessary to have one other than HTTP/1.1 standard of 2 minutes.
    var timeoutInterval: TimeInterval? { get }
    
    /// A constructor that will help build the request.
//    var requestConstructor: RequestConstructor { get }
    
    /// Whether this request is gated by oAuth. Default is true.
    var requiresOAuthCredentials: Bool { get }
    
    /// The JSONDecoder to use. Defaults to `APIClientConfiguration.jsonDecoder`.
    var jsonDecoder: JSONDecoder { get }
    
    /// An optional function that translates JSON errors to typed Swift Errors.
//    var errorTranslator: FailureResponseClosure? { get }
    
    /// Builds the underlying data task and `resume`s it. This method is implemented by the default
    /// extension.
    func start(retryIfUnauthorized: Bool, completionHandler: ((ServiceResponseResult<ServiceResponse>) -> Void)?) -> URLSessionDataTask?
    
    /// Decodes the response data. Only called on a successful response (2xx). If APIResponse == EmptyAPIResponse than
    /// this method always returns .success(EmptyAPIResponse()).
    func decodeResponse(data: Data?, from request: URLRequest) -> ServiceResponseResult<ServiceResponse>
}
